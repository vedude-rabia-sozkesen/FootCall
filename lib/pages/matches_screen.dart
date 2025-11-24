import 'package:flutter/material.dart';

import '../data/match_repository.dart';
import '../models/match_model.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
// Replaced AppBottomNavBar with local _HomeBottomBar implementation (or shared widget)
// import '../widgets/app_bottom_nav.dart'; 

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  final MatchRepository _repository = MatchRepository.instance;
  String? _filterCity;
  String? _filterDistrict;
  String? _filterTeamName;
  String? _filterTime;

  /// Check if match time interval is inside the filter time interval
  /// Example: match "12.00-14.00" is inside filter "12.00-15.00"
  bool _isTimeIntervalInside(String matchTimeRange, String filterTimeRange) {
    try {
      // Parse match time range (e.g., "12.00-14.00")
      final matchParts = matchTimeRange.split('-');
      if (matchParts.length != 2) {
        // Fallback to simple contains if format is unexpected
        return matchTimeRange.toLowerCase().contains(filterTimeRange.toLowerCase());
      }
      
      final matchStart = _parseTime(matchParts[0].trim());
      final matchEnd = _parseTime(matchParts[1].trim());
      
      // Parse filter time range (e.g., "12.00-15.00" or just "12.00")
      final filterParts = filterTimeRange.split('-');
      if (filterParts.length == 1) {
        // Single time value - check if it's within match range
        final filterTime = _parseTime(filterParts[0].trim());
        return filterTime >= matchStart && filterTime <= matchEnd;
      } else if (filterParts.length == 2) {
        // Time range - check if match interval is inside filter interval
        final filterStart = _parseTime(filterParts[0].trim());
        final filterEnd = _parseTime(filterParts[1].trim());
        
        // Match is inside filter if match start >= filter start and match end <= filter end
        return matchStart >= filterStart && matchEnd <= filterEnd;
      }
      
      return false;
    } catch (e) {
      // Fallback to simple contains if parsing fails
      return matchTimeRange.toLowerCase().contains(filterTimeRange.toLowerCase());
    }
  }

  /// Parse time string (e.g., "12.00" or "12:00") to minutes since midnight
  int _parseTime(String timeStr) {
    // Remove any non-digit characters except dot and colon
    timeStr = timeStr.replaceAll(RegExp(r'[^\d.:]'), '');
    
    // Handle both "12.00" and "12:00" formats
    final parts = timeStr.contains(':') 
        ? timeStr.split(':') 
        : timeStr.split('.');
    
    if (parts.length >= 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      return hours * 60 + minutes;
    } else if (parts.length == 1) {
      // Just hours
      final hours = int.tryParse(parts[0]) ?? 0;
      return hours * 60;
    }
    
    return 0;
  }

  List<MatchModel> get _filteredMatches {
    final allMatches = _repository.matchesNotifier.value;
    return allMatches.where((match) {
      if (_filterCity != null && _filterCity!.isNotEmpty) {
        if (!match.cityDistrict.toLowerCase().contains(_filterCity!.toLowerCase())) {
          return false;
        }
      }
      if (_filterDistrict != null && _filterDistrict!.isNotEmpty) {
        if (!match.cityDistrict.toLowerCase().contains(_filterDistrict!.toLowerCase())) {
          return false;
        }
      }
      if (_filterTeamName != null && _filterTeamName!.isNotEmpty) {
        if (!match.matchTitle.toLowerCase().contains(_filterTeamName!.toLowerCase()) &&
            !match.playingTeam.toLowerCase().contains(_filterTeamName!.toLowerCase())) {
          return false;
        }
      }
      if (_filterTime != null && _filterTime!.isNotEmpty) {
        if (!_isTimeIntervalInside(match.timeRange, _filterTime!)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _showFilterDialog() {
    final cityController = TextEditingController(text: _filterCity ?? '');
    final districtController = TextEditingController(text: _filterDistrict ?? '');
    final teamController = TextEditingController(text: _filterTeamName ?? '');
    final timeController = TextEditingController(text: _filterTime ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Matches'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'Enter city name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: districtController,
                decoration: const InputDecoration(
                  labelText: 'District',
                  hintText: 'Enter district name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: teamController,
                decoration: const InputDecoration(
                  labelText: 'Team Name',
                  hintText: 'Enter team name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  hintText: 'Enter time range (e.g., 12.00-15.00)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _filterCity = null;
                _filterDistrict = null;
                _filterTeamName = null;
                _filterTime = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _filterCity = cityController.text.trim().isEmpty
                    ? null
                    : cityController.text.trim();
                _filterDistrict = districtController.text.trim().isEmpty
                    ? null
                    : districtController.text.trim();
                _filterTeamName = teamController.text.trim().isEmpty
                    ? null
                    : teamController.text.trim();
                _filterTime = timeController.text.trim().isEmpty
                    ? null
                    : timeController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2235),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: _MatchesHeader(),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                        vertical: kDefaultPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            'Filter',
                            style: TextStyle(
                              color: Color(0xFF4B5775),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          IconButton(
                            onPressed: _showFilterDialog,
                            icon: const Icon(
                              Icons.filter_list,
                              color: Color(0xFF4B5775),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color(0xFFCBD8FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: kDefaultPadding,
                        vertical: 12,
                      ),
                      child: Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'city/district',
                              style: TextStyle(
                                color: Color(0xFF4B5775),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'team name(s)',
                              style: TextStyle(
                                color: Color(0xFF4B5775),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'time',
                              style: TextStyle(
                                color: Color(0xFF4B5775),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: kSmallPadding),
                    Expanded(
                      child: ValueListenableBuilder<List<MatchModel>>(
                        valueListenable: _repository.matchesNotifier,
                        builder: (context, matches, _) {
                          final filtered = _filteredMatches;
                          if (filtered.isEmpty) {
                            return const Center(
                              child: Text(
                                'No matches available',
                                style: TextStyle(color: Colors.black87),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: kSmallPadding),
                            itemBuilder: (context, index) {
                              final match = filtered[index];
                              return Dismissible(
                                key: ValueKey(match.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  color: kAppRed,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) {
                                  _repository.removeMatch(match.id);
                                },
                                child: _MatchListTile(match: match),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: kDefaultPadding),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Create Match',
                        style: kCardTitleStyle.copyWith(
                          color: const Color(0xFF1E2235),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_repository.isAdmin)
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/create-match');
                          },
                          child: const CircleAvatar(
                            radius: 36,
                            backgroundColor: Color(0xFF87C56C),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: kDefaultPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MatchesBottomBar(),
    );
  }
}

class _MatchesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF41465A), Color(0xFF2C3144)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: Center(
        child: Text(
          'Matches',
          style: kCardTitleStyle.copyWith(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _MatchListTile extends StatelessWidget {
  const _MatchListTile({required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/match-info',
          arguments: match,
        );
      },
      child: Container(
        width: double.infinity,
        color: const Color(0xFF2A3150),
        padding: const EdgeInsets.symmetric(
          horizontal: kDefaultPadding,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                match.cityDistrict,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(match.assetLogoPath),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      match.matchTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  match.timeRange,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Bottom Bar for Matches Screen
class MatchesBottomBar extends StatelessWidget {
  const MatchesBottomBar({super.key});

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
            isActive: false,
            onTap: () => _showPlaceholderDialog(context),
          ),
          _BottomItem(
            imagePath: 'lib/images/search_logo.png',
            label: 'Search',
            isActive: false, // This could be true if Matches is considered Search
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
