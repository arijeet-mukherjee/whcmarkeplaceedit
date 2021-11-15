import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:provider/provider.dart';

class AppLogoAndText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /* Image.asset(
          theme.isDarkTheme()
              ? 'assets/images/app_icon_dark.png'
              : 'assets/images/app_icon.png',
          width: SizeConfig.blockSizeHorizontal * 24,
        ), */
        Text(
          APP_NAME,
          style: TextStyle(
            fontFamily: 'Trueno',
            fontSize: SizeConfig.safeBlockHorizontal * 7,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
