import 'package:flutter/material.dart';

const kAppGreen = Color(0xFF4C8F3A);
const kAppGreenLight = Color(0xFF7BC567);


class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: kAppGreen,
      currentIndex: 2, // 0: Home, 1: My Team, 2: Search, 3: MyProfile
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          label: 'My Team',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'MyProfile',
        ),
      ],
      onTap: (index) {
        
      },
    );
  }
}


class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _SearchActionButton(
                    label: 'List Teams',
                    onTap: () {
                      
                    },
                  ),
                  const SizedBox(height: 12),
                  _SearchActionButton(
                    label: 'List Matches',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SearchActionButton(
                    label: 'List Players',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const AppBottomNavBar(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      color: kAppGreen,
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
                color: kAppGreenLight,
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
                color: const Color(0xFF111827), // koyu lacivert kutu
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Search team, match or player',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.white, size: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchActionButton extends StatelessWidget {
  const _SearchActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAppGreenLight,
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
