import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// A simple delegate that falls back to English for Material/Cupertino widgets
/// when the locale is Somali. This prevents the "No MaterialLocalizations found" error
/// while allowing the app to use Somali for its own UI strings.
class SomaliLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const SomaliLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // We use the English material localizations as a base for Somali
    // to avoid the Red Screen of Death.
    return await GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(SomaliLocalizationsDelegate old) => false;
}

class SomaliCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const SomaliCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return await GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(SomaliCupertinoLocalizationsDelegate old) => false;
}
