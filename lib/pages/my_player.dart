import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';
import 'package:provider/provider.dart';
import '../providers/setting_provider.dart';

class MyPlayerPage extends StatelessWidget {
  final bool isAdmin;

  const MyPlayerPage({
    super.key,
    this.isAdmin = true, // Default to true for now to show the button as requested
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back button
        backgroundColor: kAppGreen,
        foregroundColor: Colors.white,
        title: const Text("My Player", style: kHeaderTextStyle),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              context.read<SettingsProvider>().toggleTheme();
            },
            icon: Icon(
              context.watch<SettingsProvider>().isDarkMode
                  ? Icons.dark_mode    // Dark mode'dayken → AY göster
                  : Icons.light_mode,  // Light mode'dayken → GÜNEŞ göster
              color: context.watch<SettingsProvider>().isDarkMode
                  ? Colors.black       // Dark mode → siyah ay
                  : Colors.white,      // Light mode → beyaz güneş
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/requests');
            },
            child: const Text(
              "Requests",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (isAdmin)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/admin');
              },
              child: const Text(
                "Admin",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _ProfileCard(),
            SizedBox(height: 16),
            _StatsCard(),
            SizedBox(height: 16),
            _UserInfoCard(),
          ],
        ),
      ),
      // Using shared Bottom Bar
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 3), 
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 32,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Fatih Paksoy",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Age: 24",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Position: ST",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Player ID: #123456",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Player Stats",
              style: TextStyle(
                color: kAppGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatItem(label: "Matches", value: "24"),
                _StatItem(label: "Goals", value: "12"),
                _StatItem(label: "Assists", value: "5"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Contact Info",
              style: TextStyle(
                color: kAppGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.email_outlined, text: "fatih@example.com"),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.phone_outlined, text: "+90 555 123 45 67"),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.location_on_outlined, text: "Istanbul, Turkey"),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

