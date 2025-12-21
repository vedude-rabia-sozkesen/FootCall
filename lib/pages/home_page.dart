import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../providers/auth_provider.dart' as app_auth;
import '../services/match_service.dart';
import '../services/team_service.dart';
import '../models/team_model.dart';
import '../providers/setting_provider.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(body: Center(child: Text("Not logged in.")));
        }

        return Scaffold(
          appBar: _buildAppBar(context),
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('players').doc(user.uid).snapshots(),
        builder: (context, playerSnapshot) {
          if (!playerSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final playerData = playerSnapshot.data!.data() as Map<String, dynamic>;
          final teamId = playerData['currentTeamId'] as String?;

          return Stack(
            children: [
              Positioned.fill(
                child: Opacity(opacity: 0.15, child: Transform.scale(scale: 1.3, child: Image.asset('lib/images/bg_pattern.png', fit: BoxFit.cover))),
              ),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  children: [
                    _HomeHeader(playerData: playerData),
                    const SizedBox(height: 24),
                    _NextMatchSection(teamId: teamId),
                    const SizedBox(height: 32),
                    _PreviousMatchesSection(teamId: teamId),
                    const SizedBox(height: 32),
                    _MyTeamSection(teamId: teamId),
                  ],
                ),
              ),
            ],
          );
          },
        ),
        bottomNavigationBar: const AppBottomNavBar(activeIndex: 0),
      );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('FootCall Home'),
      backgroundColor: kAppGreen,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: () => context.read<SettingsProvider>().toggleTheme(),
          icon: Icon(
            context.watch<SettingsProvider>().isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: context.watch<SettingsProvider>().isDarkMode ? Colors.black : Colors.white,
          ),
        ),
        IconButton(
          onPressed: () async {
            final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
            await authProvider.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          },
          icon: const Icon(Icons.logout),
          tooltip: 'Log Out',
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final Map<String, dynamic> playerData;
  const _HomeHeader({required this.playerData});

  @override
  Widget build(BuildContext context) {
    final name = playerData['name'] ?? 'Player';
    final photoUrl = playerData['photoUrl'] as String?;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.white,
          backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : const AssetImage('lib/images/sample_player.jpeg') as ImageProvider,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text('Welcome, $name!', style: const TextStyle(color: kAppGreen, fontSize: 22, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _NextMatchSection extends StatelessWidget {
  final String? teamId;
  const _NextMatchSection({this.teamId});

  @override
  Widget build(BuildContext context) {
    final matchService = MatchService();
    final List<String> teamIds = teamId != null ? [teamId!] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Next Match', style: TextStyle(color: kAppGreen, fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot>(
           stream: matchService.getNextMatchStream(teamIds).handleError((error) {
            developer.log("----------- KINGO, NEXT MATCH HATASI BU, LİNKE TIKLA: ${error.toString()} -----------");
          }),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
               return const _EmptyStateCard(message: 'Error loading next match.');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const _EmptyStateCard(message: 'No match scheduled');
            }
            final matchData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            final location = matchData['location'] ?? 'N/A';
            final timestamp = matchData['matchDate'] as Timestamp;
            final time = DateFormat('HH:mm').format(timestamp.toDate());

            return FutureBuilder<List<TeamModel?>>(
              future: Future.wait([TeamService().getTeam(matchData['teamA_id']), TeamService().getTeam(matchData['teamB_id'])]),
              builder: (context, teamSnapshot) {
                final teamA = teamSnapshot.data?.first;
                final teamB = teamSnapshot.data?.last;
                final teams = '${teamA?.name ?? '...'} vs ${teamB?.name ?? '...'}';

                return Container(
                  height: 70,
                  decoration: BoxDecoration(color: kAppGreenLight, borderRadius: BorderRadius.circular(60)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(child: Text(location, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                      const VerticalDivider(),
                      Expanded(child: Text(teams, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                      const VerticalDivider(),
                      Expanded(child: Text(time, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _PreviousMatchesSection extends StatelessWidget {
  final String? teamId;
  const _PreviousMatchesSection({this.teamId});

  @override
  Widget build(BuildContext context) {
    final matchService = MatchService();
    final List<String> teamIds = teamId != null ? [teamId!] : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Previous Matches', style: TextStyle(color: kAppGreen, fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot>(
          stream: matchService.getPreviousMatchesStream(teamIds, limit: 3),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const _EmptyStateCard(message: 'No match played yet');
            }
            final matches = snapshot.data!.docs;
            return Container(
              height: 110,
              decoration: BoxDecoration(color: kAppGreenLight, borderRadius: BorderRadius.circular(90)),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: matches.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final scoreA = data['scoreA'] ?? 0;
                  final scoreB = data['scoreB'] ?? 0;
                  final teamAId = data['teamA_id'];
                  
                  Color resultColor = Colors.blue; // Draw
                  if(scoreA != scoreB){
                     bool isWinner = (teamAId == teamId && scoreA > scoreB) || (teamAId != teamId && scoreB > scoreA);
                     resultColor = isWinner ? Colors.green : Colors.red;
                  }

                  return _ScoreBubble(score: '$scoreA–$scoreB', color: resultColor);
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MyTeamSection extends StatelessWidget {
  final String? teamId;
  const _MyTeamSection({this.teamId});

  @override
  Widget build(BuildContext context) {
    if (teamId == null) {
      return const _EmptyStateCard(message: 'You are not in a team');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Team', style: TextStyle(color: kAppGreen, fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 14),
        FutureBuilder<TeamModel?>(
          future: TeamService().getTeam(teamId!),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const _EmptyStateCard(message: 'Loading team...');
            }
            final team = snapshot.data!;
            return GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/my-team'),
              child: Container(
                decoration: BoxDecoration(color: kAppBlueCard, borderRadius: BorderRadius.circular(28)),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(width: 60, height: 60, color: Colors.white, child: team.logoUrl.isNotEmpty ? Image.network(team.logoUrl) : Image.asset('lib/images/team_logo.png')),
                    const SizedBox(width: 20),
                    Text(team.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}


class _ScoreBubble extends StatelessWidget {
  final String score;
  final Color color;
  const _ScoreBubble({required this.score, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 50,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(score, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        CircleAvatar(radius: 5, backgroundColor: color),
      ],
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String message;
  const _EmptyStateCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(child: Text(message, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16))),
    );
  }
}
