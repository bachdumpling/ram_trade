// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ram_trade/pages/home_screen.dart';
import 'package:ram_trade/pages/profile_screen.dart';
import 'package:ram_trade/pages/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_screen.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://nnglwhgsrkbblfrnsfpg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5uZ2x3aGdzcmtiYmxmcm5zZnBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDcxNzY3OTMsImV4cCI6MjAyMjc1Mjc5M30.aJNNiKFeM-c1ReSOh3gEQMrwwskYDsJRYe65ukgU4_w',
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
      home: const SplashPage(),
      routes: <String, WidgetBuilder>{
        '/home': (_) => const Home(),
        '/login': (_) => const LoginScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileScreen(),
    // const LoginScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.green.shade900,

          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.settings),
          //   label: 'Settings',
          // ),
        ],
      ),
    );
  }
}
