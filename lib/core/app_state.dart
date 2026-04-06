import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_analytics.dart';

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  final analytics = AppAnalytics();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  double _balance = 12450.80;
  double get balance => _balance;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  // Estonian is not RTL, so we can remove or update this check.
  // Arabic was RTL.
  bool get isRtl => _locale.languageCode == 'ar'; 

  int _selectedNavIndex = 0;
  int get selectedNavIndex => _selectedNavIndex;

  bool _showHomePromo = false;
  bool get showHomePromo => _showHomePromo;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    // Load saved theme
    final savedTheme = _prefs.getString('theme_mode') ?? 'light';
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;

    // Load saved locale
    final savedLocale = _prefs.getString('language_code') ?? 'en';
    _locale = Locale(savedLocale);

    // Load balance (mock)
    _balance = _prefs.getDouble('balance') ?? 12450.80;

    _isInitialized = true;
    notifyListeners();
  }

  void setShowHomePromo(bool show) {
    _showHomePromo = show;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    analytics.logEvent('bottom_nav_click', parameters: {'index': index});
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefs.setString('theme_mode', isDark ? 'dark' : 'light');
    analytics.logEvent('toggle_theme', parameters: {'is_dark': isDark});
    notifyListeners();
  }

  void setLanguage(String langCode) {
    _locale = Locale(langCode);
    _prefs.setString('language_code', langCode);
    analytics.logEvent('set_language', parameters: {'lang': langCode});
    notifyListeners();
  }

  // Validation: Check if balance is sufficient
  bool hasSufficientBalance(double amount) {
    return _balance >= amount;
  }

  void deductBalance(double amount) {
    _balance -= amount;
    _prefs.setDouble('balance', _balance);
    notifyListeners();
  }

  // Helper for translations
  String translate(String en, String so, {String ar = '', String et = '', String de = ''}) {
    switch (_locale.languageCode) {
      case 'so': return so.isNotEmpty ? so : en;
      case 'ar': return ar.isNotEmpty ? ar : en;
      case 'et': return et.isNotEmpty ? et : (so.isNotEmpty ? so : en);
      case 'de': return de.isNotEmpty ? de : en;
      default:   return en;
    }
  }
}
