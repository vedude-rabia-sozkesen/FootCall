import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/team_model.dart';
import '../utils/colors.dart';
import '../providers/setting_provider.dart';
import '../widgets/app_bottom_nav.dart';

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
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    final bgColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    final tableHeaderColor = isDark ? Colors.grey[800]! : const Color(0xFFDFF0D8);
    final panelTextColor = isDark ? Colors.white : Colors.black87;
    final tableCellBg = isDark ? Colors.grey[850]! : Colors.white;
    final nameCellColor = isDark ? Colors.green[700]! : Colors.green[100]!; // Name/Surname hücresi koyultuldu

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(isDark: isDark),
            const SizedBox(height: 16),
            Text(
              '${team.name} • ${team.city}/${team.district}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: panelTextColor,
              ),
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
                        decoration: BoxDecoration(color: tableHeaderColor),
                        children: const [
                          _TableHeader('Name/Surname'),
                          _TableHeader('Age'),
                          _TableHeader('Position'),
                          _TableHeader('Title'),
                        ],
                      ),
                      ...team.players.map((player) => TableRow(
                        children: [
                          _TableCell(player.name, bgColor: nameCellColor, textColor: panelTextColor),
                          _TableCell(player.age, bgColor: tableCellBg, textColor: panelTextColor),
                          _TableCell(player.position, bgColor: tableCellBg, textColor: panelTextColor),
                          _TableCell(player.title, bgColor: tableCellBg, textColor: panelTextColor),
                        ],
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Previous Matches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: panelTextColor,
                    ),
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
                          color: isDark ? Colors.grey[800]! : Colors.white,
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: panelTextColor,
                              ),
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
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isDark;
  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: isDark ? Colors.grey[850]! : kAppGreen,
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
                color: isDark ? Colors.grey[700]! : kAppGreenLight,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            top: 35,
            child: Text(
              'Team Info',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          // Dark/Light mode button
          Positioned(
            top: 35,
            right: 20,
            child: GestureDetector(
              onTap: () => context.read<SettingsProvider>().toggleTheme(),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Colors.white : Colors.black,
                size: 26,
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
  final String text;
  final Color bgColor;
  final Color textColor;
  const _TableCell(this.text, {this.bgColor = Colors.white, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
