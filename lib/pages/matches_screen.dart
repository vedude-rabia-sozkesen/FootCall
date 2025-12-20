import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../services/match_service.dart';
import '../services/team_service.dart';
import '../models/team_model.dart';
import '../providers/setting_provider.dart';
import '../pages/create_match_request_page.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final MatchService _matchService = MatchService();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final bool isAdmin = true; // Placeholder for admin check

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
              child: StreamBuilder<QuerySnapshot>(
                stream: _matchService.getMatches(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No matches available'));
                  }

                  final matches = snapshot.data!.docs;

                  return ListView.separated(
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: kSmallPadding),
                    itemBuilder: (context, index) {
                      final matchDoc = matches[index];
                      return _MatchListTile(matchDoc: matchDoc);
                    },
                  );
                },
              ),
            ),
            if (isAdmin) _CreateMatchButton(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
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
          Center(child: Text('Matches', style: kCardTitleStyle.copyWith(fontSize: 18))),
          Positioned(top: 4, right: 8, child: IconButton(
            onPressed: settings.toggleTheme,
            icon: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: settings.isDarkMode ? Colors.black : Colors.white),
          )),
        ],
      ),
    );
  }
}

class _MatchListTile extends StatelessWidget {
  final QueryDocumentSnapshot matchDoc;
  const _MatchListTile({required this.matchDoc});

  @override
  Widget build(BuildContext context) {
    final matchData = matchDoc.data() as Map<String, dynamic>;
    final teamService = TeamService();
    final matchService = MatchService();

    final teamAId = matchData['teamA_id'];
    final teamBId = matchData['teamB_id'];
    final status = matchData['status'] ?? 'pending';
    final timestamp = matchData['matchDate'] as Timestamp?;
    final date = timestamp != null ? DateFormat('dd/MM HH:mm').format(timestamp.toDate()) : 'N/A';
    final scoreA = matchData['scoreA'];
    final scoreB = matchData['scoreB'];
    final result = (status == 'completed' && scoreA != null && scoreB != null) ? '$scoreA - $scoreB' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 16.0),
      color: context.watch<SettingsProvider>().isDarkMode ? const Color(0xFF2A3150) : const Color(0xFF6B79A6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: FutureBuilder<List<TeamModel?>>(
              future: Future.wait([teamService.getTeam(teamAId), teamService.getTeam(teamBId)]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13));
                final teamA = snapshot.data![0];
                final teamB = snapshot.data![1];
                return Text('${teamA?.name ?? 'Team A'} vs ${teamB?.name ?? 'Team B'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis);
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(date, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: Text(result, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Flexible(child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis)),
                 const SizedBox(width: 4),
                 if (status == 'scheduled')
                  SizedBox(
                    width: 22,
                    child: IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.play_circle, color: Colors.white, semanticLabel: 'Mark as Played'),
                      onPressed: () => FirebaseFirestore.instance.collection('matches').doc(matchDoc.id).update({'status': 'played'}),
                    ),
                  ),
                if (status == 'played' || status == 'completed')
                  SizedBox(
                    width: 22,
                    child: IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.scoreboard, color: Colors.white, semanticLabel: 'Enter Score'),
                      onPressed: () => _showScoreDialog(context, matchDoc.id, teamService, teamAId, teamBId, matchService),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showScoreDialog(BuildContext context, String matchId, TeamService teamService, String teamAId, String teamBId, MatchService matchService) async {
    final teamA = await teamService.getTeam(teamAId);
    final teamB = await teamService.getTeam(teamBId);
    final scoreAController = TextEditingController();
    final scoreBController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Final Score'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: scoreAController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: teamA?.name ?? 'Team A'),
                validator: (value) => value == null || value.isEmpty ? 'Enter score' : null,
              ),
              TextFormField(
                controller: scoreBController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: teamB?.name ?? 'Team B'),
                validator: (value) => value == null || value.isEmpty ? 'Enter score' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final scoreA = int.parse(scoreAController.text);
                final scoreB = int.parse(scoreBController.text);
                try {
                  await matchService.updateMatchResult(matchId: matchId, scoreA: scoreA, scoreB: scoreB);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Match result updated!'), backgroundColor: Colors.green));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
