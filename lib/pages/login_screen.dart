import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ram_trade/utils/constants.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _googleSignIn(),
          child: const Text('Sign in with Google'),
        ),
      ),
    );
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