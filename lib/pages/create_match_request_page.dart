import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../services/team_service.dart';
import '../services/match_request_service.dart';
import '../services/auth_service.dart';
import '../models/team_model.dart';
import '../providers/setting_provider.dart';
import '../utils/colors.dart';

class CreateMatchRequestPage extends StatefulWidget {
  const CreateMatchRequestPage({super.key});

  @override
  State<CreateMatchRequestPage> createState() => _CreateMatchRequestPageState();
}

class _CreateMatchRequestPageState extends State<CreateMatchRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();

  final TeamService _teamService = TeamService();
  final MatchRequestService _matchRequestService = MatchRequestService();
  final AuthService _authService = AuthService();

  TeamModel? _selectedOpponentTeam;
  DateTime? _selectedDate;
  String? _myTeamId;

  @override
  void initState() {
    super.initState();
    _fetchMyTeamId();
  }

  Future<void> _fetchMyTeamId() async {
    final user = _authService.currentUser;
    if (user != null) {
      final playerData = await _authService.getPlayerData(user.uid);
      if (playerData.exists) {
        setState(() {
          _myTeamId = (playerData.data() as Map<String, dynamic>)['currentTeamId'];
        });
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateController.text = DateFormat('dd/MM/yyyy - HH:mm').format(_selectedDate!);
        });
      }
    }
  }

  void _sendRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedOpponentTeam == null || _selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an opponent and a date.')),
        );
        return;
      }
      if (_myTeamId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be in a team to send a request.')),
        );
        return;
      }

      try {
        await _matchRequestService.createMatchRequest(
          receivingTeamId: _selectedOpponentTeam!.id,
          matchDate: _selectedDate!,
          location: _locationController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match request sent successfully!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Match Request'),
        backgroundColor: isDark ? Colors.grey[850] : kAppGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Opponent Team Picker
              StreamBuilder<List<TeamModel>>(
                stream: _teamService.getTeamsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final teams = snapshot.data!.where((team) => team.id != _myTeamId).toList();
                  return DropdownButtonFormField<TeamModel>(
                    decoration: const InputDecoration(labelText: 'Select Opponent Team'),
                    value: _selectedOpponentTeam,
                    items: teams.map((team) {
                      return DropdownMenuItem<TeamModel>(
                        value: team,
                        child: Text(team.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedOpponentTeam = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select a team' : null,
                  );
                },
              ),
              const SizedBox(height: 20),
              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 20),
              // Date Time Picker
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Date and Time',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _pickDate,
                validator: (value) => value == null || value.isEmpty ? 'Please select a date and time' : null,
              ),
              const SizedBox(height: 32),
              // Submit Button
              ElevatedButton(
                onPressed: _sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Send Match Request', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
