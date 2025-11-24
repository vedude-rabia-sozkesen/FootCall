import 'package:flutter/material.dart';
import '../data/request_repository.dart';
import '../models/team_request.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

void _showNotImplemented(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Not implemented'),
      content: const Text('This feature is not implemented yet.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class PlayerRequestsScreen extends StatelessWidget {
  const PlayerRequestsScreen({super.key});

  RequestRepository get _repo => RequestRepository.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: kAppGreen,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 24,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: kAppGreenLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Text(
                        'Requests',
                        style: kHeaderTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Team Requests'),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<List<TeamRequest>>(
                      valueListenable: _repo.teamRequestsNotifier,
                      builder: (context, requests, _) {
                        if (requests.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No team requests yet. Join a match as an admin to send one.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            for (final req in requests) ...[
                              _TeamRequestCard(request: req),
                              const SizedBox(height: 8),
                            ]
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle('Team Responses'),
                    const SizedBox(height: 8),
                    const _TeamResponseCard(
                      statusText: 'Rejected',
                      statusColor: kAppRed,
                    ),
                    const SizedBox(height: 8),
                    const _TeamResponseCard(
                      statusText: 'Accepted',
                      statusColor: kAppGreenBright,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 3),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: kSectionTitleStyle,
    );
  }
}

/// Team Requests card – logo + "Eagles" + red X & green ✓
class _TeamRequestCard extends StatelessWidget {
  const _TeamRequestCard({required this.request});

  final TeamRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: kAppBlueCard,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _TeamLogo(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  request.teamName,
                  style: kCardTitleStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  request.matchTitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CircleIconButton(
                background: kAppRed,
                icon: Icons.close,
                onPressed: () => _showNotImplemented(context),
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                background: kAppGreenBright,
                icon: Icons.check,
                onPressed: () => _showNotImplemented(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Team Responses card – logo + "Eagles" + pill "Rejected"/"Accepted"
class _TeamResponseCard extends StatelessWidget {
  final String statusText;
  final Color statusColor;

  const _TeamResponseCard({
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: kAppBlueCard,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _TeamLogo(),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Eagles',
              style: kCardTitleStyle,
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: kPillTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('lib/images/team_logo.png'), // Updated path
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final Color background;
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.background,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
