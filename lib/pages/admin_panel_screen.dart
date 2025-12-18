import 'package:flutter/material.dart';
import 'package:provider/provider.dart';                     // ✅ Consumer için
import '../providers/setting_provider.dart';                // ✅ SettingsProvider
import '../data/request_repository.dart';
import '../models/player_join_request.dart';
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

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  RequestRepository get _repo => RequestRepository.instance;

  @override
  Widget build(BuildContext context) {
    // 🔹 Consumer ile SettingsProvider alıyoruz
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDark = settings.isDarkMode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Panel'),
            backgroundColor: isDark ? const Color(0xFF2D2D2D) : kAppGreen,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  settings.toggleTheme(); // ✅ Buton tema değiştiriyor
                },
                icon: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Player Requests'),
                        const SizedBox(height: 8),
                        ValueListenableBuilder<List<PlayerJoinRequest>>(
                          valueListenable: _repo.playerRequestsNotifier,
                          builder: (context, requests, _) {
                            if (requests.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'No player requests yet. When players join your match, they will appear here.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }
                            return Column(
                              children: [
                                for (final req in requests) ...[
                                  _PlayerRequestCard(request: req),
                                  const SizedBox(height: 12),
                                ]
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const _SectionTitle('Player Responses'),
                        const SizedBox(height: 8),
                        const _PlayerResponsesCard(),
                        const SizedBox(height: 24),
                        const _SectionTitle('Manage Team'),
                        const SizedBox(height: 8),
                        const _ManageTeamCard(highlighted: true),
                        const SizedBox(height: 8),
                        const _ManageTeamCard(highlighted: false),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNavBar(activeIndex: 3),
        );
      },
    );
  }
}

// Aşağıdaki sınıflar (_SectionTitle, _PlayerRequestCard, vb.) aynı kalıyor
// çünkü sadece AppBar’daki tema butonu mantığını değiştiriyoruz

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

class _PlayerRequestCard extends StatelessWidget {
  const _PlayerRequestCard({required this.request});

  final PlayerJoinRequest request;

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
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(
              'lib/images/sample_player.jpeg',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  request.playerName,
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

class _PlayerResponsesCard extends StatelessWidget {
  const _PlayerResponsesCard();

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
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage('lib/images/sample_player.jpeg'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Ahmet',
              style: kCardTitleStyle,
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: kAppRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Rejected',
              style: kPillTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageTeamCard extends StatelessWidget {
  final bool highlighted;

  const _ManageTeamCard({required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: kAppBlueCard,
        borderRadius: BorderRadius.circular(8),
        border: highlighted
            ? Border.all(color: kAppGreenBright, width: 3)
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage('lib/images/sample_player.jpeg'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Ahmet',
              style: kCardTitleStyle,
            ),
          ),
          GestureDetector(
            onTap: () => _showNotImplemented(context),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: kAppRed,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Remove',
                style: kPillTextStyle,
              ),
            ),
          ),
        ],
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
