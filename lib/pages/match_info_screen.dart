import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/match_service.dart';
import '../services/team_service.dart';
import '../models/team_model.dart';
import '../providers/setting_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/teams_provider.dart';
import '../providers/matches_provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';

class MatchInfoScreen extends StatelessWidget {
  const MatchInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String matchId = ModalRoute.of(context)!.settings.arguments as String;
    final MatchService matchService = MatchService();
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFC9DAF3),
      appBar: _buildAppBar(context, isDark),
      body: StreamBuilder<DocumentSnapshot>(
        stream: matchService.getMatchStream(matchId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Match not found.'));
          }

          final matchData = snapshot.data!.data() as Map<String, dynamic>;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1E2235),
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    const SizedBox(height: kDefaultPadding * 1.5),
                    _InfoCard(matchData: matchData, isDark: isDark),
                    const SizedBox(height: kDefaultPadding),
                    _AdminControls(matchId: matchId, matchData: matchData),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
        title: const Text('Match Info'),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFF1E2235),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => context.read<SettingsProvider>().toggleTheme(),
            icon: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
        ],
      );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3A3A3A), const Color(0xFF1F1F1F)]
              : [const Color(0xFF5A637A), const Color(0xFF2A2F40)],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(32)),
      ),
      child: Center(
        child: Text('Match Info', style: kCardTitleStyle.copyWith(fontSize: 24)),
      ),
    );
  }
}

String _getStatusDisplayText(String status) {
  // Map old statuses to new ones
  if (status == 'pending') return 'SCHEDULED';
  if (status == 'completed') return 'PLAYED';
  return status.toUpperCase();
}

class _InfoCard extends StatelessWidget {
  final Map<String, dynamic> matchData;
  final bool isDark;

  const _InfoCard({required this.matchData, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final teamService = TeamService();
    final teamAId = matchData['teamA_id'];
    final teamBId = matchData['teamB_id'];
    final location = matchData['location'] ?? 'N/A';
    final timestamp = matchData['matchDate'] as Timestamp?;
    final date = timestamp != null
        ? DateFormat('dd/MM/yyyy - HH:mm').format(timestamp.toDate())
        : 'N/A';
    final scoreA = matchData['scoreA'];
    final scoreB = matchData['scoreB'];
    final scoreDisplay = scoreA != null && scoreB != null ? '$scoreA - $scoreB' : 'Not played';

    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF2D344C),
        borderRadius: BorderRadius.circular(32),
      ),
      child: FutureBuilder<List<TeamModel?>>(
        future: Future.wait([teamService.getTeam(teamAId), teamService.getTeam(teamBId)]),
        builder: (context, snapshot) {
          final teamA = snapshot.data?.isNotEmpty == true ? snapshot.data![0] : null;
          final teamB = snapshot.data?.length == 2 ? snapshot.data![1] : null;

          return Column(
            children: [
              _InfoRow(label: 'Teams', value: '${teamA?.name ?? '...'} vs ${teamB?.name ?? '...'}'),
              const SizedBox(height: kSmallPadding),
              _InfoRow(label: 'Status', value: _getStatusDisplayText(matchData['status'] ?? 'scheduled')),
              const SizedBox(height: kSmallPadding),
              _InfoRow(label: 'Score', value: scoreDisplay),
              const SizedBox(height: kSmallPadding),
              _InfoRow(label: 'Time', value: date),
              const SizedBox(height: kSmallPadding),
              _InfoRow(label: 'Location', value: location),
            ],
          );
        },
      ),
    );
  }
}

class _AdminControls extends StatelessWidget {
  final String matchId;
  final Map<String, dynamic> matchData;

  const _AdminControls({required this.matchId, required this.matchData});

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
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    final currentUser = authProvider.user;
    
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    final teamAId = matchData['teamA_id'] as String?;
    final teamBId = matchData['teamB_id'] as String?;

    if (teamAId == null || teamBId == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<bool>(
      future: _isUserAdminOfMatch(currentUser.uid, teamAId, teamBId, teamsProvider),
      builder: (context, adminSnapshot) {
        if (!adminSnapshot.hasData || !adminSnapshot.data!) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: MatchService().getMatchStream(matchId),
          builder: (context, matchSnapshot) {
            if (!matchSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final currentMatchData = matchSnapshot.data!.data() as Map<String, dynamic>;
            final currentStatus = currentMatchData['status'] ?? 'scheduled';
            
            // Map old statuses
            String displayStatus = currentStatus;
            if (currentStatus == 'pending') displayStatus = 'scheduled';
            if (currentStatus == 'completed') displayStatus = 'played';

            return Column(
              children: [
                _StatusSelector(
                  matchId: matchId,
                  currentStatus: displayStatus,
                  teamAId: teamAId,
                  teamBId: teamBId,
                ),
                if (displayStatus == 'played') ...[
                  const SizedBox(height: kDefaultPadding),
                  _ScoreEditor(
                    matchId: matchId,
                    matchData: currentMatchData,
                    teamAId: teamAId,
                    teamBId: teamBId,
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _StatusSelector extends StatelessWidget {
  final String matchId;
  final String currentStatus;
  final String teamAId;
  final String teamBId;

  const _StatusSelector({
    required this.matchId,
    required this.currentStatus,
    required this.teamAId,
    required this.teamBId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    
    return Container(
      padding: const EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF2D344C),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Status',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatusChip(
                  label: 'Scheduled',
                  value: 'scheduled',
                  currentStatus: currentStatus,
                  color: Colors.green,
                  onSelected: (selected) {
                    if (selected) _updateStatus(context, 'scheduled');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusChip(
                  label: 'Played',
                  value: 'played',
                  currentStatus: currentStatus,
                  color: Colors.blue,
                  onSelected: (selected) {
                    if (selected) _updateStatus(context, 'played');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatusChip(
                  label: 'Canceled',
                  value: 'canceled',
                  currentStatus: currentStatus,
                  color: Colors.red,
                  onSelected: (selected) {
                    if (selected) _updateStatus(context, 'canceled');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('matches').doc(matchId).update({'status': newStatus});
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toUpperCase()}'),
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
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final String currentStatus;
  final Color color;
  final ValueChanged<bool> onSelected;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.currentStatus,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentStatus == value;
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[800],
    );
  }
}

class _ScoreEditor extends StatelessWidget {
  final String matchId;
  final Map<String, dynamic> matchData;
  final String teamAId;
  final String teamBId;

  const _ScoreEditor({
    required this.matchId,
    required this.matchData,
    required this.teamAId,
    required this.teamBId,
  });

  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
    final matchesProvider = Provider.of<MatchesProvider>(context, listen: false);
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    
    final scoreA = matchData['scoreA'] as int?;
    final scoreB = matchData['scoreB'] as int?;

    return FutureBuilder<List<TeamModel?>>(
      future: Future.wait([
        teamsProvider.getTeam(teamAId),
        teamsProvider.getTeam(teamBId),
      ]),
      builder: (context, teamSnapshot) {
        if (!teamSnapshot.hasData) {
          return const SizedBox.shrink();
        }

        final teamA = teamSnapshot.data![0];
        final teamB = teamSnapshot.data![1];

        return Container(
          padding: const EdgeInsets.all(kDefaultPadding),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF2D344C),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Match Score',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              _ScoreEditorContent(
                matchId: matchId,
                teamA: teamA,
                teamB: teamB,
                initialScoreA: scoreA,
                initialScoreB: scoreB,
                matchesProvider: matchesProvider,
              ),
            ],
          ),
        );
      },
    );
  }

}

class _ScoreEditorContent extends StatefulWidget {
  final String matchId;
  final TeamModel? teamA;
  final TeamModel? teamB;
  final int? initialScoreA;
  final int? initialScoreB;
  final MatchesProvider matchesProvider;

  const _ScoreEditorContent({
    required this.matchId,
    required this.teamA,
    required this.teamB,
    required this.initialScoreA,
    required this.initialScoreB,
    required this.matchesProvider,
  });

  @override
  State<_ScoreEditorContent> createState() => _ScoreEditorContentState();
}

class _ScoreEditorContentState extends State<_ScoreEditorContent> {
  late TextEditingController _scoreAController;
  late TextEditingController _scoreBController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _scoreAController = TextEditingController(text: widget.initialScoreA?.toString() ?? '0');
    _scoreBController = TextEditingController(text: widget.initialScoreB?.toString() ?? '0');
  }

  @override
  void didUpdateWidget(_ScoreEditorContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialScoreA != widget.initialScoreA) {
      _scoreAController.text = widget.initialScoreA?.toString() ?? '0';
    }
    if (oldWidget.initialScoreB != widget.initialScoreB) {
      _scoreBController.text = widget.initialScoreB?.toString() ?? '0';
    }
    _hasChanges = false;
  }

  @override
  void dispose() {
    _scoreAController.dispose();
    _scoreBController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.teamA?.name ?? 'Team A',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _scoreAController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (_) => setState(() => _hasChanges = true),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '-',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    widget.teamB?.name ?? 'Team B',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _scoreBController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (_) => setState(() => _hasChanges = true),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (_hasChanges) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _scoreAController.text = widget.initialScoreA?.toString() ?? '0';
                    _scoreBController.text = widget.initialScoreB?.toString() ?? '0';
                    _hasChanges = false;
                  });
                },
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _saveScore,
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Save Score'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _saveScore() async {
    final scoreA = int.tryParse(_scoreAController.text);
    final scoreB = int.tryParse(_scoreBController.text);

    if (scoreA == null || scoreB == null || scoreA < 0 || scoreB < 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid non-negative numbers'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await widget.matchesProvider.updateMatchResult(
        matchId: widget.matchId,
        scoreA: scoreA,
        scoreB: scoreB,
      );

      setState(() {
        _hasChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Score saved: ${widget.teamA?.name ?? 'Team A'} $scoreA - $scoreB ${widget.teamB?.name ?? 'Team B'}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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


class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ],
    );
  }
}
