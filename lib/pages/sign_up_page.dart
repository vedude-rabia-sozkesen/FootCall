import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    Navigator.pushReplacementNamed(context, '/login');
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
          // ARKA PLAN PATTERN
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Transform.scale(
                scale: 1.3,
                child: Image.asset(
                  'lib/images/bg_pattern.png',
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                // Sol üst yeşil daire (Back + Sign Up)
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.arrow_back,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Alttaki lacivert panel
                Column(
                  children: [
                    const SizedBox(height: 140),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: panelColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                          child: Column(
                            children: [
                              // 🔥 ÜST BAR + THEME BUTONU
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: settings.toggleTheme,
                                      child: SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: Icon(
                                          isDark
                                              ? Icons.dark_mode
                                              : Icons.light_mode,
                                          color: isDark
                                              ? Colors.black
                                              : Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Sign Up',
                                style: kHeaderTextStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Create an account to continue.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 28),

                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _DarkLabeledField(
                                        label: 'FULL NAME',
                                        hintText: 'Dani Martinez',
                                        controller: _nameController,
                                      ),
                                      const SizedBox(height: 18),
                                      _DarkLabeledField(
                                        label: 'EMAIL',
                                        hintText:
                                        'hello@reallygreatsite.com',
                                        controller: _emailController,
                                        keyboardType:
                                        TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: 18),
                                      _DarkLabeledField(
                                        label: 'PASSWORD',
                                        hintText: 'Create a password',
                                        controller: _passwordController,
                                        obscureText: true,
                                      ),
                                      const SizedBox(height: 28),

                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: kAppGreen,
                                            foregroundColor: Colors.white,
                                            padding:
                                            const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(32),
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          onPressed: _onSignUpPressed,
                                          child: const Text('Sign Up'),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Already registered?',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pushReplacementNamed(
                                                  context, '/login');
                                            },
                                            child: const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                decoration:
                                                TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                    ],
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

  const _DarkLabeledField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDarkMode;

    final labelStyle = TextStyle(
      fontSize: 11,
      letterSpacing: 1.5,
      fontWeight: FontWeight.w600,
      color: Colors.white.withOpacity(0.9),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[700]!.withOpacity(0.22)
                : Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.85),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
