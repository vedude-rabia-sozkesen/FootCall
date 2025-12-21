import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/auth_provider.dart' as app_auth;
import '../services/auth_service.dart';
import '../services/match_service.dart';
import '../services/team_service.dart';
import '../models/team_model.dart';
import '../providers/setting_provider.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

class PlayerInfoScreen extends StatelessWidget {
  const PlayerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playerId = ModalRoute.of(context)!.settings.arguments as String;
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      appBar: AppBar(title: const Text("Player Info")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('players').doc(playerId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final playerData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _ProfileHeader(playerData: playerData),
                const SizedBox(height: 24),
                _PlayerInfoCard(playerData: playerData, playerId: playerId),
                const SizedBox(height: 24),
                _PreviousMatchesSection(playerTeamId: playerData['currentTeamId']),
                const SizedBox(height: 24),
                _ActionButtons(playerData: playerData, playerId: playerId),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 3),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> playerData;
  const _ProfileHeader({required this.playerData});

  @override
  Widget build(BuildContext context) {
    final photoUrl = playerData['photoUrl'] as String?;
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) 
              ? NetworkImage(photoUrl) 
              : const AssetImage('lib/images/sample_player.jpeg') as ImageProvider,
        ),
        const SizedBox(height: 12),
        const Text("Player Info", style: kHeaderTextStyle),
      ],
    );
  }
}

class _PlayerInfoCard extends StatelessWidget {
  final Map<String, dynamic> playerData;
  final String playerId;
  const _PlayerInfoCard({required this.playerData, required this.playerId});

  @override
  Widget build(BuildContext context) {
    final teamId = playerData['currentTeamId'] as String?;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(playerData['name'] ?? 'N/A', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Age: ${playerData['age'] ?? 'N/A'}"),
                Text("Position: ${playerData['position'] ?? 'N/A'}"),
              ],
            ),
            const SizedBox(height: 4),
            Text("ID: ${playerData['id'] ?? 'N/A'}", style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            // Team Info
            FutureBuilder<TeamModel?>(
              future: teamId != null ? TeamService().getTeam(teamId!) : Future.value(null),
              builder: (context, snapshot) {
                final teamName = snapshot.hasData && snapshot.data != null 
                    ? snapshot.data!.name 
                    : 'Not in a team';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: teamId != null ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Team Info: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        teamName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: teamId != null ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviousMatchesSection extends StatelessWidget {
  final String? playerTeamId;
  const _PreviousMatchesSection({this.playerTeamId});

  @override
  Widget build(BuildContext context) {
    final matchService = MatchService();
    final List<String> teamIds = playerTeamId != null ? [playerTeamId!] : [];

    return Column(
      children: [
        const Text("Previous Matches"),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot>(
          stream: matchService.getPreviousMatchesStream(teamIds, limit: 3),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("No recent matches.");
            }
            final matches = snapshot.data!.docs;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: matches.map((doc) {
                 final data = doc.data() as Map<String, dynamic>;
                 final scoreA = data['scoreA'] ?? 0;
                 final scoreB = data['scoreB'] ?? 0;
                 return Chip(label: Text('$scoreA - $scoreB'));
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Map<String, dynamic> playerData;
  final String playerId;
  const _ActionButtons({required this.playerData, required this.playerId});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    final voters = Map<String, bool>.from(playerData['voters'] ?? {});
    final hasVoted = voters.containsKey(currentUser.uid);
    final currentVote = hasVoted ? voters[currentUser.uid] : null;

    return Column(
      children: [
        _buildPlusButton(context, currentUser.uid),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                IconButton(
                  onPressed: () async {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.likeDislikePlayer(playerId, isLike: true);
                  },
                  icon: Icon(Icons.thumb_up, color: currentVote == true ? Colors.green : Colors.grey),
                ),
                Text("Likes: ${playerData['likes'] ?? 0}"),
              ],
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () async {
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.likeDislikePlayer(playerId, isLike: false);
                  },
                  icon: Icon(Icons.thumb_down, color: currentVote == false ? Colors.red : Colors.grey),
                ),
                Text("Dislikes: ${playerData['dislikes'] ?? 0}"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlusButton(BuildContext context, String currentUserId) {
    final viewedPlayerTeamId = playerData['currentTeamId'] as String?;
    
    // Hide button if viewed player is already in a team
    if (viewedPlayerTeamId != null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('players').doc(currentUserId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final adminPlayerData = snapshot.data!.data() as Map<String, dynamic>;
        final adminTeamId = adminPlayerData['currentTeamId'] as String?;

        if (adminTeamId == null) {
          // Hide if admin is not in a team
          return const SizedBox.shrink();
        }

        return FutureBuilder<TeamModel?>(
          future: TeamService().getTeam(adminTeamId),
          builder: (context, teamSnapshot) {
            if (!teamSnapshot.hasData) return const SizedBox.shrink();
            
            final team = teamSnapshot.data!;
            final bool isUserAdmin = team.createdBy == currentUserId;
            
            if (!isUserAdmin) {
              return const SizedBox.shrink();
            }

            // Check if request already sent
            return FutureBuilder<bool>(
              future: TeamService().hasPendingRequestToPlayer(
                teamId: adminTeamId,
                playerId: playerId,
              ),
              builder: (context, requestSnapshot) {
                final hasRequest = requestSnapshot.data ?? false;
                
                if (hasRequest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Request sent to player',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return FloatingActionButton(
                  onPressed: () => _sendTeamRequest(context, adminTeamId, currentUserId),
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _sendTeamRequest(BuildContext context, String teamId, String requestedBy) async {
    try {
      final teamService = TeamService();
      await teamService.sendTeamJoinRequestToPlayer(
        teamId: teamId,
        playerId: playerId,
        requestedBy: requestedBy,
      );

      // Show success notification
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Request sent to player'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Show error notification
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
