import 'package:flutter/foundation.dart';

class AppAnalytics {
  static final AppAnalytics _instance = AppAnalytics._internal();
  factory AppAnalytics() => _instance;
  AppAnalytics._internal();

  void logScreenView(String screenName) {
    if (kDebugMode) {
      print('Analytics: [ScreenView] $screenName');
    }
    // In a real app, you would call FirebaseAnalytics.instance.logScreenView(...)
  }

  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      print('Analytics: [Event] $name parameters: $parameters');
    }
    // In a real app, you would call FirebaseAnalytics.instance.logEvent(...)
  }

  void logTransaction(String type, double amount, String currency) {
    if (kDebugMode) {
      print('Analytics: [Transaction] $type amount: $amount $currency');
    }
    logEvent('transaction', parameters: {
      'type': type,
      'amount': amount,
      'currency': currency,
    });
  }
}
