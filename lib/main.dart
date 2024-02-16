// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ram_trade/cubits/profiles/profiles_cubit.dart';
import 'package:ram_trade/cubits/rooms/rooms_cubit.dart';
import 'package:ram_trade/pages/add_listing_screen.dart';
import 'package:ram_trade/pages/home_screen.dart';
import 'package:ram_trade/pages/market_screen.dart';
import 'package:ram_trade/pages/profile_screen.dart';
import 'package:ram_trade/pages/rooms_page.dart';
import 'package:ram_trade/pages/splash_screen.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nnglwhgsrkbblfrnsfpg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5uZ2x3aGdzcmtiYmxmcm5zZnBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDcxNzY3OTMsImV4cCI6MjAyMjc1Mjc5M30.aJNNiKFeM-c1ReSOh3gEQMrwwskYDsJRYe65ukgU4_w',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfilesCubit>(
      create: (context) => ProfilesCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ram Trade',
        theme: appTheme,
        home: const SplashPage(),
        routes: <String, WidgetBuilder>{
          '/home': (_) => const Home(),
          '/login': (_) => const LoginScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/add-listing': (_) => const AddListingScreen(),
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const AddListingScreen(),
    const MarketScreen(),
    const ProfileScreen(),
    BlocProvider<RoomCubit>(
      create: (context) => RoomCubit()..initializeRooms(context),
      child: const RoomsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedFontSize: 1.0,
        unselectedFontSize: 1.0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home, color: Colors.green),
            label: 'Home',
            activeIcon: Icon(CupertinoIcons.house_fill, color: Colors.green),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled, color: Colors.green),
            label: 'Home',
            activeIcon:
                Icon(CupertinoIcons.add_circled_solid, color: Colors.green),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined, color: Colors.green),
            label: 'Market',
            activeIcon: Icon(Icons.storefront_rounded, color: Colors.green),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person, color: Colors.green),
            label: 'Profile',
            activeIcon: Icon(CupertinoIcons.person_fill, color: Colors.green),
          ),
           BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble, color: Colors.green),
            label: 'Profile',
            activeIcon: Icon(CupertinoIcons.chat_bubble_fill, color: Colors.green),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

extension DurationFormattingExtension on Duration {
  String formatTimeDifference() {
    if (inSeconds < 60) {
      return '${inSeconds} ${inSeconds == 1 ? 'sec' : 'secs'}';
    } else if (inMinutes < 60) {
      return '${inMinutes} ${inMinutes == 1 ? 'min' : 'mins'}';
    } else if (inHours < 24) {
      return '${inHours} ${inHours == 1 ? 'hr' : 'hrs'}';
    } else if (inDays < 30) {
      return '${inDays} ${inDays == 1 ? 'day' : 'days'}';
    } else if (inDays < 365) {
      return '${(inDays / 30).floor()} ${((inDays / 30).floor() == 1) ? 'month' : 'months'}';
    } else {
      return '${(inDays / 365).floor()} ${((inDays / 365).floor() == 1) ? 'year' : 'years'}';
    }
  }
}

extension DateTimeExtensions on DateTime {
  Duration differenceFromNow() {
    final now = DateTime.now();
    return now.difference(this);
  }
}
