import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/player_repository.dart';
import '../models/player_model.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  final PlayerRepository _repository = PlayerRepository.instance;
  String _filterText = '';

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final backgroundColor = isDark ? Colors.grey[900] : const Color(0xFFD4DCE8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 🔥 ÜST BAR
            _PlayersTopBar(),

            Expanded(
              child: ValueListenableBuilder<List<PlayerModel>>(
                valueListenable: _repository.playersNotifier,
                builder: (context, players, _) {
                  final filteredPlayers = _filterText.isEmpty
                      ? players
                      : players
                      .where((player) =>
                  player.name.toLowerCase().contains(_filterText.toLowerCase()) ||
                      player.id.toLowerCase().contains(_filterText.toLowerCase()))
                      .toList();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Filter button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: _showFilterDialog,
                              icon: Icon(
                                Icons.filter_alt_outlined,
                                color: isDark ? Colors.white : Colors.black87,
                                size: 22,
                              ),
                              label: Text(
                                'Filter',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Table header
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : const Color(0xFF4A5568),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'player name',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'player id',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    'age',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Players list
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            border: Border.all(
                              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                          ),
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: filteredPlayers.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: isDark ? Colors.grey[700] : Colors.grey[300],
                            ),
                            itemBuilder: (context, index) {
                              final player = filteredPlayers[index];
                              final isEven = index % 2 == 0;
                              final rowColor = isDark
                                  ? (isEven ? Colors.grey[800] : Colors.grey[850])
                                  : (isEven ? const Color(0xFF4A5568) : const Color(0xFFD4DCE8));
                              final textColor = isDark
                                  ? Colors.white
                                  : (isEven ? Colors.white : Colors.black87);

                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/player-info',
                                    arguments: player.id,
                                  );
                                },
                                child: Container(
                                  color: rowColor,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(player.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textColor,
                                              )),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text(player.id,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textColor,
                                              )),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Text('${player.age}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textColor,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }

  void _showFilterDialog() {
    final isDark = context.read<SettingsProvider>().isDarkMode;
    showDialog(
      context: context,
      builder: (context) {
        String tempFilter = _filterText;
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
          title: const Text('Filter Players'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Enter player name or ID',
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                onChanged: (value) => tempFilter = value,
                controller: TextEditingController(text: _filterText),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _filterText = '');
                Navigator.pop(context);
              },
              child: Text('Clear', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E4E),
              ),
              onPressed: () {
                setState(() => _filterText = tempFilter);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}

// 🔥 ÜST BAR Widget
class _PlayersTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Container(
      width: double.infinity,
      height: 80,
      color: isDark ? Colors.grey[850] : const Color(0xFF4A5568),
      child: Stack(
        children: [
          Center(
            child: Text(
              'Players',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: settings.toggleTheme,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: isDark ? Colors.black : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
