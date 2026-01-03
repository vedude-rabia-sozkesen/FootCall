import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../providers/matches_provider.dart';
import '../providers/teams_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../models/team_model.dart';
import '../models/match_model.dart';
import '../providers/setting_provider.dart';
import '../pages/create_match_request_page.dart';
import '../services/match_service.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  String? _selectedStatusFilter; // null = All, 'scheduled', 'played', 'canceled'
  String? _selectedDayFilter; // null = All, 'today', 'tomorrow', 'thisWeek', 'thisMonth'
  String? _selectedLocationFilter; // null = All, or specific location string

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final matchesProvider = context.watch<MatchesProvider>();
    final authProvider = context.watch<app_auth.AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E2235) : const Color(0xFFF2F4FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: _MatchesHeader(),
            ),
            _FilterSection(
              selectedStatusFilter: _selectedStatusFilter,
              selectedDayFilter: _selectedDayFilter,
              selectedLocationFilter: _selectedLocationFilter,
              matches: matchesProvider.matches,
              onStatusFilterChanged: (filter) {
                setState(() {
                  _selectedStatusFilter = filter;
                });
              },
              onDayFilterChanged: (filter) {
                setState(() {
                  _selectedDayFilter = filter;
                });
              },
              onLocationFilterChanged: (filter) {
                setState(() {
                  _selectedLocationFilter = filter;
                });
              },
            ),
            _ListHeader(),
            const SizedBox(height: kSmallPadding),
            Expanded(
              child: _buildMatchesList(matchesProvider, matchesProvider.matches, user?.uid),
            ),
            if (user != null) _CreateMatchButton(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }

  Widget _buildMatchesList(MatchesProvider matchesProvider, List<QueryDocumentSnapshot> allMatches, String? userId) {
    if (matchesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (matchesProvider.error != null) {
      return Center(child: Text('Error: ${matchesProvider.error}'));
    }
    
    if (allMatches.isEmpty) {
      return Center(
        child: Text(
          'No matches available',
          style: TextStyle(color: context.watch<SettingsProvider>().isDarkMode ? Colors.white : Colors.black),
        ),
      );
    }

    return ListView.builder(
      itemCount: allMatches.length,
      itemBuilder: (context, index) {
        final matchDoc = allMatches[index];
        return _MatchListTile(
          matchDoc: matchDoc,
          userId: userId,
          selectedStatusFilter: _selectedStatusFilter,
          selectedDayFilter: _selectedDayFilter,
          selectedLocationFilter: _selectedLocationFilter,
        );
      },
    );
  }
}

class _ListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFCBD8FF),
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: 12,
      ),
      child: Row(
        children: const [
          Expanded(flex: 4, child: Text('TEAMS', style: TextStyle(color: Color(0xFF4B5775), fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Text('TIME', style: TextStyle(color: Color(0xFF4B5775), fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('RESULT', style: TextStyle(color: Color(0xFF4B5775), fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
          Expanded(flex: 4, child: Text('STATUS/ACTIONS', style: TextStyle(color: Color(0xFF4B5775), fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _CreateMatchButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        children: [
          Text(
            'Create Match',
            style: kCardTitleStyle.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateMatchRequestPage())),
            child: const CircleAvatar(radius: 36, backgroundColor: Color(0xFF87C56C), child: Icon(Icons.add, color: Colors.white, size: 36)),
          ),
        ],
      ),
    );
  }
}

class _MatchesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Container(
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: settings.isDarkMode ? [const Color(0xFF41465A), const Color(0xFF2C3144)] : [const Color(0xFF6E7FB6), const Color(0xFF4F5F9E)],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            top: 35,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back,
                color: settings.isDarkMode ? Colors.white : Colors.white,
                size: 28,
              ),
            ),
          ),
          Center(child: Text('Matches', style: kCardTitleStyle.copyWith(fontSize: 18))),
          Positioned(top: 4, right: 8, child: IconButton(
            onPressed: settings.toggleTheme,
            icon: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: settings.isDarkMode ? Colors.black : Colors.white),
          )),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String? selectedStatusFilter;
  final String? selectedDayFilter;
  final String? selectedLocationFilter;
  final List<QueryDocumentSnapshot> matches;
  final ValueChanged<String?> onStatusFilterChanged;
  final ValueChanged<String?> onDayFilterChanged;
  final ValueChanged<String?> onLocationFilterChanged;

  const _FilterSection({
    required this.selectedStatusFilter,
    required this.selectedDayFilter,
    required this.selectedLocationFilter,
    required this.matches,
    required this.onStatusFilterChanged,
    required this.onDayFilterChanged,
    required this.onLocationFilterChanged,
  });

  List<String> _getUniqueLocations() {
    final locations = <String>{};
    for (final match in matches) {
      final data = match.data() as Map<String, dynamic>?;
      if (data != null && data['location'] != null) {
        locations.add(data['location'] as String);
      }
    }
    return locations.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final uniqueLocations = _getUniqueLocations();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Filter
          Text(
            'Status:',
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF4B5775),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: selectedStatusFilter == null,
                  onTap: () => onStatusFilterChanged(null),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Scheduled',
                  isSelected: selectedStatusFilter == 'scheduled',
                  onTap: () => onStatusFilterChanged('scheduled'),
                  isDark: isDark,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Played',
                  isSelected: selectedStatusFilter == 'played',
                  onTap: () => onStatusFilterChanged('played'),
                  isDark: isDark,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Canceled',
                  isSelected: selectedStatusFilter == 'canceled',
                  onTap: () => onStatusFilterChanged('canceled'),
                  isDark: isDark,
                  color: Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Day Filter
          Row(
            children: [
              Text(
                'Day:',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF4B5775),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _FilterDropdown(
                  value: selectedDayFilter,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Days', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'today', child: Text('Today', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'tomorrow', child: Text('Tomorrow', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'thisWeek', child: Text('This Week', style: TextStyle(fontSize: 11))),
                    DropdownMenuItem(value: 'thisMonth', child: Text('This Month', style: TextStyle(fontSize: 11))),
                  ],
                  onChanged: onDayFilterChanged,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Location Filter
          Row(
            children: [
              Text(
                'Location:',
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF4B5775),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _FilterDropdown(
                  value: selectedLocationFilter,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Locations', style: TextStyle(fontSize: 11))),
                    ...uniqueLocations.map((location) => DropdownMenuItem(
                      value: location,
                      child: Text(location, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                    )),
                  ],
                  onChanged: onLocationFilterChanged,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String? value;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;
  final bool isDark;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A3150) : const Color(0xFFCBD8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<String?>(
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF4B5775),
          fontSize: 11,
        ),
        dropdownColor: isDark ? const Color(0xFF2A3150) : const Color(0xFFCBD8FF),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDark ? Colors.white70 : const Color(0xFF4B5775),
          size: 18,
        ),
        iconSize: 18,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? (isDark ? const Color(0xFF6E7FB6) : const Color(0xFF4F5F9E)))
              : (isDark ? const Color(0xFF2A3150) : const Color(0xFFCBD8FF)),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: color ?? (isDark ? Colors.white70 : Colors.black54),
                  width: 2,
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : const Color(0xFF4B5775)),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _MatchListTile extends StatelessWidget {
  final QueryDocumentSnapshot matchDoc;
  final String? userId;
  final String? selectedStatusFilter;
  final String? selectedDayFilter;
  final String? selectedLocationFilter;

  const _MatchListTile({
    required this.matchDoc,
    this.userId,
    this.selectedStatusFilter,
    this.selectedDayFilter,
    this.selectedLocationFilter,
  });

  Future<bool> _isUserAdminOfMatch(String? userId, String teamAId, String teamBId, TeamsProvider teamsProvider) async {
    if (userId == null) return false;
    
    final teamA = await teamsProvider.getTeam(teamAId);
    final teamB = await teamsProvider.getTeam(teamBId);
    
    final isAdminA = teamA?.createdBy == userId;
    final isAdminB = teamB?.createdBy == userId;
    
    return isAdminA || isAdminB;
  }

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder to get real-time updates from Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('matches').doc(matchDoc.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final match = MatchModel.fromDocumentSnapshot(snapshot.data!);
        
        // Apply status filter
        if (selectedStatusFilter != null) {
          String normalizedStatus = match.status;
          if (normalizedStatus == 'pending') normalizedStatus = 'scheduled';
          if (normalizedStatus == 'completed') normalizedStatus = 'played';
          
          if (normalizedStatus != selectedStatusFilter) {
            return const SizedBox.shrink();
          }
        }
        
        // Apply day filter
        if (selectedDayFilter != null) {
          final matchDate = match.matchDate.toDate();
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final matchDay = DateTime(matchDate.year, matchDate.month, matchDate.day);
          
          bool matchesDayFilter = false;
          switch (selectedDayFilter) {
            case 'today':
              matchesDayFilter = matchDay == today;
              break;
            case 'tomorrow':
              matchesDayFilter = matchDay == today.add(const Duration(days: 1));
              break;
            case 'thisWeek':
              final weekStart = today.subtract(Duration(days: today.weekday - 1));
              final weekEnd = weekStart.add(const Duration(days: 6));
              matchesDayFilter = matchDay.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                                 matchDay.isBefore(weekEnd.add(const Duration(days: 1)));
              break;
            case 'thisMonth':
              matchesDayFilter = matchDate.year == now.year && matchDate.month == now.month;
              break;
          }
          
          if (!matchesDayFilter) {
            return const SizedBox.shrink();
          }
        }
        
        // Apply location filter
        if (selectedLocationFilter != null && match.location != selectedLocationFilter) {
          return const SizedBox.shrink();
        }
        
        final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);

        final teamAId = match.teamAId;
        final teamBId = match.teamBId;
        final status = match.status;
        final date = DateFormat('dd/MM HH:mm').format(match.matchDate.toDate());
        final scoreA = match.scoreA;
        final scoreB = match.scoreB;
        
        // Map old statuses to new ones
        String displayStatus = status;
        if (status == 'pending') displayStatus = 'scheduled';
        if (status == 'completed') displayStatus = 'played';
        
        // Show score if it exists, regardless of status
        final hasScore = scoreA != null && scoreB != null;
        final result = hasScore ? '$scoreA - $scoreB' : '-';

        return Padding(
          padding: const EdgeInsets.only(bottom: kSmallPadding),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/match-info', arguments: matchDoc.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: 16.0),
              color: context.watch<SettingsProvider>().isDarkMode ? const Color(0xFF2A3150) : const Color(0xFF6B79A6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: FutureBuilder<List<TeamModel?>>(
                    future: Future.wait([
                      teamsProvider.getTeam(teamAId ?? ''),
                      teamsProvider.getTeam(teamBId ?? ''),
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text('...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13));
                      final teamA = snapshot.data![0];
                      final teamB = snapshot.data![1];
                      return Text(
                        '${teamA?.name ?? 'Team A'} vs ${teamB?.name ?? 'Team B'}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    date,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    result,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          displayStatus.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(displayStatus),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (teamAId != null && teamBId != null)
                        GestureDetector(
                          onTap: () {}, // Stop event propagation
                          child: FutureBuilder<bool>(
                            future: _isUserAdminOfMatch(userId, teamAId, teamBId, teamsProvider),
                            builder: (context, adminSnapshot) {
                              final isAdmin = adminSnapshot.data ?? false;
                              
                              if (displayStatus == 'scheduled' && isAdmin) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.play_circle, color: Colors.white, semanticLabel: 'Mark as Played'),
                                      onPressed: () => _markAsPlayed(context, matchDoc.id),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.cancel, color: Colors.red, semanticLabel: 'Cancel Match'),
                                      onPressed: () => _cancelMatch(context, matchDoc.id),
                                    ),
                                  ],
                                );
                              }
                              
                              // Score editing is only available in match info screen, not here
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.green;
      case 'played':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.white70;
    }
  }

  Future<void> _markAsPlayed(BuildContext context, String matchId) async {
    try {
      final matchService = MatchService();
      await matchService.updateMatchStatus(matchId: matchId, status: 'played');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match marked as played'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelMatch(BuildContext context, String matchId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Match?'),
        content: const Text('Are you sure you want to cancel this match?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final matchService = MatchService();
        await matchService.updateMatchStatus(matchId: matchId, status: 'canceled');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Match canceled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
