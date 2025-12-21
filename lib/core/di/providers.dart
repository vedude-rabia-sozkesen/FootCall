import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../services/prefs_service.dart';
import '../../providers/setting_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/matches_provider.dart';
import '../../providers/teams_provider.dart';
import '../../services/auth_service.dart';
import '../../services/team_service.dart';
import '../../services/match_service.dart';
import '../../services/match_request_service.dart';
import '../../services/chat_service.dart';

class AppProviders {
  static final List<SingleChildWidget> providers = [
    // Services
    Provider<PrefsService>(
      create: (_) => PrefsService()..init(),
    ),
    Provider<AuthService>(
      create: (_) => AuthService(),
    ),
    Provider<TeamService>(
      create: (_) => TeamService(),
    ),
    Provider<MatchService>(
      create: (_) => MatchService(),
    ),
    Provider<MatchRequestService>(
      create: (_) => MatchRequestService(),
    ),
    Provider<ChatService>(
      create: (_) => ChatService(),
    ),

    // Providers
    ChangeNotifierProxyProvider<PrefsService, SettingsProvider>(
      create: (context) => SettingsProvider(
        Provider.of<PrefsService>(context, listen: false),
      ),
      update: (context, prefsService, previous) =>
      previous ?? SettingsProvider(prefsService),
    ),
    
    // Auth Provider
    ChangeNotifierProxyProvider<AuthService, AuthProvider>(
      create: (context) => AuthProvider(
        Provider.of<AuthService>(context, listen: false),
      ),
      update: (context, authService, previous) =>
      previous ?? AuthProvider(authService),
    ),
    
    // Matches Provider
    ChangeNotifierProxyProvider<MatchService, MatchesProvider>(
      create: (context) => MatchesProvider(
        Provider.of<MatchService>(context, listen: false),
      ),
      update: (context, matchService, previous) =>
      previous ?? MatchesProvider(matchService),
    ),
    
    // Teams Provider
    ChangeNotifierProxyProvider<TeamService, TeamsProvider>(
      create: (context) => TeamsProvider(
        Provider.of<TeamService>(context, listen: false),
      ),
      update: (context, teamService, previous) =>
      previous ?? TeamsProvider(teamService),
    ),
  ];
}
