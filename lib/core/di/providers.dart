import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../services/prefs_service.dart';
import '../../providers/setting_provider.dart';
import '../../services/auth_service.dart';
import '../../services/team_service.dart';
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
  ];
}
