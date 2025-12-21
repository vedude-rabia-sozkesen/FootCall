import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart' as app_auth;
import '../providers/teams_provider.dart';
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
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('players').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(backgroundColor: isDark ? Colors.grey[900] : Colors.white, body: const Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final String? teamId = data?['currentTeamId'];

        if (teamId == null || teamId.isEmpty) {
          return Scaffold(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            bottomNavigationBar: const AppBottomNavBar(activeIndex: 1),
            body: const _NoTeamView(),
          );
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('teams').doc(teamId).snapshots(),
          builder: (context, teamSnap) {
            if (!teamSnap.hasData) {
              return Scaffold(backgroundColor: isDark ? Colors.grey[900] : Colors.white, body: const Center(child: CircularProgressIndicator()));
            }
            if (!teamSnap.data!.exists) {
              return Scaffold(backgroundColor: isDark ? Colors.grey[900] : Colors.white, body: const _NoTeamView());
            }

            final team = TeamModel.fromFirestore(teamSnap.data!);
            return Scaffold(
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              bottomNavigationBar: const AppBottomNavBar(activeIndex: 1),
              floatingActionButton: FloatingActionButton(
                backgroundColor: kAppGreen,
                onPressed: () => Navigator.pushNamed(context, '/team-chat', arguments: {'teamId': team.id, 'teamName': team.name}),
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
          const Text("You are not in a team yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
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
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final isDark = context.watch<SettingsProvider>().isDarkMode;
    final bool isCurrentUserAdmin = team.createdBy == authProvider.user?.uid;

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
                    Text("Team Members", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    _LeaveTeamButton(team: team, isCurrentUserAdmin: isCurrentUserAdmin),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _TeamMembersList(team: team, isDark: isDark, isCurrentUserAdmin: isCurrentUserAdmin),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaveTeamButton extends StatelessWidget {
  final TeamModel team;
  final bool isCurrentUserAdmin;
  const _LeaveTeamButton({required this.team, required this.isCurrentUserAdmin});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<app_auth.AuthProvider>();
    final teamsProvider = context.read<TeamsProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const SizedBox.shrink();
    }

    return TextButton.icon(
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(isCurrentUserAdmin && team.memberIds.length > 1 ? "Disband Team?" : "Leave Team?"),
            content: Text(isCurrentUserAdmin && team.memberIds.length > 1 
                ? "You are the admin. If you leave, admin rights will be transferred to the next player. Are you sure?"
                : "Are you sure you want to leave this team?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Leave", style: TextStyle(color: Colors.red))),
            ],
          ),
        );
        if (confirm == true) {
          try {
            await teamsProvider.leaveTeam(team.id, userId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('You left the team'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
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
      },
      icon: const Icon(Icons.exit_to_app, color: Colors.redAccent),
      label: const Text("Leave", style: TextStyle(color: Colors.redAccent)),
    );
  }
}

class _TeamMembersList extends StatelessWidget {
  final TeamModel team;
  final bool isDark;
  final bool isCurrentUserAdmin;
  const _TeamMembersList({required this.team, required this.isDark, required this.isCurrentUserAdmin});

  @override
  Widget build(BuildContext context) {
    List<String> sortedMemberIds = List.from(team.memberIds);
    sortedMemberIds.sort((a, b) {
      if (a == team.createdBy) return -1;
      if (b == team.createdBy) return 1;
      return a.compareTo(b);
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
            if (playerSnap.hasData && playerSnap.data!.exists) {
              name = (playerSnap.data!.data() as Map<String, dynamic>)['name'] ?? "No Name";
            }
            
            return Card(
              color: isDark ? Colors.grey[800] : Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () {
                  final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
                  if (memberId != authProvider.user?.uid) {
                     Navigator.of(context).pushNamed('/player-info', arguments: memberId);
                  }
                },
                leading: const CircleAvatar(backgroundColor: kAppGreen, child: Icon(Icons.person, color: Colors.white)),
                title: Text(name, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                subtitle: Text(team.createdBy == memberId ? "Admin" : "Member", style: const TextStyle(color: kAppGreen, fontWeight: FontWeight.bold)),
                trailing: (isCurrentUserAdmin && memberId != team.createdBy) 
                  ? _AdminMenuButton(teamId: team.id, memberId: memberId, currentAdminId: team.createdBy)
                  : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _AdminMenuButton extends StatelessWidget {
  final String teamId;
  final String memberId;
  final String currentAdminId;

  const _AdminMenuButton({required this.teamId, required this.memberId, required this.currentAdminId});

  @override
  Widget build(BuildContext context) {
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'kick') {
           await teamsProvider.leaveTeam(teamId, memberId);
        } else if (value == 'make_admin') {
           await teamsProvider.makeNewAdmin(teamId, memberId);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'kick',
          child: Text('Kick Player'),
        ),
        const PopupMenuItem<String>(
          value: 'make_admin',
          child: Text('Make New Admin'),
        ),
      ],
    );
  }
}


class _MatchRequestsSection extends StatelessWidget {
  final TeamModel team;
  final bool isCurrentUserAdmin;

  const _MatchRequestsSection({required this.team, required this.isCurrentUserAdmin});

  @override
  Widget build(BuildContext context) {
    // Match requests should only be shown in the requests screen, not in my team page
    // This section is removed to avoid confusion
    return const SizedBox.shrink();
  }
}

class _MatchRequestCard extends StatelessWidget {
  final QueryDocumentSnapshot request;
  final bool isCurrentUserAdmin;
  const _MatchRequestCard({required this.request, required this.isCurrentUserAdmin});

  @override
  Widget build(BuildContext context) {
    final requestData = request.data() as Map<String, dynamic>;
    final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
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
              future: teamsProvider.getTeam(sendingTeamId),
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
                  TextButton(onPressed: () async => await MatchRequestService().rejectMatchRequest(request.id), child: const Text("Reject", style: TextStyle(color: Colors.red))),
                  const SizedBox(width: 8),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: kAppGreen), onPressed: () async => await MatchRequestService().acceptMatchRequest(request.id), child: const Text("Accept", style: TextStyle(color: Colors.white))),
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
