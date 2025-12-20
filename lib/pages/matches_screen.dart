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
    final bool isAdmin = true; 

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E2235) : const Color(0xFFF2F4FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: _MatchesHeader(
                onFilterTap: () { /* Filter logic can be re-added here */ },
              ),
            ),
            Container(
              color: const Color(0xFFCBD8FF),
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
                vertical: 12,
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: Text('location', style: TextStyle(color: Color(0xFF4B5775), fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text('team name(s)', style: TextStyle(color: Color(0xFF4B5775), fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: Text('time', style: TextStyle(color: Color(0xFF4B5775), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kSmallPadding),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _matchService.getMatches(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No matches available',
                      ),
                    );
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

class _CreateMatchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        children: [
          const Text('Create Match', style: kCardTitleStyle),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateMatchRequestPage()));
            },
            child: const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFF87C56C),
              child: Icon(Icons.add, color: Colors.white, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}


class _MatchesHeader extends StatelessWidget {
  final VoidCallback onFilterTap;

  const _MatchesHeader({required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: settings.isDarkMode
              ? const [Color(0xFF41465A), Color(0xFF2C3144)]
              : const [Color(0xFF6E7FB6), Color(0xFF4F5F9E)],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [
          Center(
            child: Text('Matches', style: kCardTitleStyle.copyWith(fontSize: 18)),
          ),
          Positioned(
            top: 4,
            right: 8,
            child: IconButton(
              onPressed: settings.toggleTheme,
              icon: Icon(
                settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: settings.isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ),
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

    final teamAId = matchData['teamA_id'];
    final teamBId = matchData['teamB_id'];
    final location = matchData['location'] ?? 'N/A';
    final timestamp = matchData['matchDate'] as Timestamp?;
    final date = timestamp != null 
        ? DateFormat('HH:mm').format(timestamp.toDate()) 
        : 'N/A';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/match-info', arguments: matchDoc.id);
      },
      child: Container(
        width: double.infinity,
        color: context.watch<SettingsProvider>().isDarkMode
            ? const Color(0xFF2A3150)
            : const Color(0xFF6B79A6),
        padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                location,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<TeamModel?>>(
                future: Future.wait([teamService.getTeam(teamAId), teamService.getTeam(teamBId)]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text('Loading...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600));
                  }
                  final teamA = snapshot.data![0];
                  final teamB = snapshot.data![1];
                  final teamAName = teamA?.name ?? 'Team A';
                  final teamBName = teamB?.name ?? 'Team B';

                  return Row(
                    children: [
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '$teamAName vs $teamBName',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  date,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
