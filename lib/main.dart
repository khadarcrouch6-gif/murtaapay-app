import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'core/app_theme.dart';
import 'core/app_state.dart';
import 'core/somali_localizations.dart';
import 'features/onboarding/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.init();
  runApp(const MurtaaxPayApp());
}

class MurtaaxPayApp extends StatelessWidget {
  const MurtaaxPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState();
    
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        return MaterialApp(
          title: 'MurtaaxPay',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,
          locale: state.locale,
          localizationsDelegates: const [
            SomaliLocalizationsDelegate(), // Fallback for Somali Material
            SomaliCupertinoLocalizationsDelegate(), // Fallback for Somali Cupertino
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('so'),
            Locale('ar'), 
            Locale('de'),
          ],
          builder: (context, child) {
            return ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
