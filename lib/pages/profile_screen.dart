import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ram_trade/main.dart';
import 'package:ram_trade/pages/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImageUrl;
  String? fullName = 'Ram Trade User';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response = await supabase
          .from('profiles')
          .select('first_name, last_name, profile_url')
          .eq('id', user.id)
          .single();

      final data = response;
      setState(() {
        fullName = "${data['first_name']} ${data['last_name']}";
        profileImageUrl = data['profile_url'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget profileImageWidget;
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      profileImageWidget = Image.network(
        profileImageUrl!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      // Use AssetImage when profileImageUrl is not available
      profileImageWidget = Image.asset(
        'assets/images/default-profile-picture.png',
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Sign out'),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: profileImageWidget,
            ),
            const SizedBox(height: 16),
            Text(
              fullName ?? '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
