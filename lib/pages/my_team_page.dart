import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/team_service.dart';
import '../models/team_model.dart';
import '../utils/colors.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';
import 'create_team_page.dart';

class MyTeamPage extends StatelessWidget {
  const MyTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final teamService = Provider.of<TeamService>(context, listen: false);
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 1),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('players').doc(authService.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kAppGreen));
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final String? teamId = data?['currentTeamId'];

          if (teamId == null || teamId.isEmpty) {
            return const _NoTeamView();
          }

          // Use another StreamBuilder for the team itself
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('teams').doc(teamId).snapshots(),
            builder: (context, teamSnap) {
              if (teamSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: kAppGreen));
              }
              if (!teamSnap.hasData || !teamSnap.data!.exists) {
                return const _NoTeamView();
              }

              final team = TeamModel.fromFirestore(teamSnap.data!);
              return _TeamDetailView(team: team);
            },
          );
        },
      ),
    );
  }
}

class _NoTeamView extends StatelessWidget {
  const _NoTeamView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("You are not in a team yet", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAppGreen, 
              foregroundColor: Colors.white, 
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTeamPage())),
            child: const Text("Create a Team", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _TeamDetailView extends StatelessWidget {
  final TeamModel team;
  const _TeamDetailView({required this.team});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final teamService = Provider.of<TeamService>(context, listen: false);
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Column(
      children: [
        _TopBar(title: team.name, isDark: isDark),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Team Members", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Leave Team?"),
                      content: const Text("Are you sure you want to leave this team?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Leave", style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await teamService.leaveTeam(team.id, authService.currentUser!.uid);
                  }
                },
                icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                label: const Text("Leave", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: team.memberIds.length,
            itemBuilder: (context, index) {
              final memberId = team.memberIds[index];
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('players').doc(memberId).snapshots(),
                builder: (context, playerSnap) {
                  String name = "Loading...";
                  if (playerSnap.hasData && playerSnap.data!.data() != null) {
                    final data = playerSnap.data!.data() as Map<String, dynamic>;
                    name = data['name'] ?? "No Name";
                  }
                  
                  return Card(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: kAppGreen, child: Icon(Icons.person, color: Colors.white)),
                      title: Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                      subtitle: Text(team.createdBy == memberId ? "Admin" : "Member", 
                        style: const TextStyle(color: kAppGreen, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final bool isDark;
  const _TopBar({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: isDark ? Colors.grey[850] : kAppGreen,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
