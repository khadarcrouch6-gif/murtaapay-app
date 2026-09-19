import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/app_state.dart';
import 'core/app_auth_helper.dart';
import 'core/somali_localizations.dart';
import 'features/onboarding/splash_screen.dart';
import 'package:murtaaxpay_app/l10n/app_localizations.dart';

import 'package:flutter/scheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Professional Error Handling for Flutter errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("Flutter Error: ${details.exception}");
  };

  // Professional Error Handling for platform/async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("Platform Error: $error");
    debugPrintStack(stackTrace: stack);
    return true; 
  };

  // Configure System UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  final state = AppState();
  try {
    await state.init();
  } catch (e) {
    debugPrint("Failed to initialize AppState: $e");
  }
  
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
      _handleSecurityLock();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isLocked = true;
    }
  }

  bool _isLocked = false;
  bool _isAuthenticating = false;

  Future<void> _handleSecurityLock() async {
    if (widget.appState.biometricEnabled && _isLocked && !_isAuthenticating) {
      _isAuthenticating = true;
      try {
        await Future.delayed(const Duration(milliseconds: 200));
        final authenticated = await AppAuthHelper.authenticateWithBiometrics();
        if (authenticated) {
          setState(() {
            _isLocked = false;
          });
        }
      } finally {
        _isAuthenticating = false;
      }
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
            home: const SplashScreen(),
            builder: (context, child) {
              return Stack(
                children: [
                  GestureDetector(
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
                  ),
                  if (_isLocked && widget.appState.biometricEnabled)
                    Positioned.fill(
                      child: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/images/logo.png',
                                  height: 80,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.lock,
                                      size: 80,
                                      color: Colors.blue)),
                              const SizedBox(height: 24),
                              const Text("App Locked",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _handleSecurityLock,
                                child: const Text("Unlock MurtaaxPay"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
