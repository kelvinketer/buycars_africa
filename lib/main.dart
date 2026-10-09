import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './dealership_portal_screen.dart';
import './home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tbiqczipawjklaonxipp.supabase.co',
    anonKey: 'sb_publishable_j9PSFiTQ42FWCVdPMx_i3g_lkzWgw5E',
  );

  runApp(const ProviderScope(child: BuyCarsAfricaApp()));
}

class BuyCarsAfricaApp extends StatelessWidget {
  const BuyCarsAfricaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuyCars.Africa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676), // Electric Emerald Accent
          secondary: Color(0xFF00E676),
          surface: Color(0xFF232527), // Elevated Card Surface
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        useMaterial3: true,
      ),
      
      // Default route for all users (Web, Mobile, Desktop)
      initialRoute: '/',
      
      // Map URL paths to their respective screens
      routes: {
        '/': (context) => const HomeScreen(),
        '/admin': (context) => const DealershipPortalScreen(),
      },
    );
  }
}