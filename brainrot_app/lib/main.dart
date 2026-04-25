import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/overlay_screen.dart';
import 'providers/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const DopamineTaxApp(),
    ),
  );
}

class DopamineTaxApp extends StatelessWidget {
  const DopamineTaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dopamine Tax',
      debugShowCheckedModeBanner: false,
      color: Colors.transparent,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/block': (context) => const OverlayScreen(),
      },
    );
  }
}
