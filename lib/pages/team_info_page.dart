import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/team_model.dart';
import '../utils/colors.dart';
import '../providers/setting_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../services/team_service.dart';
import '../services/auth_service.dart';

class TeamInfoPage extends StatelessWidget {
  const TeamInfoPage({super.key, required this.team});

  final TeamModel team;

  Color _matchColor(String result) {
    if (result == '0-0' || result.endsWith('1-1') || result.endsWith('2-2')) {
      return Colors.blue;
    }
    if (result.endsWith('3-1') || result.endsWith('2-0') || result.endsWith('1-0')) {
      return Colors.green;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final teamService = Provider.of<TeamService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    final bgColor = isDark ? Colors.grey[900]! : Colors.grey[100]!;
    final tableHeaderColor = isDark ? Colors.grey[800]! : const Color(0xFFDFF0D8);
    final panelTextColor = isDark ? Colors.white : Colors.black87;
    final tableCellBg = isDark ? Colors.grey[850]! : Colors.white;
    final nameCellColor = isDark ? Colors.green[700]! : Colors.green[100]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(isDark: isDark),
            const SizedBox(height: 16),
            Text(
              '${team.name} • ${team.city}/${team.district}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: panelTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Real-time member list
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('teams').doc(team.id).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      final teamData = snapshot.data!.data() as Map<String, dynamic>;
                      final List<String> memberIds = List<String>.from(teamData['memberIds'] ?? []);
                      final String createdBy = teamData['createdBy'] ?? '';

                      return Table(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(color: tableHeaderColor),
                            children: const [
                              _TableHeader('Name/Surname'),
                              _TableHeader('Age'),
                              _TableHeader('Position'),
                              _TableHeader('Title'),
                            ],
                          ),
                          // Dynamic members from Firestore
                          ...memberIds.map((memberId) {
                            return _buildDynamicTableRow(memberId, createdBy, nameCellColor, tableCellBg, panelTextColor);
                          }),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Join Team Button (Only if not already in this team)
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('players').doc(authService.currentUser!.uid).snapshots(),
                    builder: (context, playerSnap) {
                      if (!playerSnap.hasData) return const SizedBox();
                      final playerData = playerSnap.data!.data() as Map<String, dynamic>;
                      final currentTeamId = playerData['currentTeamId'];
                      
                      if (currentTeamId == team.id) {
                        return Center(
                          child: Text("You are a member of this team", 
                            style: TextStyle(color: kAppGreen, fontWeight: FontWeight.bold)),
                        );
                      }

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAppGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: currentTeamId != null ? null : () async {
                          await teamService.joinTeam(team.id, authService.currentUser!.uid);
                        },
                        child: Text(currentTeamId != null ? "Already in a Team" : "Join Team"),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Previous Matches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: panelTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: team.previousMatches.map((match) {
                      return _buildMatchBubble(match, isDark, panelTextColor, _matchColor(match));
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
    );
  }

  TableRow _buildDynamicTableRow(String uid, String ownerId, Color nameColor, Color cellColor, Color textColor) {
    return TableRow(
      children: [
        _buildPlayerCell(uid, 'name', nameColor, textColor),
        _buildPlayerCell(uid, 'age', cellColor, textColor),
        _buildPlayerCell(uid, 'position', cellColor, textColor),
        _TableCell(uid == ownerId ? "Admin" : "Player", bgColor: cellColor, textColor: textColor),
      ],
    );
  }

  Widget _buildPlayerCell(String uid, String field, Color bg, Color text) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('players').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _TableCell("...", bgColor: bg, textColor: text);
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final val = data?[field]?.toString() ?? "-";
        return _TableCell(val, bgColor: bg, textColor: text);
      },
    );
  }

  Widget _buildMatchBubble(String match, bool isDark, Color textColor, Color dotColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]! : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 4, offset: Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(match, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 6),
          Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isDark;
  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: isDark ? Colors.grey[850]! : kAppGreen,
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
                color: isDark ? Colors.grey[700]! : kAppGreenLight,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Positioned(
            top: 35,
            child: const Text('Team Info', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          Positioned(
            left: 16,
            top: 35,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;
  const _TableCell(this.text, {this.bgColor = Colors.white, this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(10),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
