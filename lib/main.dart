import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/di/providers.dart';
import 'providers/setting_provider.dart';
import 'pages/first_page_screen.dart';
import 'pages/sign_up_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/admin_panel_screen.dart';
import 'pages/create_match_screen.dart';
import 'pages/match_info_screen.dart';
import 'pages/matches_screen.dart';
import 'pages/player_request_screen.dart';
import 'pages/teams_screen.dart';
import 'pages/player_info_screen.dart';
import 'pages/my_player.dart';
import 'pages/my_team_page.dart';
import 'pages/create_team_page.dart';
import 'pages/search_screen.dart';
import 'pages/players_screen.dart';
import 'pages/team_chat_page.dart';
import 'utils/colors.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'FootCall',
            debugShowCheckedModeBanner: false,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              primaryColor: kAppGreen,
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                backgroundColor: kAppGreen,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              primaryColor: kAppGreen,
              scaffoldBackgroundColor: const Color(0xFF1E1E1E),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF2D2D2D),
                foregroundColor: Colors.white,
              ),
              cardColor: const Color(0xFF2D2D2D),
            ),
            home: const AuthGate(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignUpPage(),
              '/home': (context) => const HomePage(),
              '/matches': (context) => MatchesScreen(),
              '/match-info': (context) => const MatchInfoScreen(),
              '/create-match': (context) => const CreateMatchScreen(),
              '/admin': (context) => const AdminPanelScreen(),
              '/requests': (context) => const PlayerRequestsScreen(),
              '/teams': (context) => const TeamsScreen(),
              '/player-info': (context) => const PlayerInfoScreen(),
              '/my-player': (context) => const MyPlayerPage(),
              '/my-team': (context) => MyTeamPage(),
              '/create-team': (context) => const CreateTeamPage(),
              '/search': (context) => const SearchPage(),
              '/players': (context) => const PlayersScreen(),
              '/team-chat': (context) => const TeamChatDemo(),
            },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // This is the source of the "bug" - it only decides the home widget.
        // It doesn't clear the navigator stack when logout happens.
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const FirstPageScreen();
      },
    );
  }
}
