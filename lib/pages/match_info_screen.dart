import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../services/match_service.dart';
import '../services/team_service.dart';
import '../models/team_model.dart';
import '../providers/setting_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

class MatchInfoScreen extends StatelessWidget {
  const MatchInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String matchId = ModalRoute.of(context)!.settings.arguments as String;
    final MatchService matchService = MatchService();
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFC9DAF3),
      appBar: AppBar(
        title: const Text('Match Info'),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFF1E2235),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => context.read<SettingsProvider>().toggleTheme(),
            icon: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: matchService.getMatchStream(matchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Match not found.'));
          }

          final matchData = snapshot.data!.data() as Map<String, dynamic>;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1E2235),
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    const SizedBox(height: kDefaultPadding * 1.5),
                    _InfoCard(matchData: matchData, isDark: isDark),
                    const SizedBox(height: kDefaultPadding),
                    // NOTE: 'View Team' & 'Join' buttons are removed for now
                    // as their logic was based on a static data model.
                    // They can be re-added with dynamic logic if needed.
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3A3A3A), const Color(0xFF1F1F1F)]
              : [const Color(0xFF5A637A), const Color(0xFF2A2F40)],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(32)),
      ),
      child: Center(
        child: Text('Match Info', style: kCardTitleStyle.copyWith(fontSize: 24)),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> matchData;
  final bool isDark;

  const _InfoCard({required this.matchData, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    final teamAId = matchData['teamA_id'];
    final teamBId = matchData['teamB_id'];
    final location = matchData['location'] ?? 'N/A';
    final timestamp = matchData['matchDate'] as Timestamp?;
    final date = timestamp != null
        ? DateFormat('dd/MM/yyyy - HH:mm').format(timestamp.toDate())
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF2D344C),
        borderRadius: BorderRadius.circular(32),
      ),
      child: FutureBuilder<List<TeamModel?>>(
        future: Future.wait([teamService.getTeam(teamAId), teamService.getTeam(teamBId)]),
        builder: (context, snapshot) {
          final teamA = snapshot.data?.isNotEmpty == true ? snapshot.data![0] : null;
          final teamB = snapshot.data?.length == 2 ? snapshot.data![1] : null;

          return Column(
            children: [
              _InfoRow(label: 'Teams', value: '${teamA?.name ?? '...'} vs ${teamB?.name ?? '...'}'),
              const SizedBox(height: kSmallPadding),
              _InfoRow(label: 'Time', value: date),
              const SizedBox(height: kSmallPadding),
              _InfoRow(label: 'Location', value: location),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }
}
