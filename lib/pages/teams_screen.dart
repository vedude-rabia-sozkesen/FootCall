import 'package:flutter/material.dart';
import '../data/team_repository.dart';
import '../models/team_model.dart';
import 'team_info_page.dart';
import '../widgets/app_bottom_nav.dart';

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  final TeamRepository _repository = TeamRepository.instance;
  String selectedCity = 'All';

  // Correctly filtering using the static list from repository
  List<TeamModel> get _filteredTeams {
    if (selectedCity == 'All') return _repository.teams;
    return _repository.teams
        .where((team) => team.city.toLowerCase() == selectedCity.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // Header with Teams title
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFA8C686),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 24,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
                    ),
                  ),
                  const Text(
                    'Teams',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                  ElevatedButton.icon(
                    onPressed: _showFilterDialog,
                    icon: const Icon(Icons.filter_list, color: Colors.black),
                    label: Text(
                      'Filter — $selectedCity',
                      style: const TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA8C686),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Table header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFA8C686),
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
                        'City/District',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Team Name(s)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Teams list
            Expanded(
              child: Builder(
                builder: (context) {
                  // Use the local filtered list instead of ValueListenableBuilder
                  // because TeamRepository does not expose a notifier.
                  final teams = _filteredTeams;

                  if (teams.isEmpty) {
                    return const Center(child: Text("No teams found"));
                  }

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
                      itemCount: teams.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      itemBuilder: (context, index) {
                        final team = teams[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TeamInfoPage(team: team),
                              ),
                            );
                          },
                          child: Container(
                            color: index % 2 == 0
                                ? const Color(0xFFE8F5E9)
                                : Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4E7C5),
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '${team.city} / ${team.district}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      team.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
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

            // Bottom Navigation
            const AppBottomNavBar(activeIndex: 2), // Search active, or -1 if standalone
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final cities = <String>{'All', ..._repository.teams.map((team) => team.city)};
    showDialog(
      context: context,
      builder: (_) {
        String tempSelection = selectedCity;
        return AlertDialog(
          title: const Text('Filter by City'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cities.map((city) {
                  final isSelected = tempSelection == city;
                  return ChoiceChip(
                    label: Text(city),
                    selected: isSelected,
                    onSelected: (_) {
                      setStateDialog(() => tempSelection = city);
                      Navigator.pop(context);
                      setState(() => selectedCity = city);
                    },
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }
}
