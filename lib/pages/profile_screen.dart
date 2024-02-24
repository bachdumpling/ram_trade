import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ram_trade/components/profile_picture.dart';
import 'package:ram_trade/pages/login_screen.dart';
import 'package:ram_trade/pages/view_profile_screen.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:ram_trade/utils/hex_color.dart';
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

  var _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account',
            style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Implement more options
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: ProfilePicture(
                          profileImageUrl: _profileImageUrl,
                          showPlusButton: false,
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
                    ),
                    const SizedBox(width: 16),
                    Text(
                      fullName ?? '',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () {
                    // Navigate to view profile
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ViewProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        "View Profile",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Buying & Selling',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.bag),
            title: const Text('Purchases',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            onTap: () {
              // Navigate to purchases
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.list_bullet),
            title: const Text('Listings',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            onTap: () {
              // Navigate to listings
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.question_circle),
            title: const Text('FAQ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            onTap: () {
              // Navigate to FAQs
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.doc_text),
            title: const Text('Terms & Policies',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            onTap: () {
              // Navigate to terms and policies
            },
          ),
          const Divider(),
          // const Padding(
          //   padding: EdgeInsets.all(16.0),
          //   child: Text(
          //     'Account',
          //     style: TextStyle(
          //       fontSize: 16,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),

          ListTile(
            leading: const Icon(CupertinoIcons.square_arrow_right),
            title: const Text(
              'Sign out',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            onTap: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  var height = MediaQuery.of(context).size.height;
                  var width = MediaQuery.of(context).size.width;

                  return Dialog(
                    insetPadding: EdgeInsets.zero,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SizedBox(
                      height: height - 730,
                      width: width - 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Sign Out',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Are you sure you want to sign out?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          // Spacer(
                          //   flex: 1,
                          // ),
                          const SizedBox(
                            height: 20,
                          ),

                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 6, bottom: 12),
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16), // Adjust the padding
                                    ),
                                    onPressed: () async {
                                      await supabase.auth.signOut();
                                      if (context.mounted) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen()),
                                        );
                                      }
                                    },
                                    child: const Text('Sign Out'),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6, right: 20, bottom: 12),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16), // Adjust the padding
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Close'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          ListTile(
            leading: const Icon(CupertinoIcons.person_badge_minus),
            title: const Text('Delete Account',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            onTap: () {
              // Delete account functionality
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
