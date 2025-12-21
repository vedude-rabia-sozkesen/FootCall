import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/setting_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../services/team_service.dart';
import '../services/auth_service.dart';
import '../models/team_model.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

void _showNotImplemented(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Not implemented'),
      content: const Text('This feature is not implemented yet.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDark = settings.isDarkMode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Panel'),
            backgroundColor: isDark ? const Color(0xFF2D2D2D) : kAppGreen,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  settings.toggleTheme();
                },
                icon: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('players').doc(user.uid).snapshots(),
            builder: (context, playerSnapshot) {
              if (!playerSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final playerData = playerSnapshot.data!.data() as Map<String, dynamic>?;
              final teamId = playerData?['currentTeamId'] as String?;
              
              if (teamId == null) {
                return const Center(child: Text("You are not in a team"));
              }

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('teams').doc(teamId).snapshots(),
                builder: (context, teamSnapshot) {
                  if (!teamSnapshot.hasData || !teamSnapshot.data!.exists) {
                    return const Center(child: Text("Team not found"));
                  }
                  
                  final team = TeamModel.fromFirestore(teamSnapshot.data!);
                  
                  // Check if user is admin
                  if (team.createdBy != user.uid) {
                    return const Center(child: Text("You are not the admin of this team"));
                  }

                  return SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionTitle('Player Requests to Join Team'),
                                const SizedBox(height: 8),
                                _PlayerJoinRequestsList(teamId: teamId),
                                const SizedBox(height: 24),
                                _SectionTitle('Current Team Members'),
                                const SizedBox(height: 8),
                                _TeamMembersList(team: team),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          bottomNavigationBar: const AppBottomNavBar(activeIndex: 3),
        );
      },
    );
  }
}

// Aşağıdaki sınıflar (_SectionTitle, _PlayerRequestCard, vb.) aynı kalıyor
// çünkü sadece AppBar’daki tema butonu mantığını değiştiriyoruz

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Text(
      text,
      style: kSectionTitleStyle.copyWith(
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}

class _PlayerJoinRequestsList extends StatelessWidget {
  final String teamId;
  const _PlayerJoinRequestsList({required this.teamId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('player_team_requests')
          .where('teamId', isEqualTo: teamId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No player requests yet.',
              style: TextStyle(color: context.watch<SettingsProvider>().isDarkMode ? Colors.white70 : Colors.grey),
            ),
          );
        }

        // Filter out requests sent BY the admin (only show requests FROM players TO the admin's team)
        final requests = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final requestedBy = data['requestedBy'] as String?;
          final playerId = data['playerId'] as String?;
          // Only show requests where the player themselves requested (requestedBy == playerId)
          // This excludes requests sent by admin to players
          return requestedBy != null && playerId != null && requestedBy == playerId;
        }).toList();

        if (requests.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No player requests yet.',
              style: TextStyle(color: context.watch<SettingsProvider>().isDarkMode ? Colors.white70 : Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            for (final requestDoc in requests) ...[
              _PlayerRequestCard(requestDoc: requestDoc, teamId: teamId),
              const SizedBox(height: 12),
            ]
          ],
        );
      },
    );
  }
}

class _PlayerRequestCard extends StatelessWidget {
  final QueryDocumentSnapshot requestDoc;
  final String teamId;
  const _PlayerRequestCard({required this.requestDoc, required this.teamId});

  @override
  Widget build(BuildContext context) {
    final requestData = requestDoc.data() as Map<String, dynamic>;
    final playerId = requestData['playerId'] as String;
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final teamService = Provider.of<TeamService>(context, listen: false);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('players').doc(playerId).snapshots(),
      builder: (context, playerSnapshot) {
        if (!playerSnapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final playerData = playerSnapshot.data!.data() as Map<String, dynamic>?;
        final playerName = playerData?['name'] ?? 'Unknown Player';
        final photoUrl = playerData?['photoUrl'] as String?;

        return Container(
          height: 90,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : kAppBlueCard,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : const AssetImage('lib/images/sample_player.jpeg') as ImageProvider,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      playerName,
                      style: kCardTitleStyle.copyWith(
                        color: isDark ? Colors.white : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wants to join your team',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CircleIconButton(
                    background: kAppRed,
                    icon: Icons.close,
                    onPressed: () => _rejectRequest(context, requestDoc.id),
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    background: kAppGreenBright,
                    icon: Icons.check,
                    onPressed: () => _acceptRequest(context, requestDoc.id, playerId, teamId, teamService),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _acceptRequest(BuildContext context, String requestId, String playerId, String teamId, TeamService teamService) async {
    try {
      // Accept the request - add player to team
      await teamService.joinTeam(teamId, playerId);
      
      // Update request status
      await FirebaseFirestore.instance.collection('player_team_requests').doc(requestId).update({
        'status': 'accepted',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Player added to team'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(BuildContext context, String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('player_team_requests').doc(requestId).update({
        'status': 'rejected',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _TeamMembersList extends StatelessWidget {
  final TeamModel team;
  const _TeamMembersList({required this.team});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final teamService = Provider.of<TeamService>(context, listen: false);
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    if (team.memberIds.isEmpty) {
      return Text(
        'No team members',
        style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
      );
    }

    return Column(
      children: [
        for (final memberId in team.memberIds) ...[
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('players').doc(memberId).snapshots(),
            builder: (context, playerSnapshot) {
              if (!playerSnapshot.hasData) {
                return const SizedBox.shrink();
              }
              
              final playerData = playerSnapshot.data!.data() as Map<String, dynamic>?;
              final playerName = playerData?['name'] ?? 'Unknown Player';
              final photoUrl = playerData?['photoUrl'] as String?;
              final isAdmin = team.createdBy == memberId;

              return Container(
                height: 90,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : kAppBlueCard,
                  borderRadius: BorderRadius.circular(8),
                  border: isAdmin
                      ? Border.all(color: kAppGreenBright, width: 2)
                      : null,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : const AssetImage('lib/images/sample_player.jpeg') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            playerName,
                            style: kCardTitleStyle.copyWith(
                              color: isDark ? Colors.white : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAdmin ? 'Admin' : 'Member',
                            style: TextStyle(
                              color: isAdmin ? kAppGreenBright : (isDark ? Colors.white70 : Colors.white70),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Show remove button only for non-admin members and if current user is admin
                    if (currentUserId == team.createdBy && !isAdmin)
                      GestureDetector(
                        onTap: () => _removeMember(context, team.id, memberId, teamService),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: kAppRed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Remove',
                            style: kPillTextStyle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ]
      ],
    );
  }

  Future<void> _removeMember(BuildContext context, String teamId, String memberId, TeamService teamService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member?'),
        content: const Text('Are you sure you want to remove this member from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await teamService.leaveTeam(teamId, memberId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Member removed from team'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _CircleIconButton extends StatelessWidget {
  final Color background;
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.background,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
