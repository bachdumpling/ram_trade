import 'package:flutter/material.dart';
import 'package:ram_trade/components/profile_picture.dart';
import 'package:ram_trade/pages/login_screen.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  String? _profileImageUrl;
  String? fullName = 'Ram Trade User';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  // Load the user's profile from the database.
  Future<void> _loadUserProfile() async {
    setState(() {
      _loading = true;
    });

    try {
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
    } on PostgrestException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Update the user's profile in the database.
  Future<void> _updateUserProfile(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    final user = supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await supabase.from('profiles').upsert(updates);
      if (mounted) {
        setState(() {
          fullName =
              "${_firstNameController.text.toString()} ${_lastNameController.text.toString()}";
        });

        const SnackBar(
          content: Text('Successfully updated profile!'),
        );
      }
    } on PostgrestException catch (error) {
      SnackBar(
        content: Text(error.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (error) {
      SnackBar(
        content: const Text('Unexpected error occurred'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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

  @override
  bool get wantKeepAlive => true;
}
