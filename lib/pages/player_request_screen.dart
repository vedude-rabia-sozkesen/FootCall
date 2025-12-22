import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../services/match_request_service.dart';
import '../services/team_service.dart';
import '../services/auth_service.dart';
import '../models/team_model.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';
import '../providers/matches_provider.dart';

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

class PlayerRequestsScreen extends StatelessWidget {
  const PlayerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('players').doc(user.uid).snapshots(),
          builder: (context, playerSnapshot) {
            if (!playerSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final playerData = playerSnapshot.data!.data() as Map<String, dynamic>?;
            final teamId = playerData?['currentTeamId'] as String?;
            
            return Column(
              children: [
                _PlayerRequestsTopBar(),
                Expanded(
                  child: teamId != null
                      ? StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('teams').doc(teamId).snapshots(),
                          builder: (context, teamSnapshot) {
                            if (!teamSnapshot.hasData || !teamSnapshot.data!.exists) {
                              return _RegularUserRequestsView(userId: user.uid);
                            }
                            
                            final team = TeamModel.fromFirestore(teamSnapshot.data!);
                            final bool isAdmin = team.createdBy == user.uid;
                            
                            // Admin sees match requests, regular users see team join requests
                            return isAdmin
                                ? _AdminRequestsView(teamId: teamId!)
                                : _RegularUserRequestsView(userId: user.uid);
                          },
                        )
                      : _RegularUserRequestsView(userId: user.uid),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 3),
    );
  }
}

// Admin view: Shows match requests from other teams
class _AdminRequestsView extends StatelessWidget {
  final String teamId;
  const _AdminRequestsView({required this.teamId});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final matchRequestService = MatchRequestService();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Match Requests from Other Teams'),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: matchRequestService.getPendingMatchRequestsForTeam(teamId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No match requests yet.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                  ),
                );
              }

              final requests = snapshot.data!.docs;
              return Column(
                children: [
                  for (final requestDoc in requests) ...[
                    _MatchRequestCard(requestDoc: requestDoc),
                    const SizedBox(height: 8),
                  ]
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// Regular user view: Shows team join requests
class _RegularUserRequestsView extends StatelessWidget {
  final String userId;
  const _RegularUserRequestsView({required this.userId});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Team Join Requests'),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('player_team_requests')
                .where('playerId', isEqualTo: userId)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No team join requests yet.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey,
                    ),
                  ),
                );
              }

              final requests = snapshot.data!.docs;
              return Column(
                children: [
                  for (final requestDoc in requests) ...[
                    _TeamJoinRequestCard(requestDoc: requestDoc),
                    const SizedBox(height: 8),
                  ]
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// 🔥 Güncellenmiş ÜST BAR Widget
class _PlayerRequestsTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Container(
      width: double.infinity,
      height: 80,
      color: isDark ? Colors.grey[850] : kAppGreen,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Center(
            child: Text(
              'Player Requests',
              style: kHeaderTextStyle.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  final isDarkMode = settings.isDarkMode;
                  return Material(
                    color: isDarkMode ? Colors.grey[300] : Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: settings.toggleTheme,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: isDarkMode ? Colors.black : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _MatchRequestCard extends StatelessWidget {
  final QueryDocumentSnapshot requestDoc;
  const _MatchRequestCard({required this.requestDoc});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final requestData = requestDoc.data() as Map<String, dynamic>;
    final sendingTeamId = requestData['sendingTeamId'] as String;
    final location = requestData['proposedLocation'] as String? ?? 'N/A';
    final Timestamp? timestamp = requestData['proposedMatchDate'] as Timestamp?;
    final date = timestamp != null 
        ? DateFormat('dd/MM/yyyy - HH:mm').format(timestamp.toDate())
        : 'N/A';
    final teamService = TeamService();
    final matchesProvider = Provider.of<MatchesProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : kAppBlueCard,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<TeamModel?>(
            future: teamService.getTeam(sendingTeamId),
            builder: (context, teamSnapshot) {
              final teamName = teamSnapshot.data?.name ?? 'Loading...';
              return Text(
                'From: $teamName',
                style: kCardTitleStyle.copyWith(
                  color: isDark ? Colors.white : Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text('📍 Location: $location', style: TextStyle(color: isDark ? Colors.white70 : Colors.white70)),
          const SizedBox(height: 4),
          Text('📅 Date: $date', style: TextStyle(color: isDark ? Colors.white70 : Colors.white70)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _CircleIconButton(
                background: kAppRed,
                icon: Icons.close,
                onPressed: () => _rejectMatchRequest(context, requestDoc.id),
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                background: kAppGreenBright,
                icon: Icons.check,
                onPressed: () => _acceptMatchRequest(context, requestDoc.id, matchesProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _acceptMatchRequest(BuildContext context, String requestId, MatchesProvider matchesProvider) async {
    try {
      final matchRequestService = MatchRequestService();
      await matchRequestService.acceptMatchRequest(requestId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Match created successfully!'),
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

  Future<void> _rejectMatchRequest(BuildContext context, String requestId) async {
    try {
      final matchRequestService = MatchRequestService();
      await matchRequestService.rejectMatchRequest(requestId);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match request rejected'),
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

class _TeamJoinRequestCard extends StatelessWidget {
  final QueryDocumentSnapshot requestDoc;
  const _TeamJoinRequestCard({required this.requestDoc});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final requestData = requestDoc.data() as Map<String, dynamic>;
    final teamId = requestData['teamId'] as String;
    final teamService = TeamService();
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    return FutureBuilder<TeamModel?>(
      future: teamService.getTeam(teamId),
      builder: (context, teamSnapshot) {
        if (!teamSnapshot.hasData) {
          return const SizedBox.shrink();
        }
        
        final team = teamSnapshot.data!;
        
        return Container(
          height: 90,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : kAppBlueCard,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _TeamLogo(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      team.name,
                      style: kCardTitleStyle.copyWith(
                        color: isDark ? Colors.white : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${team.city} / ${team.district}',
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
                    onPressed: () => _rejectTeamJoinRequest(context, requestDoc.id),
                  ),
                  const SizedBox(width: 8),
                  _CircleIconButton(
                    background: kAppGreenBright,
                    icon: Icons.check,
                    onPressed: userId != null 
                        ? () => _acceptTeamJoinRequest(context, requestDoc.id, teamId, userId, teamService)
                        : () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _acceptTeamJoinRequest(BuildContext context, String requestId, String teamId, String userId, TeamService teamService) async {
    try {
      // Join the team
      await teamService.joinTeam(teamId, userId);
      
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
                Text('You joined the team!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pushNamed('/my-team');
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

  Future<void> _rejectTeamJoinRequest(BuildContext context, String requestId) async {
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

class _TeamResponseCard extends StatelessWidget {
  final String statusText;
  final Color statusColor;

  const _TeamResponseCard({
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : kAppBlueCard,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _TeamLogo(),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Eagles',
              style: kCardTitleStyle,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: kPillTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('lib/images/team_logo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
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
