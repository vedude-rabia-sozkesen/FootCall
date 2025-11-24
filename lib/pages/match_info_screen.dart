import 'package:flutter/material.dart';

import '../data/match_repository.dart';
import '../data/request_repository.dart';
import '../data/team_repository.dart';
import '../models/match_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import 'team_info_page.dart';

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
            // Back button
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: kDefaultPadding),
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
                                    builder: (_) => TeamInfoPage(team: team),
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
                              final matchRepo = MatchRepository.instance;
                              final requestRepo = RequestRepository.instance;
                              // Get admin status from user profile (currently using placeholder)
                              final bool isAdmin = matchRepo.isAdmin;
                              
                              if (isAdmin) {
                                // Admin joining: send team request to the admin who created the match
                                requestRepo.addTeamRequestForCreator(match, match.creatorName);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Team join request sent to ${match.creatorName}.',
                                    ),
                                  ),
                                );
                              } else {
                                // Non-admin joining: send player request to the admin who created the match
                                requestRepo.addPlayerRequestForCreator(match, match.creatorName);
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

  String _getLocationDisplay() {
    // Remove city/district from location if it's already in cityDistrict
    String location = match.location;
    final cityDistrict = match.cityDistrict;
    
    // Check if location contains city/district info and remove duplicates
    final parts = cityDistrict.split('/');
    if (parts.length == 2) {
      final city = parts[0].trim();
      final district = parts[1].trim();
      
      // Remove city and district from location if they appear
      location = location.replaceAll(city, '').replaceAll(district, '');
      location = location.replaceAll(RegExp(r'[/,]+'), '').trim();
      location = location.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      // Clean up any trailing commas or slashes
      location = location.replaceAll(RegExp(r'^[,/\s]+|[,/\s]+$'), '');
    }
    
    // If location is empty after cleaning, just show the original
    if (location.isEmpty) {
      location = match.location;
    }
    
    // Add city/district at the end without a new line
    return '$location, $cityDistrict';
  }

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
            value: _getLocationDisplay(),
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

// Custom Bottom Bar for Match Info Screen (same as Matches Screen)
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
    Navigator.of(context).pushNamedAndRemoveUntil('/matches', (route) => false);
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
            onTap: () => _showPlaceholderDialog(context),
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
