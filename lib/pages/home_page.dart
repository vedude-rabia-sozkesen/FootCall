import 'package:flutter/material.dart';
import '../mixins/theme_mixin.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';
import 'package:provider/provider.dart';
import '../providers/setting_provider.dart';
import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FootCall Home'),
        backgroundColor: kAppGreen,
        foregroundColor: Colors.white,
        actions: [
          // Theme Toggle
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              final isDark = settings.isDarkMode;
              return IconButton(
                onPressed: settings.toggleTheme,
                icon: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: isDark ? Colors.black : Colors.white,
                ),
              );
            },
          ),
          // Logout Button
          IconButton(
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Transform.scale(
                scale: 1.3,
                child: Image.asset(
                  'lib/images/bg_pattern.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const _HomeHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _NextMatchSection(),
                        SizedBox(height: 32),
                        _PreviousMatchesSection(),
                        SizedBox(height: 32),
                        _MyTeamSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 0),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: const BoxDecoration(
        color: kAppGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white,
            backgroundImage:
            const AssetImage('lib/images/sample_player.jpeg'),
            onBackgroundImageError: (_, __) {},
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Welcome\nDani Martinez',
              style: kHeaderTextStyle.copyWith(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextMatchSection extends StatelessWidget {
  const _NextMatchSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Next Match',
          style: TextStyle(
            color: kAppGreen,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: kAppGreenLight,
            borderRadius: BorderRadius.circular(60),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const _MatchInfoCell(text: 'Ankara/Polatlı'),
              _VerticalDivider(),
              const _MatchInfoCell(text: 'Lions - Birds'),
              _VerticalDivider(),
              const _MatchInfoCell(text: '12.00–14.00'),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchInfoCell extends StatelessWidget {
  final String text;
  const _MatchInfoCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5,
      height: 60,
      color: Colors.black.withValues(alpha: 0.25),
    );
  }
}

class _PreviousMatchesSection extends StatelessWidget {
  const _PreviousMatchesSection();

  @override
  Widget build(BuildContext context) {
    final scores = const [
      _ScoreBubble(score: '3–1', dotColor: Colors.red),
      _ScoreBubble(score: '0–0', dotColor: Colors.blue),
      _ScoreBubble(score: '1–2', dotColor: Colors.green),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Previous Matches',
          style: TextStyle(
            color: kAppGreen,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: kAppGreenLight,
            borderRadius: BorderRadius.circular(90),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: scores,
          ),
        ),
      ],
    );
  }
}

class _ScoreBubble extends StatelessWidget {
  final String score;
  final Color dotColor;
  const _ScoreBubble({required this.score, required this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            score,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _MyTeamSection extends StatelessWidget {
  const _MyTeamSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Team',
          style: TextStyle(
            color: kAppGreen,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 14),

        Container(
          decoration: BoxDecoration(
            color: kAppBlueCard,
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'lib/images/team_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(
                child: Text(
                  'Eagles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Container(
          decoration: BoxDecoration(
            color: kAppBlueCard,
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                backgroundImage:
                const AssetImage('lib/images/sample_player.jpeg'),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Team Captain',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Jonathan Patterson',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Spacer(),
                        Text(
                          'Likes ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '17',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 18),
                        Text(
                          'Dislikes ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '23',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
