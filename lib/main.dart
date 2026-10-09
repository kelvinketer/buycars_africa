import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
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
    final bool isDesktop = !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    return MaterialApp(
      title: 'BuyCars.Africa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFF0D47A1),
        ),
        useMaterial3: true,
      ),
      home: isDesktop ? const DealershipPortalScreen() : const HomeScreen(),
    );
  }
}