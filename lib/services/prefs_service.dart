import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  SharedPreferences? _prefs;

  // Keys
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLastTab = 'last_selected_tab';

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme Mode
  Future<void> saveThemeMode(bool isDark) async {
    await _prefs?.setBool(_keyThemeMode, isDark);
  }

  bool loadThemeMode() {
    return _prefs?.getBool(_keyThemeMode) ?? false; // Default: light mode
  }

  // Last Selected Tab
  Future<void> saveLastTab(int tabIndex) async {
    await _prefs?.setInt(_keyLastTab, tabIndex);
  }

  int loadLastTab() {
    return _prefs?.getInt(_keyLastTab) ?? 0; // Default: first tab
  }

  // Clear all preferences (for logout, etc.)
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}