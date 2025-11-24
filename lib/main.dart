import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/first_page_screen.dart';
import 'pages/sign_up_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/admin_panel_screen.dart';
import 'pages/create_match_screen.dart';
import 'pages/match_info_screen.dart';
import 'pages/matches_screen.dart';
import 'pages/player_request_screen.dart';
import 'utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CS310 Admin App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kAppGreen,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/', // Set initial route
      routes: {
        '/': (context) => const FirstPageScreen(),      // First
        '/login': (context) => const LoginPage(),       // Sign In
        '/signup': (context) => const SignUpPage(),     // Sign Up
        '/home': (context) => const HomePage(),
        '/matches': (context) => MatchesScreen(),
        '/match-info': (context) => const MatchInfoScreen(),
        '/create-match': (context) => const CreateMatchScreen(),
        '/admin': (context) => const AdminPanelScreen(),
        '/requests': (context) => const PlayerRequestsScreen(),
      },
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        backgroundColor: kAppGreen,
        foregroundColor: Colors.white,
        title: const Text('Main Menu'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 260,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/admin');
                  },
                  child: const Text('Admin Panel'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 260,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kAppGreen),
                    foregroundColor: kAppGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/requests');
                  },
                  child: const Text('Requests Page'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
