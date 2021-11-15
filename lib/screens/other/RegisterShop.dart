import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Merchant.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/HomeMarketplace.dart';
import 'package:answer_me/screens/auth/RegisterWithPhone.dart';
import 'package:answer_me/screens/other/AddShopProduct.dart';
import 'package:answer_me/screens/other/RegisterShopService.dart';
import 'package:answer_me/screens/other/UnderDevelopment.dart';
import 'package:answer_me/utils/SessionManager.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/EmptyScreenText.dart';
import 'package:answer_me/widgets/FeaturedImagePicker.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

class RegisterShopScreen extends StatefulWidget {
  static const routeName = 'register_shop_screen';
  @override
  _RegisterShopScreenState createState() => _RegisterShopScreenState();
}

class _RegisterShopScreenState extends State<RegisterShopScreen> {
  AuthProvider _authProvider;
  AppProvider _appProvider;
  TextEditingController _addressController = TextEditingController();
  TextEditingController _shopnameController = TextEditingController();
  TextEditingController _ownernameController = TextEditingController();
  TextEditingController _pincodeController = TextEditingController();
  SessionManager prefs = SessionManager();
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File _featuredImage;
  File _image;
  String _networkFeaturedImage;
  String _shopService = 'Health Service';
  List mid = [];
  String market = 'N/A';
  final databaseRef = FirebaseDatabase.instance.reference();
  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);
    _checkIfPaid();
    _checkIfShopAdded();
    // myBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          theme.isDarkTheme() ? Colors.black54 : Colors.grey.shade200,
      appBar: _appBar(),
      body: _body(context, theme),
      floatingActionButton: _floatingActionButton(context, theme),
    );
  }

  _appBar() {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text('Registeration Form',
          style: theme.isDarkTheme()
              ? Theme.of(context).textTheme.headline6
              : TextStyle(
                  fontFamily: 'Equinox',
                  fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  color: Colors.white,
                )),
      backgroundColor: theme.isDarkTheme()
          ? ThemeData.dark().scaffoldBackgroundColor
          : kPrimaryColor,
    );
  }

  _body(BuildContext context, ThemeProvider theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildShopImageUpload(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildMarketPlaceTitle(),
          _buildInformationFields(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _chooseService(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildNeedAnAccountButton(context, theme),
        ],
      ),
    );
  }

  _buildNeedAnAccountButton(BuildContext context, ThemeProvider theme) {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.lef,
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 10),
              Text(
                'Already Own Shop ?',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 4,
                  color: theme.isDarkTheme() ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 1.6),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, RegisterWithPhoneScreen.routeName),
                child: Text(
                  'Login Here',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: SizeConfig.safeBlockHorizontal * 4.2,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _buildShopImageUpload() {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: Center(
          child: GestureDetector(
            onTap: () {
              _showPicker(context);
            },
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xffFDCF09),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50)),
                      width: 100,
                      height: 100,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          ),
        ));
  }

  Future getImage() async {
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _featuredImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  _floatingActionButton(BuildContext context, ThemeProvider theme) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 2,
      child: Icon(FluentIcons.arrow_forward_16_filled, color: Colors.white),
      onPressed: () async {
        if (_formKey.currentState.validate() && _image != null) {
          /* showCupertinoModalBottomSheet(
            context: context,
            elevation: 0,
            topRadius: Radius.circular(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            builder: (context) => AskQuestionScreen(),
          ); */
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AddShopProduct(
                    shopname: _shopnameController.text!=''?_shopnameController.text:market,
                    ownername: _ownernameController.text,
                    pincode: _pincodeController.text,
                    address: _addressController.text,
                    image: _image,
                    service: _shopService,
                    //shopproduct: null,
                  )));
          //_navigateToDevScreen();
        } else {
          Toast.show(
            'Enter all details',
            context,
            duration: 2,
          );
        }
      },
    );
  }

  _buildMarketPlaceTitle() {
    return  Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: CustomTextField(
        label: 'Workplace Name',
        controller: _shopnameController,
        ), );

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
            /* CustomTextField(
              label: 'Workplace Name',
              controller: _shopnameController,
            ), */
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            CustomTextField(
              label: 'Owner Name',
              //obscure: true,
              controller: _ownernameController,
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            CustomTextField(
              label: 'Address',
              // obscure: true,
              controller: _addressController,
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            CustomTextField(
              label: 'Pincode',
              type: '1',
              // obscure: true,
              controller: _pincodeController,
            ),
          ],
        ),
      ),
    );
  }

  _navigateToDevScreen() {
    Navigator.pushReplacementNamed(context, UnderDevelopmentScreen.routeName);
  }

  _chooseService() {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service Type',
                style: GoogleFonts.lato(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
              Container(
                width: (MediaQuery.of(context).size.width),
                height: 50,
                padding: const EdgeInsets.all(1.0),
                decoration: new BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade200, width: 0.0),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: _dropDown(),
              ),
              //_dropDown(),
            ],
          ),
        ));
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  _imgFromCamera() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  _dropDown() {
    return DropdownButton<String>(
      value: _shopService,
      //style: TextStyle(color: Colors.black),
      underline: SizedBox(),
      isExpanded: true,
      items: <String>['Health Service', 'Home Service']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 2,
                vertical: SizeConfig.blockSizeVertical * 1.8,
              ),
              child: Text(value)),
        );
      }).toList(),
      hint: Text(
        "Please choose a service",
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      onChanged: (String value) {
        setState(() {
          _shopService = value;
        });
      },
    );
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _checkIfPaid() async {
    var paid = await prefs.getPayment();
    if (paid != null) {
      _navigateToMarketPlaceScreen();
    }
  }

  _navigateToMarketPlaceScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => HomeMarketplaceScreen()),
    );
  }

  _checkIfShopAdded() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
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
