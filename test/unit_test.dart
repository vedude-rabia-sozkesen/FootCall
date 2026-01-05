
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_pages/services/prefs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrefsService', () {
    late PrefsService prefsService;

    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      prefsService = PrefsService();
      await prefsService.init();
    });

    test('save and load theme mode', () async {
      await prefsService.saveThemeMode(true);
      expect(prefsService.loadThemeMode(), true);

      await prefsService.saveThemeMode(false);
      expect(prefsService.loadThemeMode(), false);
    });

    test('save and load last tab', () async {
      await prefsService.saveLastTab(1);
      expect(prefsService.loadLastTab(), 1);

      await prefsService.saveLastTab(0);
      expect(prefsService.loadLastTab(), 0);
    });

    test('clear all preferences', () async {
      await prefsService.saveThemeMode(true);
      await prefsService.saveLastTab(1);

      await prefsService.clearAll();

      // After clearing, defaults should be returned
      expect(prefsService.loadThemeMode(), false);
      expect(prefsService.loadLastTab(), 0);
    });
  });
}
