import 'dart:io';
import 'dart:math';

import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Merchant.dart';
import 'package:answer_me/models/Product.dart';
import 'package:answer_me/models/ShopProduct.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/HomeMarketplace.dart';
import 'package:answer_me/screens/Tabs.dart';
import 'package:answer_me/screens/other/AddShopProduct.dart';
import 'package:answer_me/screens/other/ShopServiceWidget.dart';
import 'package:answer_me/screens/other/UnderDevelopment.dart';
import 'package:answer_me/utils/SessionManager.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/EmptyScreenText.dart';
import 'package:answer_me/widgets/FeaturedImagePicker.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:firebase_database/firebase_database.dart';

class RegisterShopService extends StatefulWidget {
  static const routeName = 'register_shop_service_screen';

  final String shopname;
  final String ownername;
  final String pincode;
  final String service;
  final String address;
  final File image;
  final List<ShopProduct> shopproduct;

  const RegisterShopService(
      {Key key,
      this.shopname,
      this.ownername,
      this.pincode,
      this.service,
      this.address,
      this.image,
      this.shopproduct})
      : super(key: key);

  @override
  _RegisterShopServiceState createState() => _RegisterShopServiceState();
}

class _RegisterShopServiceState extends State<RegisterShopService> {
  String shopname;
  String ownername;
  String pincode;
  String service;
  String address;
  File image;
  List<ShopProduct> shopproduct;
  final databaseRef = FirebaseDatabase.instance.reference();
  String shopimageUrl = '';
  SessionManager prefs = SessionManager();
  static const platform = const MethodChannel("razorpay_flutter");
  int pay = 120000;
  Razorpay _razorpay;
  @override
  void initState() {
    shopname = widget.shopname;
    ownername = widget.ownername;
    pincode = widget.pincode;
    service = widget.service;
    image = widget.image;
    address = widget.address;
    shopproduct = widget.shopproduct;

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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

  int getAmount(String i) {
    switch (i) {
      case 'Groceries shop':
        return 60000;
        break;
      case 'Vegetable shop':
        return 30000;
        break;
      case 'Mutton & Chicken shop':
        return 120000;
        break;
      case 'Fish shop':
        return 60000;
        break;
      case 'Restaurant':
        return 120000;
        break;
      case 'Fruit shop':
        return 60000;
        break;
      case 'Ice-cream parlar':
        return 120000;
        break;
      case 'Home food supplier':
        return 120000;
        break;
      case 'Sweet shop':
        return 120000;
        break;
      case 'Bakery Food & Cake':
        return 120000;
        break;

      case 'Electronics store':
        return 120000;
        break;
      case 'Electrical Repairing':
        return 120000;
        break;
      case 'Mobile repairing & selling store':
        return 120000;
        break;
      case 'Air conditioner repairing':
        return 120000;
        break;
      case 'Fridge, washing machine, water hitter geyser repairing person / shop':
        return 120000;
        break;
      case 'Inverter & Battery':
        return 120000;
        break;
      case 'Computer Service & Repairing':
        return 120000;
        break;
      case 'Car & Bike Repairing':
        return 120000;
        break;
      case 'Toto & Auto Repairing':
        return 120000;
        break;
      case 'Toto Service':
        return 30000;
        break;
      case 'Auto Service':
        return 30000;
        break;
      case 'Car Service':
        return 50000;
        break;
      case 'Dry Cleaning and Laundry':
        return 60000;
      case 'Made & Cook for Home local':
        return 40000;
      case 'Home Cleaning person(girl, Boy)':
        return 40000;
        break;
      case 'Gardening mali':
        return 40000;
        break;
      case 'Purohit / Priest':
        return 60000;
        break;
      case 'Pest Control':
        return 40000;
        break;
      case 'Home Cleaning':
        return 120000;
        break;
      case 'Land Building Flat Rent Buy and Sales':
        return 120000;
        break;
      case 'Home painting color':
        return 60000;
        break;
      case 'Construction':
        return 120000;
        break;
      case 'Tiles Work':
        return 120000;
        break;
      case 'Plumber & Waters':
        return 60000;
        break;
      case 'Furniture Fitting':
        return 120000;
        break;
      case 'Interior decorator':
        return 120000;
        break;
      case 'Carpentary Work':
        return 60000;
        break;
      case 'Photographery services':
        return 60000;
        break;
      case 'Beauty Parlor Saloon barber':
        return 60000;
        break;
      case 'Catering party & Event management':
        return 120000;
        break;
      case 'Gift Items':
        return 60000;
        break;
      case 'Flower Service':
        return 120000;
        break;
      case 'Education Accessories':
        return 60000;
        break;
      case 'Ticket Booking & Trading':
        return 60000;
        break;
      case 'Movers & Packers':
        return 60000;
        break;
      case 'Printing Service(Xerox/etc)':
        return 60000;
        break;
      case 'Courier Service':
        return 40000;
        break;
      case 'Internet & Broadband':
        return 120000;
        break;
      case 'CCTV & Security':
        return 120000;
        break;
      case 'Online Education':
        return 120000;
        break;
      case 'Education & Tution Class':
        return 120000;
        break;
      case 'Dancing Class':
        return 120000;
        break;
      case 'Singing Class':
        return 120000;
        break;
      case 'Judo,Karate & Marshal Art':
        return 120000;
        break;
      case 'Yoga Class':
        return 120000;
        break;
      case 'Legal Adviser':
        return 120000;
        break;
      case 'Account Adviser':
        return 120000;
        break;
      case 'Astrology':
        return 120000;
        break;
      case 'Gold Jewellery':
        return 120000;
        break;
      case 'Garment shops':
        return 120000;
        break;
      case 'School Dress':
        return 120000;
        break;
      case 'Fashionable Dress Man,Women,Kids':
        return 120000;
        break;
      case 'Nurse':
        return 120000;
        break;
      case 'Doctor':
        return 120000;
        break;
      case 'Physiotherapy':
        return 120000;
        break;
      case 'Aaya & Grand Mother':
        return 60000;
        break;
      case 'Caretaker & Attainder (Boy/Girl)':
        return 60000;
        break;
      case 'Ambulance Service':
        return 60000;
        break;
      case 'Medical Store':
        return 120000;
        break;
      case 'Pathology test lab':
        return 120000;
        break;
      case 'Medical surgical equipment supplier & stores':
        return 120000;
        break;
      case 'Babysitter':
        return 60000;
        break;
    }
    return 120000;
  }

  _appBar() {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return AppBar(
      centerTitle: true,
      leading: AppBarLeadingButton(
        color: Colors.white,
      ),
      title: Text('Review & Pay',
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
      /* actions: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 1,
              vertical: SizeConfig.blockSizeVertical * 1.2,
            ),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: ThemeData.dark().scaffoldBackgroundColor,
              ),
              onPressed: () => {},
              child: Text(
                'Pay',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ] */
    );
  }

  _body(BuildContext context, ThemeProvider theme) {
    print(shopname + ownername);
    return shopproduct != null
        ? Stack(children: [
            ListView(children: [
              SizedBox(height: SizeConfig.blockSizeVertical * 3),
              _amountPayable(),
              SizedBox(height: SizeConfig.blockSizeVertical * 1),
              _buildShopImage(),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              _shopName(),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              _ownerName(),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              _address(),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              _pincode(),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              _serviceType(),
              SizedBox(height: SizeConfig.blockSizeVertical * 3),
              CategorySection(
                service: service,
                shopProduct: shopproduct,
              ),
            ])
          ])
        : Center(
            child: Text(
            'No Product Added Yet!',
            textAlign: TextAlign.center,
          ));
  }

  _buildShopImage() {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: Center(
          child: GestureDetector(
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xffFDCF09),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        image,
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

  _floatingActionButton(BuildContext context, ThemeProvider theme) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 2,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('Pay',
                style: TextStyle(
                  fontFamily: 'Equinox',
                  //fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  color: Colors.white,
                )),
            Icon(FluentIcons.arrow_forward_16_filled, color: Colors.white)
          ]),
      onPressed: () async {
        await uploadShopImageToFirebase(context);
        print(shopimageUrl);
        openCheckout();
      },
    );
  }

  _shopName() {
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
                'Shop Name',
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
                  child: Center(
                    child: Text(
                      shopname,
                      style: GoogleFonts.lato(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                        color: Colors.black54,
                      ),
                    ),
                  )),
              //_dropDown(),
            ],
          ),
        ));
  }

  _ownerName() {
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
                'Owner Name',
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
                  child: Center(
                    child: Text(
                      ownername,
                      style: GoogleFonts.lato(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                        color: Colors.black54,
                      ),
                    ),
                  )),
              //_dropDown(),
            ],
          ),
        ));
  }

  _address() {
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
                'Address',
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
                  child: Center(
                    child: Text(
                      address,
                      style: GoogleFonts.lato(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                        color: Colors.black54,
                      ),
                    ),
                  )),
              //_dropDown(),
            ],
          ),
        ));
  }

  _pincode() {
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
                'Pincode',
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
                  child: Center(
                    child: Text(
                      pincode,
                      style: GoogleFonts.lato(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                        color: Colors.black54,
                      ),
                    ),
                  )),
              //_dropDown(),
            ],
          ),
        ));
  }

  _serviceType() {
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
                  child: Center(
                    child: Text(
                      service,
                      style: GoogleFonts.lato(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                        color: Colors.black54,
                      ),
                    ),
                  )),
              //_dropDown(),
            ],
          ),
        ));
  }

  _amountPayable() {
    String s = shopproduct.length > 0
        ? getAmount(shopproduct[0].category).toString()
        : '120000';
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
                'Payable Amount: ' + s,
                style: TextStyle(
                  fontFamily: 'Equinox',
                  fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.5),

              //_dropDown(),
            ],
          ),
        ));
  }

  Future uploadShopImageToFirebase(BuildContext context) async {
    String fileName = p.basename(image.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(image);

    await uploadTask.then((res) {
      res.ref.getDownloadURL().then((value) => {
            /* setState(() {
        shopimageUrl = value;
      }) */
            shopimageUrl = value,
            print(value)
          });
    });
  }

  //Razorpay Integration
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Toast.show("SUCCESS: " + response.paymentId, context, duration: 2);
    prefs.setPayment('Paid');

    final FirebaseAuth auth = FirebaseAuth.instance;
    String mid = auth.currentUser.uid.toString();
    Map<dynamic, dynamic> product = new Map<dynamic, dynamic>();
    int i = 0;

    for (ShopProduct s in shopproduct) {
      Products p = new Products(
          image: s.image, category: s.category, name: s.name, price: s.price);

      product[i.toString()] = p.toJson();
      i++;
    }
    print(product.toString());
    Merchant merchant = new Merchant(
        mid: mid,
        shopname: shopname,
        shopimage: shopimageUrl,
        ownername: ownername,
        address: address,
        pincode: pincode,
        servicetype: service,
        paid: "1",
        paymentid: response.paymentId,
        products: product);
    databaseRef.child('/merchant').push().set(merchant.toJson());
    prefs.setPayment("1");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (ctx) => HomeMarketplaceScreen()),
    );
    //Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Toast.show("ERROR: " + response.code.toString() + " - " + response.message,
        context,
        duration: 2);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Toast.show(
      "EXTERNAL_WALLET: " + response.walletName,
      context,
      duration: 2,
    );
  }

  void openCheckout() async {
    int amt =
        shopproduct.length > 0 ? getAmount(shopproduct[0].category) : 120000;
    var options = {
      'key': 'rzp_test_oyFwlUfsQJgOWz',
      'amount': amt,
      'name': 'WHC Marketplace',
      'description': 'Registration Fee',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error:' + e.toString());
    }
  }
}
