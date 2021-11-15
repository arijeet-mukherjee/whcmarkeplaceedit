import 'dart:convert';

import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/models/User.dart';
import 'package:answer_me/screens/Tabs.dart';
import 'package:answer_me/screens/auth/Login.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/services/AuthService.dart';
import 'package:answer_me/utils/SessionManager.dart';
import 'package:answer_me/utils/Utils.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:toast/toast.dart';

class AuthProvider with ChangeNotifier {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  SessionManager prefs = SessionManager();

  final authService = AuthService();
  final googleSignin = GoogleSignIn(scopes: ['email']);
  final FacebookLogin facebookLogin = new FacebookLogin();

  Stream<auth.User> get currentUser => authService.currentUser;

  User _user = User();
  List<Question> _questions = [];
  List<Question> _polls = [];
  List<Question> _bookmarks = [];
  List<Question> _asked = [];
  List<Question> _waiting = [];

  User get user => _user;

  List<Question> get questions => _questions;
  List<Question> get polls => _polls;
  List<Question> get bookmarks => _bookmarks;
  List<Question> get asked => _asked;
  List<Question> get waiting => _waiting;

  Future clearUserNotifications() async {
    this._user.notifications = 0;
    notifyListeners();
  }

  Future setQuestions(List<Question> value) async {
    this._questions = value;
    notifyListeners();
  }

  Future setPolls(List<Question> value) async {
    this._polls = value;
    notifyListeners();
  }

  Future setBookmarks(List<Question> value) async {
    this._bookmarks = value;
    notifyListeners();
  }

  Future setAsked(List<Question> value) async {
    this._asked = value;
    notifyListeners();
  }

  Future setWaiting(List<Question> value) async {
    this._waiting = value;
    notifyListeners();
  }

  Future<bool> setUser(User user) async {
    this._user = user;
    notifyListeners();
    return true;
  }

  Future clearUser() async {
    this._user = null;
    notifyListeners();
  }

  Future<User> loginUser(
      BuildContext context, String username, String password) async {
    User user = await ApiRepository.loginUser(context,
        username: username, password: password);
    if (user != null) {
      if (user.emailVerifiedAt != null) {
        // await prefs.setLoggedIn(true);
        await prefs.setPassword(password);
        await prefs.setUser(user);
        _firebaseMessaging.getToken().then((token) async {
          ApiRepository.setDeviceToken(user.id, token);
        });
        _user = user;

        notifyListeners();
      } else {
        Toast.show(
          'Please check your inbox and verify your email.',
          context,
          duration: 2,
        );
        return null;
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => LoginScreen()),
      );
    }
    return user;
  }



  Future getUserInfo(BuildContext context, int userId) async {
    SessionManager prefs = SessionManager();
    User user = await ApiRepository.getUserInfo(context, userId: userId);
    if (user != null) {
      await prefs.setUser(user);
      this._user = user;
      notifyListeners();
    }
  }

  // google sign in
  loginGoogle(BuildContext context) async {
    try {
      showLoadingDialog(context, 'Logging in...');
      final GoogleSignInAccount googleUser = await googleSignin.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

      showLoadingDialog(context, 'Logging in...');

      //Firebase Sign in
      final result = await authService.signInWithCredential(credential);
      var fbUser = result.user;

      await registerSocialUser(
        context,
        fbUser.displayName,
        fbUser.email,
        fbUser.photoURL,
        fbUser.uid,
        'Google',
      );
    } catch (error) {
      print(error);
      Navigator.pop(context);
    }
  }

  // google sign in
  loginApple(BuildContext context) async {
    try {
      final appleUser = await SignInWithApple.getAppleIDCredential(
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: CLIENT_ID,
          redirectUri: Uri.parse(REDIRECT_URL),
        ),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print(appleUser);

      await registerSocialUser(
        context,
        appleUser.givenName,
        appleUser.email,
        '',
        appleUser.userIdentifier,
        'Apple',
      );
    } catch (error) {
      print(error);
    }
  }

  loginFacebook(BuildContext context) async {
    final result = await facebookLogin.logIn(['email']);
    final token = result.accessToken.token;

    showLoadingDialog(context, 'Logging in...');

    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,picture.width(800).height(800),first_name,last_name,email&access_token=$token');

    final fbUser = json.decode(graphResponse.body);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        await registerSocialUser(
          context,
          fbUser['name'],
          fbUser['email'],
          fbUser['picture']['data']['url'],
          fbUser['id'],
          'Facebook',
        );
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Facebook authentication cancelled by user.');
        Navigator.pop(context);
        break;
      case FacebookLoginStatus.error:
        print('Facebook login error: ${result.errorMessage}');
        Navigator.pop(context);
        break;
    }
  }

  Future registerSocialUser(BuildContext context, var username, var email,
      var avatar, var authId, var source) async {
    await ApiRepository.registerSocialUser(
            context, username, email, avatar, authId, source)
        .then((user) async {
      if (user != null) {
        print(user);
        // await prefs.setLoggedIn(true);
        // await prefs.setPassword(user.password);
        await prefs.setUser(user);
        _firebaseMessaging.getToken().then((token) async {
          ApiRepository.setDeviceToken(user.id, token);
        });
        _user = user;
        notifyListeners();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => TabsScreen()),
        );
      }
    });
  }

  logout() async {
    _user = User();
    authService.logout();
    await facebookLogin.logOut();

    notifyListeners();
  }
  // google sign in end

  clearProfileQuestions() {
    this._questions.clear();
    this._polls.clear();
    this._bookmarks.clear();
    this._asked.clear();
    this._waiting.clear();
  }
}
