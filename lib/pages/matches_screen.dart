import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../providers/matches_provider.dart';
import '../providers/teams_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../models/team_model.dart';
import '../providers/setting_provider.dart';
import '../pages/create_match_request_page.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final matchesProvider = context.watch<MatchesProvider>();
    final authProvider = context.watch<app_auth.AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E2235) : const Color(0xFFF2F4FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: _MatchesHeader(),
            ),
            _ListHeader(),
            const SizedBox(height: kSmallPadding),
            Expanded(
              child: _buildMatchesList(matchesProvider, user?.uid),
            ),
            if (user != null) _CreateMatchButton(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }

  Widget _buildMatchesList(MatchesProvider matchesProvider, String? userId) {
    if (matchesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (matchesProvider.error != null) {
      return Center(child: Text('Error: ${matchesProvider.error}'));
    }
    
    if (matchesProvider.matches.isEmpty) {
      return const Center(child: Text('No matches available'));
    }

    return ListView.separated(
      itemCount: matchesProvider.matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: kSmallPadding),
      itemBuilder: (context, index) {
        final matchDoc = matchesProvider.matches[index];
        return _MatchListTile(matchDoc: matchDoc, userId: userId);
      },
    );
  }
}

class _ListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFCBD8FF),
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 12,
      ),
      child: Row(
        children: const [
          Expanded(flex: 4, child: Text('TEAMS', style: TextStyle(color: Color(0xFF4B5775), fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Text('TIME', style: TextStyle(color: Color(0xFF4B5775), fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('RESULT', style: TextStyle(color: Color(0xFF4B5775), fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
          Expanded(flex: 4, child: Text('STATUS/ACTIONS', style: TextStyle(color: Color(0xFF4B5775), fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _CreateMatchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        children: [
          Text(
            'Create Match',
            style: kCardTitleStyle.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateMatchRequestPage())),
            child: const CircleAvatar(radius: 36, backgroundColor: Color(0xFF87C56C), child: Icon(Icons.add, color: Colors.white, size: 36)),
          ),
        ],
      ),
    );
  }
}

class _MatchesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Container(
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: settings.isDarkMode ? [const Color(0xFF41465A), const Color(0xFF2C3144)] : [const Color(0xFF6E7FB6), const Color(0xFF4F5F9E)],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 4,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          Center(child: Text('Matches', style: kCardTitleStyle.copyWith(fontSize: 18))),
          Positioned(top: 4, right: 8, child: IconButton(
            onPressed: settings.toggleTheme,
            icon: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.white),
          )),
        ],
      ),
    );
  }
}

class _MatchListTile extends StatelessWidget {
  final QueryDocumentSnapshot matchDoc;
  final String? userId;

  const _MatchListTile({required this.matchDoc, this.userId});

  Future<bool> _isUserAdminOfMatch(String? userId, String teamAId, String teamBId, TeamsProvider teamsProvider) async {
    if (userId == null) return false;
    
    final teamA = await teamsProvider.getTeam(teamAId);
    final teamB = await teamsProvider.getTeam(teamBId);
    
    final isAdminA = teamA?.createdBy == userId;
    final isAdminB = teamB?.createdBy == userId;
    
    return isAdminA || isAdminB;
  }

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder to get real-time updates from Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('matches').doc(matchDoc.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final matchData = snapshot.data!.data() as Map<String, dynamic>;
        final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);

        final teamAId = matchData['teamA_id'] as String?;
        final teamBId = matchData['teamB_id'] as String?;
        final status = matchData['status'] ?? 'scheduled';
        final timestamp = matchData['matchDate'] as Timestamp?;
        final date = timestamp != null ? DateFormat('dd/MM HH:mm').format(timestamp.toDate()) : 'N/A';
        final scoreA = matchData['scoreA'] as int?;
        final scoreB = matchData['scoreB'] as int?;
        
        // Map old statuses to new ones
        String displayStatus = status;
        if (status == 'pending') displayStatus = 'scheduled';
        if (status == 'completed') displayStatus = 'played';
        
        // Show score if it exists, regardless of status
        final hasScore = scoreA != null && scoreB != null;
        final result = hasScore ? '$scoreA - $scoreB' : '-';

        return InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('/match-info', arguments: matchDoc.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 16.0),
            color: context.watch<SettingsProvider>().isDarkMode ? const Color(0xFF2A3150) : const Color(0xFF6B79A6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: FutureBuilder<List<TeamModel?>>(
                    future: Future.wait([
                      teamsProvider.getTeam(teamAId ?? ''),
                      teamsProvider.getTeam(teamBId ?? ''),
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text('...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13));
                      final teamA = snapshot.data![0];
                      final teamB = snapshot.data![1];
                      return Text(
                        '${teamA?.name ?? 'Team A'} vs ${teamB?.name ?? 'Team B'}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    date,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    result,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          displayStatus.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(displayStatus),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (teamAId != null && teamBId != null)
                        GestureDetector(
                          onTap: () {}, // Stop event propagation
                          child: FutureBuilder<bool>(
                            future: _isUserAdminOfMatch(userId, teamAId, teamBId, teamsProvider),
                            builder: (context, adminSnapshot) {
                              final isAdmin = adminSnapshot.data ?? false;
                              
                              if (displayStatus == 'scheduled' && isAdmin) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.play_circle, color: Colors.white, semanticLabel: 'Mark as Played'),
                                      onPressed: () => _markAsPlayed(context, matchDoc.id),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.cancel, color: Colors.red, semanticLabel: 'Cancel Match'),
                                      onPressed: () => _cancelMatch(context, matchDoc.id),
                                    ),
                                  ],
                                );
                              }
                              
                              // Score editing is only available in match info screen, not here
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.green;
      case 'played':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.white70;
    }
  }

  Future<void> _markAsPlayed(BuildContext context, String matchId) async {
    try {
      await FirebaseFirestore.instance.collection('matches').doc(matchId).update({'status': 'played'});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match marked as played'),
            backgroundColor: Colors.green,
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

  Future<void> _cancelMatch(BuildContext context, String matchId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Match?'),
        content: const Text('Are you sure you want to cancel this match?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('matches').doc(matchId).update({'status': 'canceled'});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Match canceled'),
              backgroundColor: Colors.orange,
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
