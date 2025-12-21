import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../utils/colors.dart';
import '../utils/styles.dart';
import '../providers/setting_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _selectedPosition = 'Goalkeeper';

  final List<String> _positions = [
    'Goalkeeper',
    'Defender',
    'Midfielder',
    'Attacker'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists for this email. Please sign in instead.';
      case 'invalid-email':
        return 'The email address is invalid. Please check and try again.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many requests. Please wait a moment and try again.';
      default:
        return 'An error occurred during sign up. Please try again.';
    }
  }

  Future<void> _onSignUpPressed() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
      await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        position: _selectedPosition,
        age: int.parse(_ageController.text.trim()),
      );
      
      if (mounted) {
        // IMPORTANT: Let AuthGate handle the navigation to Home.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getFriendlyErrorMessage(e.code)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = settings.isDarkMode;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
    final panelColor = isDark ? Colors.grey[800] : kAppBlueCard;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Transform.scale(
                scale: 1.3,
                child: Image.asset(
                  'lib/images/bg_pattern.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -75,
                  left: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: kAppGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 90, top: 92),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.arrow_back, color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text('Back', style: TextStyle(color: Colors.white, fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 140),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: panelColor,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text('Create Account', style: kHeaderTextStyle.copyWith(color: Colors.white, fontSize: 24)),
                              const SizedBox(height: 20),
                              _DarkLabeledField(label: 'FULL NAME', hintText: 'Dani Martinez', controller: _nameController),
                              const SizedBox(height: 15),
                              _DarkLabeledField(label: 'EMAIL', hintText: 'example@mail.com', controller: _emailController, keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 15),
                              _DarkLabeledField(label: 'PASSWORD', hintText: '******', controller: _passwordController, obscureText: true),
                              const SizedBox(height: 15),
                              _DarkLabeledField(label: 'AGE', hintText: '25', controller: _ageController, keyboardType: TextInputType.number),
                              const SizedBox(height: 15),
                              
                              // Position Dropdown
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('POSITION', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.22),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedPosition,
                                        dropdownColor: kAppBlueCard,
                                        iconEnabledColor: Colors.white,
                                        style: const TextStyle(color: Colors.white),
                                        isExpanded: true,
                                        items: _positions.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() => _selectedPosition = newValue!);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kAppGreen,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                  ),
                                  onPressed: _onSignUpPressed,
                                  child: Consumer<app_auth.AuthProvider>(
                                    builder: (context, authProvider, _) {
                                      if (authProvider.isLoading) {
                                        return const CircularProgressIndicator(color: Colors.white);
                                      }
                                      return const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkLabeledField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _DarkLabeledField({required this.label, required this.hintText, required this.controller, this.obscureText = false, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w600, color: Colors.white70)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.22), borderRadius: BorderRadius.circular(28)),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
