import 'dart:convert';

import 'package:answer_me/models/Shop.dart';
import 'package:answer_me/models/User.dart' as u;
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  final String firstTime = "firstime";
  final String user = "user";
  final String password = "password";
  final String shop = "shop";

  setFirstTime(bool state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(this.firstTime, state);
  }

  Future<bool> getFirstTime() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    bool firsttime;
    firsttime = pref.getBool(this.firstTime) ?? true;
    return firsttime;
  }

  // setLoggedIn(bool state) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool(this.loggedIn, state);
  // }

  // Future<bool> getLoggedIn() async {
  //   final SharedPreferences pref = await SharedPreferences.getInstance();
  //   bool loggedIn;
  //   loggedIn = pref.getBool(this.loggedIn) ?? false;
  //   return loggedIn;
  // }

  Future setUser(u.User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    pref.setString(this.user, userJson);
  }

  Future setPayment(String pay) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    
    pref.setString('pay', pay);
  }

  Future getPayment() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString('pay') != null) {
      String payDone= pref.getString('pay');
      
      return payDone;
    } else
      return null;
  }

  Future setShop(Shop shop) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userJson = jsonEncode(shop.toJson());
    pref.setString(this.shop, userJson);
  }

  Future<u.User> getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString(this.user) != null) {
      Map userMap = jsonDecode(pref.getString(this.user));
      var user = u.User.fromJson(userMap);
      return user;
    } else
      return null;
  }

  Future clearUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove(this.user);
    await pref.remove(this.password);
    // await pref.remove(this.loggedIn);
  }

  Future setPassword(String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(this.password, password);
  }

  Future<String> getPassword() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String password;
    password = pref.getString(this.password) ?? null;
    return password;
  }
}
