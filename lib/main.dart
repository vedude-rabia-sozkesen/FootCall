import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

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
import 'pages/search_screen.dart';
import 'pages/players_screen.dart';
import 'pages/team_chat_page.dart';
import 'utils/colors.dart';

// Firebase options dosyasını import et (oluşturman gerekecek)
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 DEBUG: Firebase başlatma logları ekliyorum
  print('=' * 50);
  print('🚀 FootCall Uygulaması Başlatılıyor');
  print('=' * 50);

  try {
    print('🔄 Firebase başlatılıyor...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 🔥 BAŞARILI: Firebase bağlantısı kuruldu
    print('✅ Firebase başarıyla başlatıldı!');
    print('📱 Platform: ${DefaultFirebaseOptions.currentPlatform.appId}');
    print('🔧 Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}');

  } catch (e) {
    // 🔥 HATA: Firebase bağlantısı başarısız
    print('❌❌❌ CRITICAL ERROR: Firebase başlatma başarısız! ❌❌❌');
    print('❌ Hata detayı: $e');
    print('=' * 50);
    rethrow; // Hatayı yukarı fırlat
  }

  // 🔥 DEBUG: Uygulama başlatılıyor
  print('🎯 Flutter uygulaması başlatılıyor...');
  print('=' * 50);

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
          // 🔥 DEBUG: Settings bilgilerini göster
          print('🎨 Settings yüklendi:');
          print('   • Tema modu: ${settings.isDarkMode ? "🌙 Dark" : "☀️ Light"}');
          print('   • Son tab: ${settings.lastSelectedTab}');

          return MaterialApp(
            title: 'FootCall',
            debugShowCheckedModeBanner: false,

            // ThemeMode ekledik
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // Light Theme
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

            // Dark Theme eklendi
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

            initialRoute: '/',
            routes: {
              '/': (context) => const FirstPageScreen(),
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
              const SizedBox(height: 16),
              SizedBox(
                width: 260,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/teams');
                  },
                  child: const Text('Teams Screen'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 260,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/player-info',
                        arguments: '34731');
                  },
                  child: const Text('Player Info Screen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}