import 'package:flutter/material.dart';

import '../data/match_repository.dart';
import '../data/request_repository.dart';
import '../models/match_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
// AppBottomNavBar usage removed

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
            const MatchInfoBottomBar(),
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

// Custom Bottom Bar for Match Info Page
class MatchInfoBottomBar extends StatelessWidget {
  const MatchInfoBottomBar({super.key});

  void _showPlaceholderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Coming soon'),
        content: const Text('This navigation destination is not ready yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      decoration: const BoxDecoration(
        color: kAppGreen,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BottomItem(
            imagePath: 'lib/images/home_logo.png',
            label: 'Home',
            isActive: false,
            onTap: () => _goHome(context),
          ),
          _BottomItem(
            imagePath: 'lib/images/myteam_logo.png',
            label: 'My Team',
            isActive: false,
            onTap: () => _showPlaceholderDialog(context),
          ),
          _BottomItem(
            imagePath: 'lib/images/search_logo.png',
            label: 'Search',
            isActive: false,
            onTap: () => _showPlaceholderDialog(context),
          ),
          _BottomItem(
            imagePath: 'lib/images/myprofile_logo.png',
            label: 'MyProfile',
            isActive: false,
            onTap: () => Navigator.of(context).pushNamed('/my-player'),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomItem({
    required this.imagePath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color textColor = Colors.white;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
