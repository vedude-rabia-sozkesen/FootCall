import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  String _filterText = '';

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final authService = Provider.of<AuthService>(context, listen: false);
    final backgroundColor = isDark ? Colors.grey[900] : const Color(0xFFD4DCE8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _PlayersTopBar(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: authService.getPlayersStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var players = snapshot.data!.docs;

                  final filteredPlayers = _filterText.isEmpty
                      ? players
                      : players.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final name = data['name'] as String? ?? '';
                          final id = data['id'] as String? ?? '';
                          return name.toLowerCase().contains(_filterText.toLowerCase()) ||
                                 id.toLowerCase().contains(_filterText.toLowerCase());
                        }).toList();

                  // The SingleChildScrollView ensures the content is scrollable when it exceeds the screen height.
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildFilterButton(isDark),
                        const SizedBox(height: 8),
                        _buildTableHeader(isDark),
                        _buildPlayerList(isDark, filteredPlayers),
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

  Widget _buildFilterButton(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: _showFilterDialog,
          icon: Icon(Icons.filter_alt_outlined, color: isDark ? Colors.white : Colors.black87, size: 22),
          label: Text('Filter', style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildTableHeader(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : const Color(0xFF4A5568),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Padding(padding: EdgeInsets.all(16), child: Text('PLAYER NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)))),
          Expanded(flex: 2, child: Padding(padding: EdgeInsets.all(16), child: Text('PLAYER ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)))),
          Expanded(flex: 1, child: Padding(padding: EdgeInsets.all(16), child: Text('AGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)))),
        ],
      ),
    );
  }

  Widget _buildPlayerList(bool isDark, List<QueryDocumentSnapshot> players) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: players.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
        itemBuilder: (context, index) {
          final playerDoc = players[index];
          final playerData = playerDoc.data() as Map<String, dynamic>;
          final isEven = index % 2 == 0;
          final rowColor = isDark ? (isEven ? Colors.grey[800] : Colors.grey[850]) : (isEven ? const Color(0xFFF7FAFC) : Colors.white);
          final textColor = isDark ? Colors.white : Colors.black87;

          return Container(
            color: rowColor,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      style: TextButton.styleFrom(foregroundColor: textColor, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 8.0)),
                      onPressed: () => Navigator.of(context).pushNamed('/player-info', arguments: playerDoc.id),
                      child: Text(playerData['name'] ?? '', style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
                Expanded(flex: 2, child: Padding(padding: const EdgeInsets.all(16), child: Text(playerData['id'] ?? '', style: TextStyle(fontSize: 14, color: textColor)))),
                Expanded(flex: 1, child: Padding(padding: const EdgeInsets.all(16), child: Text('${playerData['age'] ?? ''}', style: TextStyle(fontSize: 14, color: textColor)))),
              ],
            ),
          );
        },
      ),
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
            TextButton(onPressed: () { setState(() => _filterText = ''); Navigator.pop(context); }, child: Text('Clear', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white : Colors.black))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B8E4E)),
              onPressed: () { setState(() => _filterText = tempFilter); Navigator.pop(context); },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}

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
          const Center(child: Text('Players', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
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
