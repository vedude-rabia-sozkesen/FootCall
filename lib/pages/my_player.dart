import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';

class MyPlayerPage extends StatelessWidget {
  const MyPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in.")));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('players').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Player data not found."));
          }

          final playerData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _ProfileCard(playerData: playerData),
                const SizedBox(height: 16),
                _StatsCard(playerData: playerData),
                const SizedBox(height: 16),
                _UserInfoCard(playerData: playerData, uid: user.uid),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(activeIndex: 3),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kAppGreen,
        foregroundColor: Colors.white,
        title: const Text("My Profile", style: kHeaderTextStyle),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => context.read<SettingsProvider>().toggleTheme(),
            icon: Icon(
              context.watch<SettingsProvider>().isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: context.watch<SettingsProvider>().isDarkMode ? Colors.black : Colors.white,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/requests'),
            child: const Text("Requests", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          // Show admin button only if user created a team
          StreamBuilder<DocumentSnapshot?>(
            stream: user != null 
                ? FirebaseFirestore.instance.collection('players').doc(user.uid).snapshots()
                : Stream<DocumentSnapshot?>.value(null),
            builder: (context, playerSnapshot) {
              if (!playerSnapshot.hasData) return const SizedBox.shrink();
              
              final playerData = playerSnapshot.data!.data() as Map<String, dynamic>?;
              final teamId = playerData?['currentTeamId'] as String?;
              
              if (teamId == null) return const SizedBox.shrink();
              
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('teams').doc(teamId).snapshots(),
                builder: (context, teamSnapshot) {
                  if (!teamSnapshot.hasData || !teamSnapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }
                  
                  final teamData = teamSnapshot.data!.data() as Map<String, dynamic>;
                  final createdBy = teamData['createdBy'] as String?;
                  final bool isAdmin = createdBy == user?.uid;
                  
                  if (!isAdmin) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white),
                      onPressed: () => Navigator.of(context).pushNamed('/admin'),
                      child: const Text("Admin", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  );
                },
              );
            },
          ),
        ],
      );
  }
}

// Other widgets (_ProfileCard, _StatsCard) remain the same

class _ProfileCard extends StatelessWidget {
  final Map<String, dynamic> playerData;
  const _ProfileCard({required this.playerData});

  @override
  Widget build(BuildContext context) {
    final String name = playerData['name'] ?? 'No Name';
    final int age = playerData['age'] ?? 0;
    final String position = playerData['position'] ?? 'N/A';
    final String playerId = playerData['id'] ?? 'No ID';

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 32, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text("Age: $age", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text("Position: $position", style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 2),
                  Text("Player ID: #$playerId", style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Map<String, dynamic> playerData;
  const _StatsCard({required this.playerData});

  @override
  Widget build(BuildContext context) {
    final int matches = playerData['matchesPlayed'] ?? 0;
    final int wins = playerData['wins'] ?? 0;
    final int losses = playerData['losses'] ?? 0;

    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Player Stats", style: TextStyle(color: kAppGreen, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: "Matches", value: matches.toString()),
                _StatItem(label: "Wins", value: wins.toString()),
                _StatItem(label: "Losses", value: losses.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _UserInfoCard extends StatefulWidget {
  final Map<String, dynamic> playerData;
  final String uid;
  const _UserInfoCard({required this.playerData, required this.uid});

  @override
  State<_UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<_UserInfoCard> {
  bool _isEditing = false;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.playerData['phone'] ?? '');
    _locationController = TextEditingController(text: widget.playerData['location'] ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.updatePlayerProfile(widget.uid, {
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String email = widget.playerData['email'] ?? 'No email provided';

    return Card(
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Contact Info", style: TextStyle(color: kAppGreen, fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    if (_isEditing) {
                      _saveChanges();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.email_outlined, text: email),
            const SizedBox(height: 12),
            _isEditing
                ? _EditRow(controller: _phoneController, icon: Icons.phone_outlined)
                : _InfoRow(icon: Icons.phone_outlined, text: widget.playerData['phone'] ?? 'No phone provided'),
            const SizedBox(height: 12),
            _isEditing
                ? _EditRow(controller: _locationController, icon: Icons.location_on_outlined)
                : _InfoRow(icon: Icons.location_on_outlined, text: widget.playerData['location'] ?? 'No location provided'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

class _EditRow extends StatelessWidget {
  final IconData icon;
  final TextEditingController controller;

  const _EditRow({required this.icon, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ),
      ],
    );
  }
}
