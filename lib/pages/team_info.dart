import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../widgets/app_bottom_nav.dart';

class TeamInfoPage extends StatelessWidget {
  const TeamInfoPage({super.key});

  // Şimdilik DEMO veri – sadece UI için
  List<Map<String, dynamic>> get _players => const [
    {
      'name': 'Jonathan Patterson',
      'age': 28,
      'position': 'FW',
      'title': 'Captain',
    },
    {
      'name': 'Alex Smith',
      'age': 25,
      'position': 'MF',
      'title': '',
    },
    {
      'name': 'David Johnson',
      'age': 23,
      'position': 'DF',
      'title': '',
    },
  ];

  List<String> get _previousMatches => const ['3-1', '0-0', '1-2'];

  Color _matchColor(String result) {
    // berabere
    if (result == '0-0' ||
        result.endsWith('1-1') ||
        result.endsWith('2-2')) {
      return Colors.blue;
    }
    // kazandı
    if (result.endsWith('3-1') ||
        result.endsWith('2-0') ||
        result.endsWith('1-0')) {
      return Colors.green;
    }
    // kaybetti
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

            // Takım adı + şehir – şimdilik sabit
            const Text(
              'Eagles • Ankara/Polatlı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Oyuncu tablosu
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(
                          color: Color(0xFFDFF0D8),
                        ),
                        children: [
                          _TableHeader('Name/Surname'),
                          _TableHeader('Age'),
                          _TableHeader('Position'),
                          _TableHeader('Title'),
                        ],
                      ),
                      ..._players.map(
                            (player) => TableRow(
                          children: [
                            _TableCell(player['name'] as String),
                            _TableCell('${player['age']}'),
                            _TableCell(player['position'] as String),
                            _TableCell(player['title'] as String),
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
                    children: _previousMatches.map((match) {
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
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
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