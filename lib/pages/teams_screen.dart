import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/teams_provider.dart';
import 'team_info_page.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';
import '../utils/colors.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  String selectedCity = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final bgColor = isDark ? Colors.grey[900]! : Colors.grey[200]!;
    final teamsProvider = context.watch<TeamsProvider>();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 100,
              color: isDark ? Colors.grey[850]! : const Color(0xFFA8C686),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 16,
                    top: 35,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.arrow_back,
                          color: isDark ? Colors.white : Colors.black, size: 28),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Teams',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 35,
                    child: IconButton(
                      onPressed: () => context.read<SettingsProvider>().toggleTheme(),
                      icon: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: isDark ? Colors.black : Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Builder(
                    builder: (context) {
                      final teams = teamsProvider.teams;
                      final cities = <String>{'All', ...teams.map((t) => t.city)};
                      return ElevatedButton.icon(
                        onPressed: () => _showFilterDialog(context, cities),
                        icon: const Icon(Icons.filter_list, color: Colors.black),
                        label: Text(
                          'Filter — $selectedCity',
                          style: const TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA8C686),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: _buildTeamsList(teamsProvider, isDark),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }

  Widget _buildTeamsList(TeamsProvider teamsProvider, bool isDark) {
    if (teamsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (teamsProvider.error != null) {
      return Center(child: Text('Error: ${teamsProvider.error}'));
    }
    
    if (teamsProvider.teams.isEmpty) {
      return const Center(child: Text("No teams found"));
    }

    final filteredTeams = selectedCity == 'All'
        ? teamsProvider.teams
        : teamsProvider.teams
            .where((t) => t.city.toLowerCase() == selectedCity.toLowerCase())
            .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]! : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListView.separated(
        itemCount: filteredTeams.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final team = filteredTeams[index];
          return ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TeamInfoPage(team: team),
                ),
              );
            },
            tileColor: index % 2 == 0 
                ? (isDark ? Colors.grey[850] : const Color(0xFFE8F5E9)) 
                : (isDark ? Colors.grey[900] : Colors.white),
            title: Text(team.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text('${team.city} / ${team.district}', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
            trailing: Icon(Icons.chevron_right, color: kAppGreen),
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context, Set<String> cities) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Filter by City'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cities.map((city) {
              return ChoiceChip(
                label: Text(city),
                selected: selectedCity == city,
                onSelected: (_) {
                  setState(() => selectedCity = city);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
