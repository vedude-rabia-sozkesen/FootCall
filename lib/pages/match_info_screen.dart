import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../mixins/theme_mixin.dart';
import '../data/match_repository.dart';
import '../data/request_repository.dart';
import '../data/team_repository.dart';
import '../models/match_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import '../providers/setting_provider.dart';
import 'team_info_page.dart';
import '../widgets/app_bottom_nav.dart';

class MatchInfoScreen extends StatelessWidget with ThemeMixin {
  const MatchInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MatchModel match =
    ModalRoute.of(context)!.settings.arguments as MatchModel;

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDark = settings.isDarkMode;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : const Color(0xFFC9DAF3),

          appBar: AppBar(
            title: const Text('Match Info'),
            backgroundColor: isDark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFF1E2235),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: true,
            actions: [
              IconButton(
                onPressed: settings.toggleTheme,
                icon: Icon(
                  settings.isDarkMode
                      ? Icons.dark_mode    // Dark → AY
                      : Icons.light_mode,  // Light → GÜNEŞ
                  color: settings.isDarkMode
                      ? Colors.black       // Dark mode → siyah ay
                      : Colors.white,      // Light mode → beyaz güneş
                ),
              ),
            ],
          ),


          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: kDefaultPadding),

                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFF1E2235),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.all(kDefaultPadding),
                          child: Column(
                            children: [
                              Container(
                                height: 96,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? const [
                                      Color(0xFF3A3A3A),
                                      Color(0xFF1F1F1F),
                                    ]
                                        : const [
                                      Color(0xFF5A637A),
                                      Color(0xFF2A2F40),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(32),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Match Info',
                                    style: kCardTitleStyle.copyWith(
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: kDefaultPadding * 1.5),

                              _InfoCard(
                                match: match,
                                isDark: isDark,
                              ),

                              const SizedBox(height: kDefaultPadding),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    isDark ? kAppGreen : const Color(0xFF778BB4),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                  ),
                                  onPressed: () {
                                    final team = TeamRepository.instance
                                        .findByName(match.playingTeam);

                                    if (team == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'No team info found for ${match.playingTeam}.',
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            TeamInfoPage(team: team),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'View Team Info',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: kDefaultPadding),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7FBD63),
                                  foregroundColor: Colors.white,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                  shape: const CircleBorder(),
                                ),
                                onPressed: () {
                                  final matchRepo =
                                      MatchRepository.instance;
                                  final requestRepo =
                                      RequestRepository.instance;
                                  final bool isAdmin =
                                      matchRepo.isAdmin;

                                  if (isAdmin) {
                                    requestRepo.addTeamRequestForCreator(
                                      match,
                                      match.creatorName,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Team join request sent to ${match.creatorName}.',
                                        ),
                                      ),
                                    );
                                  } else {
                                    requestRepo.addPlayerRequestForCreator(
                                      match,
                                      match.creatorName,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Player request sent to ${match.creatorName}\'s admin panel.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'Join*',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: kSmallPadding),

                              Text(
                                '*This functionality means joining as a team for admins and joining as a player for players',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.white70,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.match,
    required this.isDark,
  });

  final MatchModel match;
  final bool isDark;

  String _getLocationDisplay() {
    String location = match.location;
    final cityDistrict = match.cityDistrict;

    final parts = cityDistrict.split('/');
    if (parts.length == 2) {
      final city = parts[0].trim();
      final district = parts[1].trim();

      location = location.replaceAll(city, '').replaceAll(district, '');
      location = location.replaceAll(RegExp(r'[/,]+'), '').trim();
      location = location.replaceAll(RegExp(r'\s+'), ' ').trim();
      location =
          location.replaceAll(RegExp(r'^[,/\s]+|[,/\s]+$'), '');
    }

    if (location.isEmpty) {
      location = match.location;
    }

    return '$location, $cityDistrict';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFF2D344C),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Time', value: match.timeRange),
          const SizedBox(height: kSmallPadding),
          _InfoRow(label: 'Location', value: _getLocationDisplay()),
          const SizedBox(height: kSmallPadding),
          _InfoRow(label: 'Playing Team', value: match.playingTeam),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }
}
