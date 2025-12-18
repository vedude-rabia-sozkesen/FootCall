import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'package:provider/provider.dart';
import '../providers/setting_provider.dart';

class MyTeamPage extends StatelessWidget {
  //const MyTeamPage({super.key, required this.team});

  // Şimdilik sadece type için; içinde alan kullanmıyoruz
  //final TeamModel team;

  // DEMO oyuncu listesi – TeamModel'e bağlı değil
  static const List<Map<String, dynamic>> _demoPlayers = [
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

  // DEMO maç skorları – TeamModel'e bağlı değil
  static const List<String> _demoMatches = ['3-1', '0-0', '1-2'];

  Color _matchColor(String result) {
    if (result == '0-0' ||
        result.endsWith('1-1') ||
        result.endsWith('2-2')) {
      return Colors.blue; // beraberlik
    }
    if (result.endsWith('3-1') ||
        result.endsWith('2-0') ||
        result.endsWith('1-0')) {
      return Colors.green; // galibiyet
    }
    return Colors.red; // mağlubiyet
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // SAĞ ALT TEAM CHAT TUŞU
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAppGreen,
        onPressed: () {
          Navigator.pushNamed(context, '/team-chat');
        },
        child: const Icon(Icons.chat_bubble_outline),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: Column(
          children: [
            const _MyTeamTopBar(),
            const SizedBox(height: 16),

            // Başlık – TeamModel alanı kullanılmıyor
            const Text(
              'My Team',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Oyuncu tablosu
                  Table(
                    border: TableBorder.all(
                      color: Theme.of(context).dividerColor,
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        ),
                        children: const [
                          _TableHeader('Name/Surname'),
                          _TableHeader('Age'),
                          _TableHeader('Position'),
                          _TableHeader('Title'),
                        ],
                      ),
                      ..._demoPlayers.map(
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _demoMatches.map((match) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
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
                                color: Theme.of(context).textTheme.bodyLarge?.color,
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const AppBottomNavBar(activeIndex: 1),
    );
  }
}

class _MyTeamTopBar extends StatelessWidget {
  const _MyTeamTopBar();

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
              'My Team',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // 🔥 YENİ EKLENEN — SAĞ ÜST LIGHT / DARK BUTONU
          Positioned(
            top: 30,
            right: 16,
            child: IconButton(
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
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
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
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}


