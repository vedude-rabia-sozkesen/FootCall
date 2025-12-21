import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/teams_provider.dart';
import '../models/team_model.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _onCreatePressed() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team name is required')));
      return;
    }

    try {
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
      final teamsProvider = Provider.of<TeamsProvider>(context, listen: false);
      final uid = authProvider.user?.uid;
      
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to create a team')),
        );
        return;
      }
      
      final teamId = const Uuid().v4();

      final newTeam = TeamModel(
        id: teamId,
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        district: _districtController.text.trim(),
        description: _descController.text.trim(),
        createdBy: uid,
        createdAt: DateTime.now(),
        memberIds: [uid],
      );

      await teamsProvider.createTeam(newTeam);
      await teamsProvider.joinTeam(teamId, uid);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Team", style: kHeaderTextStyle),
        backgroundColor: kAppGreen,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('lib/images/bg_pattern.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _StyledField(label: 'TEAM NAME', hintText: 'e.g. Eagles FC', controller: _nameController),
                  const SizedBox(height: 18),
                  _StyledField(label: 'CITY', hintText: 'e.g. Istanbul', controller: _cityController),
                  const SizedBox(height: 18),
                  _StyledField(label: 'DISTRICT', hintText: 'e.g. Kadikoy', controller: _districtController),
                  const SizedBox(height: 18),
                  _StyledField(label: 'DESCRIPTION', hintText: 'Tell us about your team...', controller: _descController, maxLines: 3),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAppGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      onPressed: _onCreatePressed,
                      child: Consumer<TeamsProvider>(
                        builder: (context, teamsProvider, _) {
                          if (teamsProvider.isLoading) {
                            return const CircularProgressIndicator(color: Colors.white);
                          }
                          return const Text("Create Team", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final int maxLines;

  const _StyledField({required this.label, required this.hintText, required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: kAppGreen)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
