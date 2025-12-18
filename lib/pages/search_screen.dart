import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[100];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBarWithTheme(),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _SearchActionButton(
                    label: 'List Teams',
                    onTap: () {
                      Navigator.of(context).pushNamed('/teams');
                    },
                  ),
                  const SizedBox(height: 12),
                  _SearchActionButton(
                    label: 'List Matches',
                    onTap: () {
                      Navigator.of(context).pushNamed('/matches');
                    },
                  ),
                  const SizedBox(height: 12),
                  _SearchActionButton(
                    label: 'List Players',
                    onTap: () {
                      Navigator.of(context).pushNamed('/players');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }
}

// 🔥 ÜST BAR + THEME BUTONU
class _TopBarWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Container(
      width: double.infinity,
      height: 140,
      color: isDark ? Colors.grey[850] : kAppGreen,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : kAppGreenLight,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Search team, match or player',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(Icons.search, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  // 🔥 THEME BUTTON
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: settings.toggleTheme,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: isDark ? Colors.black : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔥 ACTION BUTTON
class _SearchActionButton extends StatelessWidget {
  const _SearchActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final buttonColor = isDark ? Colors.grey[700] : kAppGreenLight;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
