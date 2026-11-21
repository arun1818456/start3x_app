import 'package:flutter/foundation.dart' show kIsWeb;
import '../exports.dart';

class SocialAuth {
  Future<UserCredential?> signInWithGoogle() async {
    const List<String> scopes = <String>['email', 'profile'];
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      scopes: scopes,
      clientId: kIsWeb
          ? '704177767512-i1h3085ieeqcdeef254k8ocaamkukaq3.apps.googleusercontent.com'
          : null,
    ).signIn();

    if (googleUser == null) {
      // User cancelled Google sign-in
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    var data = await FirebaseAuth.instance.signInWithCredential(credential);
    return data;
  }
}
