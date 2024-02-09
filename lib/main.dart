import 'package:flutter/material.dart';
import 'package:ram_trade/pages/profile_screen.dart';
import 'package:ram_trade/pages/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_screen.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://nnglwhgsrkbblfrnsfpg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5uZ2x3aGdzcmtiYmxmcm5zZnBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDcxNzY3OTMsImV4cCI6MjAyMjc1Mjc5M30.aJNNiKFeM-c1ReSOh3gEQMrwwskYDsJRYe65ukgU4_w',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ram Trade',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        // '/': (_) => const SplashPage(),
        '/login': (_) => const LoginScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}
