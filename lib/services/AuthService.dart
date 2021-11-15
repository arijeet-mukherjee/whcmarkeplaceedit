import 'package:firebase_auth/firebase_auth.dart' as auth;

class AuthService {
  final _auth = auth.FirebaseAuth.instance;

  Future<auth.UserCredential> signInWithCredential(
          auth.AuthCredential credential) =>
      _auth.signInWithCredential(credential);

  Future<void> logout() => _auth.signOut();

  Stream<auth.User> get currentUser => _auth.authStateChanges();
}
