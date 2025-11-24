import 'package:flutter/material.dart';

import '../data/match_repository.dart';
import '../data/request_repository.dart';
import '../models/match_model.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

class MatchInfoScreen extends StatelessWidget {
  const MatchInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MatchModel match =
        ModalRoute.of(context)!.settings.arguments as MatchModel;

    return Scaffold(
      backgroundColor: const Color(0xFFC9DAF3),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: kDefaultPadding * 1.5),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2235),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: Column(
                        children: [
                          Container(
                            height: 96,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF5A637A), Color(0xFF2A2F40)],
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(32)),
                            ),
                            child: Center(
                              child: Text(
                                'Match Info',
                                style: kCardTitleStyle.copyWith(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: kDefaultPadding * 1.5),
                          _InfoCard(match: match),
                          const SizedBox(height: kDefaultPadding),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF778BB4),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              onPressed: () {
                                // to be filled: navigate to team info page
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
                              final matchRepo = MatchRepository.instance;
                              final requestRepo = RequestRepository.instance;
                              final bool isAdmin = matchRepo.isAdmin;
                              if (isAdmin) {
                                requestRepo.addTeamRequest(match);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Team join request sent to admin.'),
                                  ),
                                );
                              } else {
                                requestRepo.addPlayerRequest(match);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Player request sent to admin panel.'),
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
                          const Text(
                            '*This functionality means joining as a team for admins and joining as a player for players',
                            style: TextStyle(
                              color: Colors.white70,
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
            const AppBottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF2D344C),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Time',
            value: match.timeRange,
          ),
          const SizedBox(height: kSmallPadding),
          _InfoRow(
            label: 'Location',
            value: '${match.location}, ${match.cityDistrict}',
          ),
          const SizedBox(height: kSmallPadding),
          _InfoRow(
            label: 'Playing Team',
            value: match.playingTeam,
          ),
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

