import 'package:flutter/material.dart';
import '../mixins/theme_mixin.dart';
import '../utils/colors.dart';
import 'package:provider/provider.dart';
import '../providers/setting_provider.dart';

class FirstPageScreen extends StatelessWidget {
  const FirstPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white, ← SİLİNDİ
      appBar: AppBar(
        title: const Text('FootCall'),
        backgroundColor: kAppGreen,
        foregroundColor: Colors.white,
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              final isDark = settings.isDarkMode;

              return IconButton(
                onPressed: settings.toggleTheme,
                icon: Icon(
                  isDark
                      ? Icons.dark_mode    // Dark moddayken AY
                      : Icons.light_mode,  // Light moddayken GÜNEŞ
                  color: isDark
                      ? Colors.black       // Dark → siyah ay
                      : Colors.white,      // Light → beyaz güneş
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
                  flex: 5,
                  child: Center(
                    child: Image.asset(
                      'lib/images/footcall_logo.png',
                      height: 400,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),

                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: kAppBlueCard,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 28,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Elevate your football journey',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kAppGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/login');
                                },
                                child: const Text('Sign in'),
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: kAppGreen, width: 2),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: const Text('Sign Up'),
                              ),
                            ),
                          ],
                        ),
                      ],
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