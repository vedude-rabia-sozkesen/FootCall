import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/match_repository.dart';
import '../models/match_model.dart';
import '../utils/constants.dart';
import '../utils/colors.dart'; // Need kAppGreen for CreateMatchBottomBar
// AppBottomNavBar removed

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _teamController = TextEditingController();

  final MatchRepository _repository = MatchRepository.instance;

  @override
  void dispose() {
    _cityController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _teamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9DAF3),
      appBar: AppBar(
        title: const Text('Create Match'),
        backgroundColor: const Color(0xFF1E2235),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2235),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: kSmallPadding),
                        _buildField(
                          label: 'City / District',
                          controller: _cityController,
                        ),
                        _buildField(
                          label: 'Time',
                          controller: _timeController,
                          hint: 'e.g. 12.00-14.00',
                        ),
                        _buildField(
                          label: 'Location',
                          controller: _locationController,
                        ),
                        _buildField(
                          label: 'Playing Team',
                          controller: _teamController,
                        ),
                        const SizedBox(height: kDefaultPadding),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7FBD63),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          onPressed: _submit,
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const CreateMatchBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint ?? 'Enter $label',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2D344C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              errorStyle: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final match = MatchModel(
      id: const Uuid().v4(),
      cityDistrict: _cityController.text.trim(),
      matchTitle: _teamController.text.trim(),
      timeRange: _timeController.text.trim(),
      location: _locationController.text.trim(),
      playingTeam: _teamController.text.trim(),
      creatorName: 'You',
      assetLogoPath: 'lib/images/team_logo.png',
      coverImageUrl:
          'https://images.unsplash.com/photo-1508609349937-5ec4ae374ebf',
    );

    _repository.addMatch(match);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Match Created'),
          content: const Text('Your match has been added to the list.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // go back to matches
              },
              child: const Text('Back to Matches'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pushNamed(
                  '/match-info',
                  arguments: match,
                );
              },
              child: const Text('View Match'),
            ),
          ],
        );
      },
    );
  }
}

// Custom Bottom Bar for Create Match Page
class CreateMatchBottomBar extends StatelessWidget {
  const CreateMatchBottomBar({super.key});

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
            isActive: false,
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
