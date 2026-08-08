import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/app_state.dart';
import 'core/somali_localizations.dart';
import 'features/onboarding/splash_screen.dart';
import 'l10n/app_localizations.dart';

import 'package:flutter/scheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create the single instance and initialize it
  final state = AppState();
  await state.init();
  
  // Fix for potential font assertion errors in complex layouts
  // by ensuring the scheduler knows when to paint fonts.
  SchedulerBinding.instance.addPostFrameCallback((_) {
    debugPrint("App initialization complete");
  });

  runApp(MurtaaxPayApp(appState: state));
}

class MurtaaxPayApp extends StatefulWidget {
  final AppState appState;
  const MurtaaxPayApp({super.key, required this.appState});

  @override
  State<MurtaaxPayApp> createState() => _MurtaaxPayAppState();
}

class _MurtaaxPayAppState extends State<MurtaaxPayApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.appState.updateMarketRates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.appState,
      child: Selector<AppState, (ThemeMode, Locale)>(
        selector: (context, state) => (state.themeMode, state.locale),
        builder: (context, data, child) {
          final themeMode = data.$1;
          final locale = data.$2;
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              SomaliLocalizationsDelegate(),
              SomaliCupertinoLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              return GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: ResponsiveBreakpoints.builder(
                  child: child!,
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                  ],
                ),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
