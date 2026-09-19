import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:murtaaxpay_app/core/app_state.dart';
import 'package:murtaaxpay_app/core/somali_localizations.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Widget createTestableWidget(Widget child, {AppState? appState}) {
  return ChangeNotifierProvider<AppState>.value(
    value: appState ?? AppState(),
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        SomaliLocalizationsDelegate(),
        SomaliCupertinoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('so', ''),
      ],
      home: child,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
    ),
  );
}

void setupMockSecureStorage() {
  const MethodChannel channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'read':
          return null;
        case 'write':
          return null;
        case 'delete':
          return null;
        case 'deleteAll':
          return null;
        default:
          return null;
      }
    },
  );
}
