import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/AppTheme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme;
  Typography defaultTypography;
  SharedPreferences prefs;
  bool _isDarkTheme = false;

  ThemeProvider(bool darkThemeOn) {
    if (darkThemeOn) {
      _selectedTheme = AppTheme.dark;
      _isDarkTheme = darkThemeOn;
    } else {
      _selectedTheme = AppTheme.light;
      _isDarkTheme = darkThemeOn;
    }
  }

  Future<void> swapTheme() async {
    prefs = await SharedPreferences.getInstance();

    if (_selectedTheme == AppTheme.dark) {
      _selectedTheme = AppTheme.light;
      _isDarkTheme = false;
      await prefs.setBool("darkTheme", false);
    } else {
      _selectedTheme = AppTheme.dark;
      _isDarkTheme = true;
      await prefs.setBool("darkTheme", true);
    }

    notifyListeners();
  }

  ThemeData getTheme() => _selectedTheme;

  bool isDarkTheme() => _isDarkTheme;
}
