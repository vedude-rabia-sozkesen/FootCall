import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../services/prefs_service.dart';
import '../../providers/setting_provider.dart';
import '../../services/auth_service.dart';

class AppProviders {
  static final List<SingleChildWidget> providers = [
    // Services
    Provider<PrefsService>(
      create: (_) => PrefsService()..init(),
    ),
    Provider<AuthService>(
      create: (_) => AuthService(),
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
