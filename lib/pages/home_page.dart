import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/setting_provider.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

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
          IconButton(
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              // No need to manually navigate; AuthGate handles it!
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
            backgroundImage: const AssetImage('lib/images/sample_player.jpeg'),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Welcome Back!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
        const Text('Next Match', style: TextStyle(color: kAppGreen, fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 14),
        Container(
          height: 70,
          decoration: BoxDecoration(color: kAppGreenLight, borderRadius: BorderRadius.circular(60)),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const Row(
            children: [
              Expanded(child: Text('Ankara/Polatlı', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              VerticalDivider(),
              Expanded(child: Text('Lions - Birds', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
              VerticalDivider(),
              Expanded(child: Text('12:00–14:00', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviousMatchesSection extends StatelessWidget {
  const _PreviousMatchesSection();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Previous Matches', style: TextStyle(color: kAppGreen, fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 14),
        Container(
          height: 110,
          decoration: BoxDecoration(color: kAppGreenLight, borderRadius: BorderRadius.circular(90)),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreBubble(score: '3–1', color: Colors.red),
              _ScoreBubble(score: '0–0', color: Colors.blue),
              _ScoreBubble(score: '1–2', color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreBubble extends StatelessWidget {
  final String score;
  final Color color;
  const _ScoreBubble({required this.score, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 50,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(score, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        CircleAvatar(radius: 5, backgroundColor: color),
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
        const Text('My Team', style: TextStyle(color: kAppGreen, fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(color: kAppBlueCard, borderRadius: BorderRadius.circular(28)),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(width: 60, height: 60, color: Colors.white, child: Image.asset('lib/images/team_logo.png')),
              const SizedBox(width: 20),
              const Text('Eagles', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
