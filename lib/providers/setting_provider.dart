import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class SettingsProvider extends ChangeNotifier {
  final PrefsService _prefsService;

  bool _isDarkMode = false;
  int _lastSelectedTab = 0;

  SettingsProvider(this._prefsService) {
    _loadSettings();
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  int get lastSelectedTab => _lastSelectedTab;

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {  // 🔥 async yap
    _isDarkMode = _prefsService.loadThemeMode();
    _lastSelectedTab = _prefsService.loadLastTab();
    notifyListeners();
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefsService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  // Set theme directly (ek method)
  Future<void> setTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _prefsService.saveThemeMode(isDark);
    notifyListeners();
  }

  // Save last tab
  Future<void> saveLastTab(int index) async {
    _lastSelectedTab = index;
    await _prefsService.saveLastTab(index);
    notifyListeners();
  }

  // 🔥 DEBUG için: Tüm ayarları göster
  Map<String, dynamic> get debugInfo {
    return {
      'theme_mode': _isDarkMode,
      'last_tab': _lastSelectedTab,
      'prefs_initialized': true,
    };
  }
}