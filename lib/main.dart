import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/create_match_screen.dart';
import 'pages/match_info_screen.dart';
import 'pages/matches_screen.dart';
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
      initialRoute: '/matches', // Set initial route
      routes: {
        '/matches': (context) => MatchesScreen(),
        '/match-info': (context) => const MatchInfoScreen(),
        '/create-match': (context) => const CreateMatchScreen(),
      },
    );
  }
}
