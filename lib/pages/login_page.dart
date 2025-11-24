import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';

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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ARKA PLAN PATTERN (ellemedim, aynı kaldı)
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
          // 2) CONTENT
          SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                // 2a) SOL ÜST YEŞİL DAİRE (Back + Sign In)
                Positioned(
                  top: -75, //
                  left: -80,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: kAppGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 90, top: 95),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
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
                            'Sign Up', // burada da Sign In
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

                // 2b) ALTTA LACİVERT PANEL + FORM
                Column(
                  children: [
                    const SizedBox(height: 230), // panelin başlangıcı
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
                          // BURADAKİ TOP PADDING'İ BÜYÜTTÜM
                          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
                          child: Column(
                            children: [
                              // Panel içindeki büyük başlık
                              Text(
                                'Sign In', // burada da Sign In
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

                              // FORM SCROLLABLE
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

                                      // SIGN IN BUTONU
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Koyu panel üzerindeki yarı saydam input alanı
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