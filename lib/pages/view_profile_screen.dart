import 'package:flutter/material.dart';
import 'package:ram_trade/components/profile_picture.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  ViewProfileScreenState createState() => ViewProfileScreenState();
}

class ViewProfileScreenState extends State<ViewProfileScreen> {
  String? _profileImageUrl;
  String? fullName = 'Ram Trade User';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // WidgetsBinding.instance.addObserver();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ProfilePicture(
              profileImageUrl: _profileImageUrl,
              showPlusButton: true,
              onUpload: (profileImageUrl) async {
                setState(() {
                  _profileImageUrl = profileImageUrl;
                });

                // Update the profile picture URL in the database.
                final userId = supabase.auth.currentUser!.id;
                await supabase.from('profiles').update({
                  'profile_url': profileImageUrl,
                }).eq("id", userId);
              },
            ),
            const SizedBox(height: 16),
            Text(
              fullName!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
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
