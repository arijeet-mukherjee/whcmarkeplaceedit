import 'package:flutter/material.dart';

//////////////////////////////////////////
///         APP CONFIGUGRATION         ///
//////////////////////////////////////////

// Host URL (Replace it with your host)
// Do not write a forward slash ('/') at the end of the URL.
const String URL = 'https://likemind.online';

// Apple sign in configuration
const CLIENT_ID = 'com.example.answermeservice';
const REDIRECT_URL = 'https://likemind-58637.firebaseapp.com/__/auth/handler';

// The application name
// Note that changing this value won't affect the whole application
// you still have to change it in AndroidManifest.xml for Android
// and in Info.plist for iOS
const String APP_NAME = 'WHC Marketplace';

const Color kPrimaryColor = Colors.orange;//Color(0xFe8604a); // or Colors.red

// The text that will be sent when sharing the app
const String SHARE_TEXT = 'WHC Marketplace';

// Android Google Play Store link URL
const String ANDROID_SHARE_URL =
    'https://play.google.com/store/apps/details?id=com.whc.markeplace';

// iOS Apple Store link URL
const String IOS_SHARE_URL =
    'https://apps.apple.com/us/app/example/id1234567891';

// iOS App Id taken from the developer account
const String IOS_APP_ID = '1234567891';

// How many questions you want to display per load
const int PER_PAGE = 10;
