import 'package:flutter/material.dart';
import 'package:ram_trade/components/ProfilePicture.dart';
import 'package:ram_trade/main.dart';
import 'package:ram_trade/pages/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _profileImageUrl;
  String? fullName = 'Ram Trade User';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Load the user's profile from the database.
  void _loadUserProfile() async {
    final userId = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('profiles')
        .select('first_name, last_name, profile_url')
        .eq('id', userId)
        .single();

    setState(() {
      fullName = "${data['first_name']} ${data['last_name']}";
      _firstNameController.text = data['first_name'];
      _lastNameController.text = data['last_name'];
      _profileImageUrl = data['profile_url'];
    });
  }

  // Update the user's profile in the database.
  void _updateUserProfile(BuildContext context) async {
    final userId = supabase.auth.currentUser!.id;
    final updates = {
      'id': userId,
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
    };

    try {
      await supabase.from('profiles').upsert(updates).eq('id', userId);

      // Check if the widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        fullName =
            "${_firstNameController.text.toString()} ${_lastNameController.text.toString()}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            ProfilePicture(
                profileImageUrl: _profileImageUrl,
                onUpload: (profileImageUrl) async {
                  setState(() {
                    _profileImageUrl = profileImageUrl;
                  });

                  // Update the profile picture URL in the database.
                  final userId = supabase.auth.currentUser!.id;
                  await supabase.from('profiles').update({
                    'profile_url': profileImageUrl,
                  }).eq("id", userId);
                }),
            const SizedBox(height: 16),
            Text(
              fullName ?? '',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                  ),
                )),
            ElevatedButton(
              onPressed: () async => _updateUserProfile(context),
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
