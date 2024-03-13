// ignore_for_file: sort_child_properties_last
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ram_trade/utils/constants.dart';
import 'package:ram_trade/utils/hex_color.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ram_trade/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  void _setupAuthListener() {
    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        }
      }
    });
  }

  Future<void> _googleSignIn() async {
    const webClientId =
        '907456851423-9gq0fj471scnt10agb8henf57irf42si.apps.googleusercontent.com';
    const iosClientId =
        '907456851423-1gjknjh7cvgu8nesc9092t41gqcu4rmm.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Google Sign In was cancelled by the user.')),
        );
        return;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No access or ID token found.')),
        );
        return;
      }

      final String? email = googleUser.email;
      // if (email == null || !email.endsWith('@fordham.edu')) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('Only Fordham University emails are allowed.',
      //           textAlign: TextAlign.center,
      //           style: TextStyle(
      //               fontWeight: FontWeight.bold,
      //               fontSize: 14,
      //               color: Colors.red)),
      //     ),
      //   );
      //   return;
      // }

      //  If the email domain is correct, proceed with the sign in
      final authResponse = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (authResponse.user != null) {
        _createOrUpdateUserProfile(authResponse.user as User);
      } else {
        throw 'An error occurred while signing in.';
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign In failed: $error')),
      );
    }
  }

  void _createOrUpdateUserProfile(User user) async {
    final profileResult =
        await supabase.from('profiles').select().eq('id', user.id);

    if (profileResult.isEmpty) {
      // Split the full name to get the first and last name
      List<String> names =
          user.userMetadata?['full_name']?.split(" ") ?? ["", ""];
      String firstName = names[0];
      String lastName =
          names.length > 1 ? names.skip(1).toList().join(" ") : "";

      await supabase.from('profiles').upsert({
        'id': user.id,
        'first_name': firstName,
        'last_name': lastName,
        'profile_url': user.userMetadata?['avatar_url']
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/splash-screen-image.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          // Overlay with semi-transparent black color
          Container(
            color: Colors.black.withOpacity(0.2), // Adjust opacity as needed
          ),
          // Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.center,
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const Text(
                            'Discover what your fellow Rams have to offer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Marketplace to buy, sell or trade items amongst Fordham students',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: HexColor("#888888"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _googleSignIn(),
                        child: const Text("Continue with Google"),
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// if (authResponse.user != null) {
//   // Assuming you have a method to check if the user profile exists.
//   bool profileExists = await _checkUserProfileExists(authResponse.user!.id);
//   if (!profileExists) {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const OnboardingScreen()),
//     );
//   } else {
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => const ProfileScreen()),
//     );
//   }
// } else {
//   throw 'An error occurred while signing in.';
// }