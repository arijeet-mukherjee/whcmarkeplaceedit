import 'dart:collection';

import 'package:answer_me/models/Merchant.dart';
import 'package:answer_me/screens/HomeMarketplace.dart';
import 'package:answer_me/screens/auth/LoginPhone.dart';
import 'package:answer_me/screens/auth/RegisterWithPhone.dart';
import 'package:answer_me/screens/other/RegisterShop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/AppConfig.dart';
import '../../config/SizeConfig.dart';
import '../../providers/AuthProvider.dart';
import '../../providers/ThemeProvider.dart';
import '../../screens/Tabs.dart';
import '../../screens/auth/Login.dart';
import '../../screens/landing/Onboarding.dart';
import '../../utils/SessionManager.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = 'splash_screen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation heartbeatAnimation;
  SessionManager prefs = SessionManager();
  List mid = [];
  final databaseRef = FirebaseDatabase.instance.reference();
  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    heartbeatAnimation =
        Tween<double>(begin: 300.0, end: 150.0).animate(controller);
    controller.forward().whenComplete(() {
      controller.reverse();
    });
    
  }

  _checkIfFirstTime() async {
    bool firsttime = await prefs.getFirstTime();

    if (firsttime) {
      await prefs.setFirstTime(false);
      _navigateToOnBoardScreen();
    } else {
      //_checkIfLoggedIn();
      //await _checkIfShopAdded();
      _checkIfLoggedInPhone();
    }
  }

  _checkIfLoggedInPhone() async {
    var loggedInUser = await prefs.getUser();
    if (loggedInUser != null) {
      /*  AuthProvider authProvider =
          Provider.of<AuthProvider>(context, listen: false);
      await prefs.getUser().then((user) async {
        if (user.source == null) {
          prefs.getPassword().then((password) {
            if (password != null) {
              authProvider
                  .loginUser(context, user.email, password)
                  .then((user) async {
                if (user != null) _navigateToTabsScreen();
              });
            }
          });
        } else {
          await authProvider.setUser(user);
          _navigateToRegisterShopScreen();
        }
      }); */
      _navigateToRegisterShopScreen();
    } else {
      _navigateToLoginScreen();
    }
  }

  _checkIfLoggedIn() async {
    var loggedInUser = await prefs.getUser();
    if (loggedInUser != null) {
      AuthProvider authProvider =
          Provider.of<AuthProvider>(context, listen: false);
      await prefs.getUser().then((user) async {
        if (user.source == null) {
          prefs.getPassword().then((password) {
            if (password != null) {
              authProvider
                  .loginUser(context, user.email, password)
                  .then((user) async {
                if (user != null) _navigateToTabsScreen();
              });
            }
          });
        } else {
          await authProvider.setUser(user);
          _navigateToTabsScreen();
        }
      });
    } else {
      _navigateToLoginScreen();
    }
  }

  _navigateToOnBoardScreen() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, OnBoardingScreen.routeName);
    });
  }

  _navigateToLoginScreen() {
    Future.delayed(Duration(seconds: 2), () {
      // Navigator.pushReplacementNamed(context, LoginPhoneScreen.routeName);
      Navigator.pushNamed(context, RegisterWithPhoneScreen.routeName);
    });
  }

  _navigateToTabsScreen() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, TabsScreen.routeName);
    });
  }

  _navigateToRegisterShopScreen() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, RegisterShopScreen.routeName);
    });
  }

  _navigateToMarketPlaceScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => HomeMarketplaceScreen()),
    );
  }

  _checkIfPaid() async {
    var paid = await prefs.getPayment();
    if (paid != null) {
      _navigateToMarketPlaceScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    SizeConfig().init(context);
    return AnimatedBuilder(
        animation: heartbeatAnimation,
        builder: (context, widget) {
          return Scaffold(
            backgroundColor: Color(0xFFf2e827),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    theme.isDarkTheme()
                        ? 'assets/images/app_icon_dark.png'
                        : 'assets/images/app_icon.png',
                        
                    //width: SizeConfig.blockSizeHorizontal * 35,
                    width: heartbeatAnimation.value,
                    height: heartbeatAnimation.value,
                  ),
                  /* Text(
              APP_NAME,
              style: TextStyle(
                fontFamily: 'Trueno',
                fontSize: SizeConfig.safeBlockHorizontal * 7,
                color: Theme.of(context).primaryColor,
              ),
            ), */
                ],
              ),
            ),
          );
        });
  }

  Future<void> _checkIfShopAdded() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    
    if(auth.currentUser!=null){
      String midText = auth.currentUser.uid.toString();
    print("midText : " + midText);
    databaseRef.child('/merchant').once().then((DataSnapshot snapshot) {
      //print(todo.toString());
      print(snapshot.value.runtimeType);
      var map = HashMap.from(snapshot.value);
      //print(map.toString());
      map.forEach((key, value) {
        Merchant m = Merchant.fromJson(value);
        print(m.mid);
        mid.add(m.mid);
        print(m.ownername);
        print(m.address);
      });
    });
    bool b = false;
    for (String s in mid) {
      print(s);
      if (s == midText) {
        b = true;
        break;
      }
    }
    if (b) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => HomeMarketplaceScreen()),
      );
    }

  }
  }
}
