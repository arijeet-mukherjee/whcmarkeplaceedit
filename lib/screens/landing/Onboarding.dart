import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/screens/auth/Login.dart';
import 'package:answer_me/screens/auth/LoginPhone.dart';
import 'package:answer_me/screens/auth/RegisterWithPhone.dart';
import 'package:flutter/material.dart';
import 'package:minimal_onboarding/minimal_onboarding.dart';

class OnBoardingScreen extends StatelessWidget {
  static const routeName = 'onboarding_screen';

  final onboardingPages = [
    OnboardingPageModel(
      'assets/images/onboarding_1.png',
      'Welcome to',
      '$APP_NAME app. Bring your stores and services online in 5 minutes with us',
    ),
    OnboardingPageModel(
      'assets/images/onboarding_2.jpg',
      'आपका स्वागत है',
      'WHC मार्केट प्लेस ऐप। हमारे साथ 5 मिनट में अपने स्टोर और सेवाओं को ऑनलाइन लाएं',
    ),
    OnboardingPageModel(
      'assets/images/onboarding_3.png',
      'স্বাগতম',
      'WHC মার্কেট প্লেস অ্যাপ। আপনার দোকানে এবং পরিষেবাগুলি 5 মিনিটের মধ্যে আমাদের সাথে আনুন',
    ),
  ];

  _navigateToLoginScreen(BuildContext context) {
    //Navigator.pushReplacementNamed(context, LoginPhoneScreen.routeName);
    Navigator.pushReplacementNamed(context, RegisterWithPhoneScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MinimalOnboarding(
        onboardingPages: onboardingPages,
        color: Theme.of(context).primaryColor,
        dotsDecoration: DotsDecorator(
          activeColor: Theme.of(context).primaryColor,
          size: Size.square(9.0),
          activeSize: Size(18.0, 9.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        onFinishButtonPressed: () => _navigateToLoginScreen(context),
        onSkipButtonPressed: () => _navigateToLoginScreen(context),
      ),
    );
  }
}
