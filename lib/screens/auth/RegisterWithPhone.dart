import 'dart:collection';

import 'package:answer_me/models/Merchant.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/HomeMarketplace.dart';
import 'package:answer_me/screens/other/Information.dart';
import 'package:answer_me/screens/other/RegisterShop.dart';
import 'package:answer_me/screens/other/UnderDevelopment.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/SessionManager.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/AppLogoAndText.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/DefaultButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:answer_me/models/User.dart' as LU;
import '../../config/SizeConfig.dart';
import 'dart:convert';

class RegisterWithPhoneScreen extends StatefulWidget {
  static const routeName = 'register_phone_screen';

  @override
  _RegisterWithPhoneScreenState createState() =>
      _RegisterWithPhoneScreenState();
}

class _RegisterWithPhoneScreenState extends State<RegisterWithPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber, verificationId;
  String otp, authStatus = "";
  AuthProvider authProvider;
  bool _isLoading = false;
  /* TextEditingController _emailController = TextEditingController(); */
  TextEditingController _usernameController = TextEditingController();
  List mid = [];
  bool _agree = false;
  final databaseRef = FirebaseDatabase.instance.reference();

  _registerUser() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState.validate()) {
      // String _email = _emailController.value.text;
      //String _username = _usernameController.value.text;

      phoneNumber = _usernameController.value.text;

      if (_agree) {
        setState(() {
          _isLoading = true;
        });
        verifyPhoneNumber(context);
        //showLoadingDialog(context, 'Creating Account...');

        /* await ApiRepository.registerUser(context, _username, _email, _password)
            .then((user) {
          Navigator.pop(context);
          if (user != null) {
            Navigator.pop(context);
          }
        }); */
      } else {
        Toast.show(
          'You need to agree to the Terms of Service and Privacy Policy',
          context,
          duration: 2,
        );
      }
    }
  }

  _navigateToInformationScreen(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InformationScreen(title: title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      //leading: AppBarLeadingButton(),
    );
  }

  _body(BuildContext context) {
    print(_isLoading);
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: SizeConfig.blockSizeVertical * 8),
            _buildAppLogo(),
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
            _buildInformationFields(),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            _buildCheckboxTile(),
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
            _buildRegisterButton(),
            SizedBox(height: SizeConfig.blockSizeVertical * 3),
            _isLoading == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> verifyPhoneNumber(BuildContext context) async {
    //_otpDialogBox(context);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91' + phoneNumber,
      timeout: const Duration(seconds: 15),
      verificationCompleted: (AuthCredential authCredential) {
        setState(() {
          authStatus = "Your account is successfully verified";
          _isLoading = false;
        });
      },
      verificationFailed: (Exception authException) {
        setState(() {
          authStatus = "Authentication failed";
          _isLoading = false;
        });
      },
      codeSent: (String verId, [int forceCodeResent]) {
        verificationId = verId;
        setState(() {
          authStatus = "OTP has been successfully send";
          _isLoading = false;
        });
        _otpDialogBox(context).then((value) {});
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        setState(() {
          authStatus = "TIMEOUT";
          _isLoading = false;
        });
      },
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
      child: Column(
        children: [
          // CustomTextField(label: 'Email', controller: _emailController),
          CustomTextField(
            label: 'Phone Number',
            controller: _usernameController,
            hint: 'Enter Phone Number without Code',
          ),
        ],
      ),
    );
  }

  _buildRegisterButton() {
    return DefaultButton(
      text: 'Generate Otp',
      onPressed: () async {
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

        _registerUser();
      },
    );
  }

  _buildCheckboxTile() {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Theme(
      data: ThemeData(
        unselectedWidgetColor:
            theme.isDarkTheme() ? Colors.white70 : Colors.black54,
      ),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: _agree,
        checkColor: Colors.white,
        activeColor: Theme.of(context).primaryColor,
        // checkColor: theme.isDarkTheme() ? Colors.white70 : Colors.black87,
        onChanged: (state) {
          setState(() {
            _agree = state;
          });
        },
        title: Wrap(
          children: [
            _buildWrappedText(
                'By registering, you agreed to the', false, theme),
            GestureDetector(
              onTap: () => _navigateToInformationScreen('Terms and Conditions'),
              child: _buildWrappedText('Terms of Service', true, theme),
            ),
            _buildWrappedText(' and ', false, theme),
            GestureDetector(
              onTap: () => _navigateToInformationScreen('Privacy Policy'),
              child: _buildWrappedText('Privacy Policy.*', true, theme),
            ),
          ],
        ),
      ),
    );
  }

  _buildWrappedText(String text, bool hyperlink, ThemeProvider theme) {
    return Text(
      text,
      style: hyperlink
          ? TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).primaryColor,
            )
          : TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
              fontWeight: FontWeight.w400,
              color: theme.isDarkTheme()
                  ? Colors.white70
                  : Colors.black.withOpacity(0.7),
            ),
    );
  }

  _otpDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter your OTP'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30),
                    ),
                  ),
                ),
                onChanged: (value) {
                  otp = value;
                },
              ),
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              TextButton(
                onPressed: ()async {
                  Navigator.of(context).pop();
                  if (otp != null) {
                    await signIn(otp);
                    //_navigateToDevScreen();
                    _loginUser();
                  }
                },
                child: Text(
                  'Submit',
                ),
              ),
            ],
          );
        });
  }

  Future<void> signIn(String otp) async {
    await FirebaseAuth.instance
        .signInWithCredential(PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    ));
  }

  _loginUser() async {
    FocusScope.of(context).unfocus();
    final FirebaseAuth auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User user) {
            if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
    String midText = auth.currentUser.uid.toString();
    print("midText : " + midText);
    bool b = false;
    for (String s in mid) {
      print(s);
      if (s == midText) {
        b = true;
        break;
      }
    }
    if (b) {
      String _username = _usernameController.value.text;

      SessionManager prefs = SessionManager();
      //showLoadingDialog(context, 'Logging in...');

      prefs.setUser(LU.User(username: _username, email: "example@example.com"));
      prefs.setPayment('1');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => HomeMarketplaceScreen()),
      );
    } else {
      if (_formKey.currentState.validate()) {
        String _username = _usernameController.value.text;

        SessionManager prefs = SessionManager();
        //showLoadingDialog(context, 'Logging in...');

        prefs.setUser(
            LU.User(username: _username, email: "example@example.com"));
        databaseRef
            .child('/registered')
            .push()
            .set({'mobile': _usernameController.text, 'mid': midText});

        _navigateToRegShopScreen();
      }
    }
  }

  _navigateToDevScreen() {
    Navigator.pushReplacementNamed(context, UnderDevelopmentScreen.routeName);
  }

  _navigateToRegShopScreen() {
    Navigator.pushReplacementNamed(context, RegisterShopScreen.routeName);
  }

  _checkIfShopAdded() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String midText = auth.currentUser.uid.toString();
    print("midText : " + midText);
    bool b = false;
    for (String s in mid) {
      print(s);
      if (s == midText) {
        b = true;
        break;
      }
    }
    if (b) {
      String _username = _usernameController.value.text;

      SessionManager prefs = SessionManager();
      //showLoadingDialog(context, 'Logging in...');

      prefs.setUser(LU.User(username: _username, email: "example@example.com"));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => HomeMarketplaceScreen()),
      );
    }
  }
}
