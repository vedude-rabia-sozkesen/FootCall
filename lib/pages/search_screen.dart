import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';
import '../services/auth_service.dart';
import '../services/team_service.dart';
import '../models/team_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[100];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBarWithTheme(
              searchController: _searchController,
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _searchQuery.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _SearchActionButton(
                          label: 'List Teams',
                          onTap: () {
                            Navigator.of(context).pushNamed('/teams');
                          },
                        ),
                        const SizedBox(height: 12),
                        _SearchActionButton(
                          label: 'List Matches',
                          onTap: () {
                            Navigator.of(context).pushNamed('/matches');
                          },
                        ),
                        const SizedBox(height: 12),
                        _SearchActionButton(
                          label: 'List Players',
                          onTap: () {
                            Navigator.of(context).pushNamed('/players');
                          },
                        ),
                      ],
                    )
                  : _SearchResults(searchQuery: _searchQuery),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }
}

// 🔥 ÜST BAR + THEME BUTONU
class _TopBarWithTheme extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _TopBarWithTheme({
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;

    return Container(
      width: double.infinity,
      height: 120,
      color: isDark ? Colors.grey[850] : kAppGreen,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 72,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : kAppGreenLight,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Search team or player',
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const Icon(Icons.search, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  // 🔥 THEME BUTTON
                  Material(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String searchQuery;

  const _SearchResults({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final queryLower = searchQuery.trim().toLowerCase();

    // Only show results if query is not empty
    if (queryLower.isEmpty) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('teams').snapshots(),
      builder: (context, teamsSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: AuthService().getPlayersStream(),
          builder: (context, playersSnapshot) {
            final List<Widget> results = [];

            // Filter teams - only by name
            if (teamsSnapshot.hasData) {
              final teams = teamsSnapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().trim().toLowerCase();
                return name.isNotEmpty && name.contains(queryLower);
              }).toList();

              if (teams.isNotEmpty) {
                results.add(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'Teams',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );

                for (final teamDoc in teams) {
                  final team = TeamModel.fromFirestore(teamDoc);
                  results.add(
                    _SearchResultItem(
                      title: team.name,
                      subtitle: '${team.city} / ${team.district}',
                      icon: Icons.group,
                      onTap: () {
                        Navigator.of(context).pushNamed('/team-info', arguments: team);
                      },
                      isDark: isDark,
                    ),
                  );
                }
              }
            }

            // Filter players - only by name
            if (playersSnapshot.hasData) {
              final players = playersSnapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().trim().toLowerCase();
                return name.isNotEmpty && name.contains(queryLower);
              }).toList();

              if (players.isNotEmpty) {
                if (results.isNotEmpty) {
                  results.add(const SizedBox(height: 16));
                }
                results.add(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Text(
                      'Players',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );

                for (final playerDoc in players) {
                  final data = playerDoc.data() as Map<String, dynamic>;
                  final name = data['name'] ?? 'Unknown';
                  final id = data['id'] ?? '';
                  results.add(
                    _SearchResultItem(
                      title: name,
                      subtitle: id.isNotEmpty ? 'ID: $id' : '',
                      icon: Icons.person,
                      onTap: () {
                        Navigator.of(context).pushNamed('/player-info', arguments: playerDoc.id);
                      },
                      isDark: isDark,
                    ),
                  );
                }
              }
            }

            if (results.isEmpty) {
              return Center(
                child: Text(
                  'No results found',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: results,
            );
          },
        );
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _SearchResultItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      color: isDark ? Colors.grey[800] : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: isDark ? Colors.white : kAppGreen),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle.isNotEmpty
            ? Text(
                subtitle,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

// 🔥 ACTION BUTTON
class _SearchActionButton extends StatelessWidget {
  const _SearchActionButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final buttonColor = isDark ? Colors.grey[700] : kAppGreenLight;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
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
