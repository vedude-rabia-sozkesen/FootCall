import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import 'home_page.dart'; // Import Home Page to access _HomeBottomBar logic or similar if needed
// But since _HomeBottomBar is private in home_page.dart, we should probably extract it or copy it.
// For now, I will re-implement the bottom bar here or better yet, create a shared widget if possible.
// Given the instructions, I will copy the bottom bar structure.

class MyPlayerPage extends StatelessWidget {
  final bool isAdmin;

  const MyPlayerPage({
    super.key,
    this.isAdmin = true, // Default to true for now to show the button as requested
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false, // This removes the back button
        backgroundColor: kAppGreen,
        foregroundColor: Colors.white,
        title: const Text("My Player", style: kHeaderTextStyle),
        centerTitle: false,
        actions: [
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
      // Using a custom Bottom Bar similar to Home Page but with 'MyProfile' active
      bottomNavigationBar: const MyPlayerBottomBar(), 
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kAppBlueCard,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 32, color: kAppBlueCard),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fatih Paksoy",
                    style: kCardTitleStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Age: 24",
                    style: kPillTextStyle.copyWith(fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Position: ST",
                    style: kPillTextStyle.copyWith(fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Player ID: #123456",
                    style: kPillTextStyle.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
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
      color: Colors.white,
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kAppBlueCard,
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
      color: Colors.white,
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
        Icon(icon, size: 20, color: kAppGreen),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: kAppBlueCard,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Bottom Bar for MyPlayer Page
class MyPlayerBottomBar extends StatelessWidget {
  const MyPlayerBottomBar({super.key});

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
            isActive: true, // Active here
            onTap: () {}, // Already on this page
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
