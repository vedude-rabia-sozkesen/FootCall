import 'package:flutter/material.dart';
import '../data/player_repository.dart';
import '../models/player_model.dart';
import '../widgets/app_bottom_nav.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFD4DCE8),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Header with Players title
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF4A5568),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text(
                    'Players',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Filter button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _showFilterDialog();
                    },
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.black87,
                      size: 22,
                    ),
                    label: const Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Table header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF4A5568),
                borderRadius: BorderRadius.only(
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
            Expanded(
              child: ValueListenableBuilder<List<PlayerModel>>(
                valueListenable: _repository.playersNotifier,
                builder: (context, players, _) {
                  // Filter players if filter text is not empty
                  final filteredPlayers = _filterText.isEmpty
                      ? players
                      : players
                          .where((player) =>
                              player.name
                                  .toLowerCase()
                                  .contains(_filterText.toLowerCase()) ||
                              player.id
                                  .toLowerCase()
                                  .contains(_filterText.toLowerCase()))
                          .toList();

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filteredPlayers.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      itemBuilder: (context, index) {
                        final player = filteredPlayers[index];
                        return InkWell(
                          onTap: () {
                            // Navigate to player info screen
                            Navigator.of(context).pushNamed(
                              '/player-info',
                              arguments: player.id,
                            );
                          },
                          child: Container(
                            color: index % 2 == 0
                                ? const Color(0xFF4A5568)
                                : const Color(0xFFD4DCE8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      player.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      player.id,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      '${player.age}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: index % 2 == 0
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Shared Bottom Navigation (Search Active)
            const AppBottomNavBar(activeIndex: 2),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempFilter = _filterText;
        return AlertDialog(
          title: const Text('Filter Players'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'Enter player name or ID',
                ),
                onChanged: (value) {
                  tempFilter = value;
                },
                controller: TextEditingController(text: _filterText),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filterText = '';
                });
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B8E4E),
              ),
              onPressed: () {
                setState(() {
                  _filterText = tempFilter;
                });
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
