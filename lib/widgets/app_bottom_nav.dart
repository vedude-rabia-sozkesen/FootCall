import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int activeIndex;

  const AppBottomNavBar({super.key, required this.activeIndex});

  void _onTap(BuildContext context, int index) {
    // Only skip navigation if we are ALREADY on that specific page
    // and not just because the index matches.
    
    switch (index) {
      case 0: // Home
        if (ModalRoute.of(context)?.settings.name == '/home') return;
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        break;
      case 1: // My Team
        if (ModalRoute.of(context)?.settings.name == '/my-team') return;
        Navigator.of(context).pushNamed('/my-team');
        break;
      case 2: // Search
        if (ModalRoute.of(context)?.settings.name == '/search') return;
        Navigator.of(context).pushNamed('/search');
        break;
      case 3: // My Profile
        if (ModalRoute.of(context)?.settings.name == '/my-player') return;
        Navigator.of(context).pushNamed('/my-player');
        break;
    }
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
            isActive: activeIndex == 0,
            onTap: () => _onTap(context, 0),
          ),
          _BottomItem(
            imagePath: 'lib/images/myteam_logo.png',
            label: 'My Team',
            isActive: activeIndex == 1,
            onTap: () => _onTap(context, 1),
          ),
          _BottomItem(
            imagePath: 'lib/images/search_logo.png',
            label: 'Search',
            isActive: activeIndex == 2,
            onTap: () => _onTap(context, 2),
          ),
          _BottomItem(
            imagePath: 'lib/images/myprofile_logo.png',
            label: 'MyProfile',
            isActive: activeIndex == 3,
            onTap: () => _onTap(context, 3),
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
              color: Colors.white,
              fontSize: 15,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
