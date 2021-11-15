import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/User.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/Tabs.dart';
import 'package:answer_me/screens/auth/ForgotPassword.dart';
import 'package:answer_me/screens/auth/Register.dart';
import 'package:answer_me/screens/auth/RegisterWithPhone.dart';
import 'package:answer_me/screens/other/UnderDevelopment.dart';
import 'package:answer_me/utils/SessionManager.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/AppLogoAndText.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/DefaultButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPhoneScreen extends StatefulWidget {
  static const routeName = 'login_phone_screen';
  @override
  _LoginPhoneScreenState createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  AuthProvider authProvider;
  SessionManager prefs = SessionManager();

  _loginUser() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      String _username = _usernameController.value.text;
      String _password = _passwordController.value.text;

      showLoadingDialog(context, 'Logging in...');
      User user = await authProvider.loginUser(context, _username, _password);

      if (user != null)
        _navigateToDevScreen();
      else
        Navigator.pop(context);
    }
  }

  _navigateToTabsScreen() {
    Navigator.pushReplacementNamed(context, TabsScreen.routeName);
  }

  _navigateToDevScreen() {
    Navigator.pushReplacementNamed(context, UnderDevelopmentScreen.routeName);
  }

  @override
  void initState() {
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: _appBar(theme),
      body: _body(context, theme),
    );
  }

  _appBar(ThemeProvider theme) {
    return AppBar(
      elevation: 0,
      actions: [
        TextButton(
          onPressed: _navigateToDevScreen,//_navigateToTabsScreen,
          child: Text(
            'SKIP',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: theme.isDarkTheme() ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  _body(BuildContext context, ThemeProvider theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: SizeConfig.blockSizeVertical * 8),
          _buildAppLogo(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildInformationFields(),
          SizedBox(height: SizeConfig.blockSizeVertical * 4),
          _buildLoginButton(),
          /* SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildOrText(theme), */
          /* SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildSocialMediaButtons(context), */
          SizedBox(height: SizeConfig.blockSizeVertical * 4),
          _buildNeedAnAccountButton(context, theme),
          SizedBox(height: SizeConfig.blockSizeVertical * 5),
        ],
      ),
    );
  }

  _buildAppLogo() {
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal * 100,
      // height: SizeConfig.blockSizeVertical * 18,
      child: AppLogoAndText(),
    );
  }

  _buildInformationFields() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              label: 'Phone Number',
              controller: _usernameController,
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            CustomTextField(
              label: 'Password',
              obscure: true,
              controller: _passwordController,
              suffix: TextButton(
                onPressed: () => Navigator.pushNamed(
                    context, ForgotPasswordScreen.routeName),
                child: Text(
                  'Forgot?',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildLoginButton() {
    return DefaultButton(text: 'Login', onPressed: _loginUser);
  }

  _buildOrText(ThemeProvider theme) {
    return Center(
      child: Text('Or, login with...',
          style: TextStyle(
            color: theme.isDarkTheme() ? Colors.white24 : Colors.black26,
          )),
    );
  }

  _buildSocialMediaButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 5,
      ),
      child: Row(
        children: [
          _socialMedialButton(
            'assets/images/google.png',
            () => authProvider.loginGoogle(context),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
          _socialMedialButton(
            'assets/images/facebook.png',
            () => authProvider.loginFacebook(context),
          ),
          // if (Platform.isIOS)
          //   Column(
          //     children: [
          SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
          _socialMedialButton(
            'assets/images/apple.png',
            () => authProvider.loginApple(context),
          ),
          //   ],
          // ),
        ],
      ),
    );
  }

  _socialMedialButton(String image, Function onTap) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              SizeConfig.blockSizeHorizontal * 5,
            ),
            side: BorderSide(color: Colors.black12),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2.2),
          child: Image.asset(
            image,
            height: SizeConfig.blockSizeHorizontal * 9.5,
          ),
        ),
        onPressed: onTap,
      ),
    );
  }

  _buildNeedAnAccountButton(BuildContext context, ThemeProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4,
            color: theme.isDarkTheme() ? Colors.white70 : Colors.black54,
          ),
        ),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 1.6),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, RegisterWithPhoneScreen.routeName),
          child: Text(
            'Create one now',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: SizeConfig.safeBlockHorizontal * 4.2,
            ),
          ),
        ),
      ],
    );
  }
}
