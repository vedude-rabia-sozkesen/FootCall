import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/request_repository.dart';
import '../models/team_request.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';

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
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🔥 Güncellenmiş ÜST BAR
            _PlayerRequestsTopBar(),

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
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No team requests yet. Join a match as an admin to send one.',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.grey,
                              ),
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

// 🔥 Güncellenmiş ÜST BAR Widget
class _PlayerRequestsTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Container(
      width: double.infinity,
      height: 80,
      color: isDark ? Colors.grey[850] : kAppGreen,
      child: Stack(
        children: [
          Center(
            child: Text(
              'Player Requests',
              style: kHeaderTextStyle.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  final isDarkMode = settings.isDarkMode;
                  return Material(
                    color: isDarkMode ? Colors.grey[300] : Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: settings.toggleTheme,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: isDarkMode ? Colors.black : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Text(
      text,
      style: kSectionTitleStyle.copyWith(
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}

class _TeamRequestCard extends StatelessWidget {
  const _TeamRequestCard({required this.request});
  final TeamRequest request;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : kAppBlueCard,
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
                  style: kCardTitleStyle.copyWith(
                    color: isDark ? Colors.white : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.matchTitle,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.white70,
                    fontSize: 12,
                  ),
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

class _TeamResponseCard extends StatelessWidget {
  final String statusText;
  final Color statusColor;

  const _TeamResponseCard({
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : kAppBlueCard,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          image: AssetImage('lib/images/team_logo.png'),
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
