import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../services/team_service.dart';
import '../services/match_request_service.dart';
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
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('players')
          .doc(authService.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            bottomNavigationBar: const AppBottomNavBar(activeIndex: 1),
            body: const Center(child: CircularProgressIndicator(color: kAppGreen)),
          );
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final String? teamId = data?['currentTeamId'];

        if (teamId == null || teamId.isEmpty) {
          return Scaffold(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            bottomNavigationBar: const AppBottomNavBar(activeIndex: 1),
            body: const _NoTeamView(),
          );
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('teams')
              .doc(teamId)
              .snapshots(),
          builder: (context, teamSnap) {
            if (teamSnap.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                bottomNavigationBar: const AppBottomNavBar(activeIndex: 1),
                body: const Center(child: CircularProgressIndicator(color: kAppGreen)),
              );
            }
            if (!teamSnap.hasData || !teamSnap.data!.exists) {
              return Scaffold(
                backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                bottomNavigationBar: const AppBottomNavBar(activeIndex: 1),
                body: const _NoTeamView(),
              );
            }

            final team = TeamModel.fromFirestore(teamSnap.data!);
            return Scaffold(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              bottomNavigationBar: const AppBottomNavBar(activeIndex: 1),
              floatingActionButton: FloatingActionButton(
                backgroundColor: kAppGreen,
                onPressed: () {
                  Navigator.pushNamed(context, '/team-chat', arguments: {
                    'teamId': team.id,
                    'teamName': team.name,
                  });
                },
                child: const Icon(Icons.chat, color: Colors.white),
              ),
              body: _TeamDetailView(team: team),
            );
          },
        );
      },
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
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final bool isCurrentUserAdmin = team.createdBy == authService.currentUser!.uid;

    return Column(
      children: [
        _TopBar(title: team.name, isDark: isDark),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),
              _MatchRequestsSection(team: team, isCurrentUserAdmin: isCurrentUserAdmin),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Team Members", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    _LeaveTeamButton(team: team),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _TeamMembersList(team: team, isDark: isDark),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaveTeamButton extends StatelessWidget {
  final TeamModel team;
  const _LeaveTeamButton({required this.team});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final teamService = context.read<TeamService>();

    return TextButton.icon(
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
    );
  }
}

class _TeamMembersList extends StatelessWidget {
  final TeamModel team;
  final bool isDark;
  const _TeamMembersList({required this.team, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Sort member IDs to show admin first
    List<String> sortedMemberIds = List.from(team.memberIds);
    sortedMemberIds.sort((a, b) {
      if (a == team.createdBy) return -1; // a is admin, should come first
      if (b == team.createdBy) return 1;  // b is admin, should come first
      return 0; // keep original order
    });

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedMemberIds.length,
      itemBuilder: (context, index) {
        final memberId = sortedMemberIds[index];
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('players').doc(memberId).snapshots(),
          builder: (context, playerSnap) {
            String name = "Loading...";
            if (playerSnap.hasData && playerSnap.data != null && playerSnap.data!.exists) {
              final data = playerSnap.data!.data() as Map<String, dynamic>?;
              name = data?['name'] ?? "No Name";
            }
            
            return Card(
              color: isDark ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () {
                  // Navigate to player info screen, but don't do anything if it's the current user.
                  if (memberId != Provider.of<AuthService>(context, listen: false).currentUser?.uid) {
                     Navigator.of(context).pushNamed('/player-info', arguments: memberId);
                  }
                },
                leading: const CircleAvatar(backgroundColor: kAppGreen, child: Icon(Icons.person, color: Colors.white)),
                title: Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text(team.createdBy == memberId ? "Admin" : "Member", 
                  style: const TextStyle(color: kAppGreen, fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }
}

class _MatchRequestsSection extends StatelessWidget {
  final TeamModel team;
  final bool isCurrentUserAdmin;

  const _MatchRequestsSection({required this.team, required this.isCurrentUserAdmin});

  @override
  Widget build(BuildContext context) {
    final requestService = MatchRequestService();

    return StreamBuilder<QuerySnapshot>(
      stream: requestService.getPendingMatchRequestsForTeam(team.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink(); // No requests, show nothing
        }

        final requests = snapshot.data!.docs;
        final isDark = context.watch<SettingsProvider>().isDarkMode;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Match Requests", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return _MatchRequestCard(request: request, isCurrentUserAdmin: isCurrentUserAdmin);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _MatchRequestCard extends StatelessWidget {
  final QueryDocumentSnapshot request;
  final bool isCurrentUserAdmin;
  const _MatchRequestCard({required this.request, required this.isCurrentUserAdmin});

  @override
  Widget build(BuildContext context) {
    final requestData = request.data() as Map<String, dynamic>;
    final requestService = MatchRequestService();
    final teamService = TeamService();
    final sendingTeamId = requestData['sendingTeamId'];
    final location = requestData['proposedLocation'];
    final Timestamp timestamp = requestData['proposedMatchDate'];
    final date = DateFormat('dd/MM/yyyy - HH:mm').format(timestamp.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<TeamModel?>(
              future: teamService.getTeam(sendingTeamId),
              builder: (context, teamSnapshot) {
                if (!teamSnapshot.hasData) {
                  return const Text("From: Loading...", style: TextStyle(fontWeight: FontWeight.bold));
                }
                return Text("From: ${teamSnapshot.data?.name ?? 'Unknown Team'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
              },
            ),
            const SizedBox(height: 8),
            Text("📍 Location: $location"),
            const SizedBox(height: 4),
            Text("📅 Date: $date"),
            if (isCurrentUserAdmin)
              const SizedBox(height: 12),
            if (isCurrentUserAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                       await requestService.rejectMatchRequest(request.id);
                    },
                    child: const Text("Reject", style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kAppGreen),
                    onPressed: () async {
                       await requestService.acceptMatchRequest(request.id);
                    },
                    child: const Text("Accept", style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
          ],
        ),
      ),
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
