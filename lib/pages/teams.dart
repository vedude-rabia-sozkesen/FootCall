import 'package:flutter/material.dart';
import '../data/team_repository.dart';
import '../models/team_model.dart';
import '../utils/colors.dart';
import 'team_info.dart';
// import '../widgets/app_bottom_nav.dart'; // Removed because it is no longer used

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final TeamRepository _repository = TeamRepository.instance;
  String selectedCity = 'All';

  List<TeamModel> get _filteredTeams {
    if (selectedCity == 'All') return _repository.teams;
    return _repository.teams
        .where((team) => team.city.toLowerCase() == selectedCity.toLowerCase())
        .toList();
  }

  void _showFilterDialog() {
    final cities = <String>{
      'All',
      ..._repository.teams.map((team) => team.city),
    };

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(title: 'Teams'),

            // Filter butonu
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_list),
                label: Text('Filter — $selectedCity'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // Başlık satırı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [
                  Expanded(
                    child: Text(
                      'City / District',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Team Name(s)',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Takım listesi
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTeams.length,
                itemBuilder: (context, index) {
                  final team = _filteredTeams[index];
                  final city = team.city;
                  final district = team.district;
                  final name = team.name;

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          // Using TeamInfoPage with the team parameter
                          builder: (_) => TeamInfoPage(team: team),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: kAppGreen),
                          const SizedBox(width: 10),
                          Text('$city / $district'),
                          const Spacer(),
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const TeamsBottomBar(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

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
          Positioned(
            top: 35,
            child: Text(
              title,
              style: const TextStyle(
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

// Custom Bottom Bar for Teams Page
class TeamsBottomBar extends StatelessWidget {
  const TeamsBottomBar({super.key});

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
            isActive: true, // Active on Teams page
            onTap: () {},
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
