import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../mixins/theme_mixin.dart';
import '../data/match_repository.dart';
import '../models/match_model.dart';
import '../utils/constants.dart';
import '../widgets/app_bottom_nav.dart';
import '../providers/setting_provider.dart';

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
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final isDark = settings.isDarkMode;

        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF121212)
              : const Color(0xFFC9DAF3),

          appBar: AppBar(
            title: const Text('Create Match'),
            backgroundColor: isDark
                ? const Color(0xFF2D2D2D)
                : const Color(0xFF1E2235),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: settings.toggleTheme,
                icon: Icon(
                  isDark
                      ? Icons.dark_mode    // Dark moddayken AY
                      : Icons.light_mode,  // Light moddayken GÜNEŞ
                  color: isDark
                      ? Colors.black       // Dark → siyah ay
                      : Colors.white,      // Light → beyaz güneş
                ),
              ),
            ],
          ),


          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(kDefaultPadding),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFF1E2235),
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
                              isDark: isDark,
                            ),
                            _buildField(
                              label: 'Time',
                              controller: _timeController,
                              hint: 'e.g. 12.00-14.00',
                              isDark: isDark,
                            ),
                            _buildField(
                              label: 'Location',
                              controller: _locationController,
                              isDark: isDark,
                            ),
                            _buildField(
                              label: 'Playing Team',
                              controller: _teamController,
                              isDark: isDark,
                            ),

                            const SizedBox(height: kDefaultPadding),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7FBD63),
                                foregroundColor: Colors.white,
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
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
              ],
            ),
          ),

          bottomNavigationBar: const AppBottomNavBar(activeIndex: 2),
        );
      },
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hint,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
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
              fillColor: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFF2D344C),
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Matches'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
