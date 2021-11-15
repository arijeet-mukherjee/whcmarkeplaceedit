
import 'package:answer_me/screens/auth/ForgotPassword.dart';
import 'package:answer_me/screens/auth/Login.dart';
import 'package:answer_me/screens/auth/LoginPhone.dart';
import 'package:answer_me/screens/auth/Register.dart';
import 'package:answer_me/screens/auth/RegisterWithPhone.dart';
import 'package:answer_me/screens/landing/Onboarding.dart';
import 'package:answer_me/screens/landing/Splash.dart';
import 'package:answer_me/screens/other/EditProfile.dart';
import 'package:answer_me/screens/other/FollowingFollowers.dart';
import 'package:answer_me/screens/other/Information.dart';
import 'package:answer_me/screens/other/Notifications.dart';
import 'package:answer_me/screens/other/QuestionPosted.dart';
import 'package:answer_me/screens/other/RegisterShop.dart';
import 'package:answer_me/screens/other/RegisterShopService.dart';
import 'package:answer_me/screens/other/UnderDevelopment.dart';
import 'package:answer_me/screens/tabs/Search.dart';
import 'package:answer_me/screens/Tabs.dart';
import 'package:flutter/widgets.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  OnBoardingScreen.routeName: (context) => OnBoardingScreen(),
  TabsScreen.routeName: (context) => TabsScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  RegisterScreen.routeName: (context) => RegisterScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  SearchScreen.routeName: (context) => SearchScreen(),
  FollowingFollowersScreen.routeName: (context) => FollowingFollowersScreen(),
  NotificationsScreen.routeName: (context) => NotificationsScreen(),
  EditProfileScreen.routeName: (context) => EditProfileScreen(),
  InformationScreen.routeName: (context) => InformationScreen(),
  QuestionPostedScreen.routeName: (context) => QuestionPostedScreen(),
  LoginPhoneScreen.routeName:(context)=>LoginPhoneScreen(),
  UnderDevelopmentScreen.routeName:(context)=>UnderDevelopmentScreen(),
  RegisterWithPhoneScreen.routeName:(context)=>RegisterWithPhoneScreen(),
  RegisterShopScreen.routeName:(context)=>RegisterShopScreen(),
  RegisterShopService.routeName:(context)=>RegisterShopService(),
};
