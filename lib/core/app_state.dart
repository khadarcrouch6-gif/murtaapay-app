import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool get isRtl => _locale.languageCode == 'ar';

  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;

  bool _showHomePromo = false;
  bool get showHomePromo => _showHomePromo;

  void setShowHomePromo(bool show) {
    _showHomePromo = show;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLanguage(String langCode) {
    _locale = Locale(langCode);
    notifyListeners();
  }

  // Helper for translations — supports English, Somali, Arabic, German
  String translate(String en, String so, {String ar = '', String de = ''}) {
    switch (_locale.languageCode) {
      case 'so': return so;
      case 'ar': return ar.isNotEmpty ? ar : en;
      case 'de': return de.isNotEmpty ? de : en;
      default:   return en;
    }
  }
}
