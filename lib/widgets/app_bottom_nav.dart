import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/styles.dart';

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

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  // Change: Home now navigates to the real Home Page ('/home') instead of '/'
  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  Widget _buildItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: kBottomNavTextStyle,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: kAppGreen,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItem(
            context: context,
            icon: Icons.home_outlined,
            label: 'Home',
            onTap: () => _goHome(context),
          ),
          _buildItem(
            context: context,
            icon: Icons.group_outlined,
            label: 'My Team',
            onTap: () => _showPlaceholderDialog(context),
          ),
          _buildItem(
            context: context,
            icon: Icons.search,
            label: 'Search',
            onTap: () => _showPlaceholderDialog(context),
          ),
          _buildItem(
            context: context,
            icon: Icons.person_outline,
            label: 'MyProfile',
            onTap: () => _showPlaceholderDialog(context),
          ),
        ],
      ),
    );
  }
}
