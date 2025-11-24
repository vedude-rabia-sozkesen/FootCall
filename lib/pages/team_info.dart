import 'package:flutter/material.dart';

import '../models/team_model.dart';
import '../utils/colors.dart';
// import 'teams_screen.dart'; // Removed unused import

class TeamInfoPage extends StatelessWidget {
  const TeamInfoPage({super.key, required this.team});

  final TeamModel team;

  Color _matchColor(String result) {
    if (result == '0-0' || result.endsWith('1-1') || result.endsWith('2-2')) {
      return Colors.blue;
    }
    if (result.endsWith('3-1') || result.endsWith('2-0') || result.endsWith('1-0')) {
      return Colors.green;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            const SizedBox(height: 16),
            Text(
              '${team.name} • ${team.city}/${team.district}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFDFF0D8),
                        ),
                        children: const [
                          _TableHeader('Name/Surname'),
                          _TableHeader('Age'),
                          _TableHeader('Position'),
                          _TableHeader('Title'),
                        ],
                      ),
                      ...team.players.map(
                        (player) => TableRow(
                          children: [
                            _TableCell(player.name),
                            _TableCell(player.age),
                            _TableCell(player.position),
                            _TableCell(player.title),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Previous Matches',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: team.previousMatches.map((match) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              match,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _matchColor(match),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const TeamInfoBottomBar(),
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
      height: 100,
      color: kAppGreen,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: kAppGreenLight,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const Positioned(
            top: 35,
            child: Text(
              'Team Info',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(text),
    );
  }
}

// Custom Bottom Bar for Team Info Page
class TeamInfoBottomBar extends StatelessWidget {
  const TeamInfoBottomBar({super.key});

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
            isActive: false,
            onTap: () => Navigator.of(context).pushNamed('/my-player'),
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
