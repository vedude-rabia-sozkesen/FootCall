import 'package:flutter/material.dart';
import '../mixins/theme_mixin.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';
import 'package:provider/provider.dart';
import '../providers/setting_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white, ← SİLİNDİ
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: kAppGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              final isDark = settings.isDarkMode;

              return IconButton(
                onPressed: () {
                  settings.toggleTheme();
                },
                icon: Icon(
                  isDark
                      ? Icons.dark_mode    // Dark → AY
                      : Icons.light_mode,  // Light → GÜNEŞ
                  color: isDark
                      ? Colors.black       // Dark mode → siyah ay
                      : Colors.white,      // Light mode → beyaz güneş
                ),
              );
            },
          ),
        ],
      ),


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
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),

          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: kAppBlueCard,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                      child: Column(
                        children: [
                          Text(
                            'Sign In',
                            style: kHeaderTextStyle.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue.',
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
                                    label: '   EMAIL',
                                    hintText: 'hello@reallygreatsite.com',
                                    controller: _emailController,
                                    keyboardType:
                                    TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 18),
                                  _DarkLabeledField(
                                    label: '   PASSWORD',
                                    hintText: '******',
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
                                      onPressed: _onLoginPressed,
                                      child: const Text('Sign In'),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration:
                                        TextDecoration.underline,
                                      ),
                                    ),
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
            color: Colors.white.withOpacity(0.22),
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