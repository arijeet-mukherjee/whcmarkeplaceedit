import 'package:answer_me/screens/auth/LoginPhone.dart';
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

class UnderDevelopmentScreen extends StatelessWidget {
  static const routeName = 'dev_screen';

 

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              theme.isDarkTheme()
                  ? 'assets/images/app_icon_dark.png'
                  : 'assets/images/app_icon.png',
              width: SizeConfig.blockSizeHorizontal * 35,
            ),
            Text(
              'UNDER DEVELOPMENT',
              style: TextStyle(
                fontFamily: 'Trueno',
                fontSize: SizeConfig.safeBlockHorizontal * 7,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

