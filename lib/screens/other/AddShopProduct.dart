import 'dart:io';
import 'dart:math';

import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/ShopProduct.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/RegisterShopService.dart';
import 'package:answer_me/screens/other/UnderDevelopment.dart';
import 'package:answer_me/utils/Utils.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/EmptyScreenText.dart';
import 'package:answer_me/widgets/FeaturedImagePicker.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class AddShopProduct extends StatefulWidget {
  final String shopname;
  final String ownername;
  final String pincode;
  final String service;
  final String address;
  final File image;
  const AddShopProduct({
    Key key,
    this.service,
    this.shopname,
    this.ownername,
    this.pincode,
    this.address,
    this.image,
  }) : super(key: key);
  @override
  _AddShopProductState createState() => _AddShopProductState();
}

class _AddShopProductState extends State<AddShopProduct> {
  TextEditingController _productnameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  String _productCategory;
  String _service;
  List<ShopProduct> shopProduct = [];
  String shopname;
  String ownername;
  String pincode;
  String service;
  String address;
  File shopImage;
  int priceCustomer = 0;
  static final _formKey2 = const Key('__RIKEY1__');
  int totalproducts = 0;
  final picker = ImagePicker();
  File _featuredImage;
  String _featuredImageString;
  //String _serviceHealthName = [];
  String servicename;
  List<String> servicenameList = [];
  
  Map<String, List<String>> _serviceHealth = {
    /* 'Patient Care Service': [
      'Post Hospitalization Care',
      'Post Surgical Care',
      'Paliative / End of Life care',
      'Critical / ICU level care'
    ], */
    //'Live-in Care': [],
    'Aaya/ Grand Mother': [
      'Old age care',
      'Domestic Care',
      'Parkinson Care',
      'Paralytic Patient Care',
      'Domicilliary Care',
      'Hygine and grooming',
      'Prepare meals and feed for elderly',
      'Assist in booking appointment with doctor',
      'Monitoring BP, temperature',
      'Oral medication under your supervision',
      'Assistance in shopping and groceries'
    ],
    //'COVID Care': [],
    'Medical surgical equipment supplier / store': [
      'Patient Bed(Manual)',
      'Patient Bed(Motorized)',
      'Oxygen Concentrator',
      'Bipap',
      'Ventilator',
      'IV Stand',
      'Cardiac Monitor',
      'Cpap',
      'Infusion Pump',
      'DVT Pump',
      'Suction Machine',
      'Motorized reclinder bed'
    ],
    /* 'Sanitization': [
      '1BHK Sanitization',
      '2BHK Sanitization',
      '3BHK Sanitization',
      '4BHK Sanitization',
      'Personal Full House'
    ], */
    'Nurse': [
      'Short Nursing Visit',
      'Day Care by nurse',
      'Night care by nurse',
      'Live-in care resident nursing care',
      'ICU nursing care rotational 24X7 care'
    ],
    'Doctor': [
      'Complete body checkup',
      'Medical Procedure',
      'Medical Emergency',
      'Pain Management',
      'Diabetes management'
    ],
    'Physiotherapy': [
      'Heat Thearpy',
      'Accupunture',
      'Joint mobilization and manipulation',
      'Soft tissue mobilization',
      'Cold therapy / Crypto therapy',
      'Muscle imbalance correction',
      'Excercise and stretching regines'
    ],
    'Caretaker / Attainder (Boy/Girl)': [
      'Neo Nantal Care',
      'Grand Nany Care',
      'Babysitter',
      'Pediatrics on call',
      'Pediatrician'
    ],
    /* 'Elderly Caretaker': [
      'Hygine and grooming',
      'Prepare meals and feed for elderly',
      'Assist in booking appointment with doctor',
      'Monitoring BP, temperature',
      'Oral medication under your supervision',
      'Assistance in shopping and groceries'
    ], */
    'Babysitter': [
      'Baby Care',
      'Prepare meals and feed',
      'Organize & take part in leisure activity',
      'Ethics and discipline building',
      'Hygine and cleaniless',
      'Maintainance and tracking daily activities report',
      'Teaching skills',
      'Toilet training',
      'Prevent Household Injuries'
    ],
    'Ambulance Service': ['Ambulance Services'],
    'Pathology test lab': ['Blood Test', 'All pathological test'],
    'Medical Store': [
      'DVT Pump',
      'Suction Machine',
      'Motorized reclinder bed',
      'Other Medical Equipments'
    ],
  };

  List<String> heathCategory = [
    'Aaya/ Grand Mother',
    'Caretaker / Attainder (Boy/Girl)',
    'Ambulance Service',
    'Nurse',
    'Doctor',
    'Physiotherapy',
    'Medical Store',
    'Babysitter',
    'Pathology test lab',
    'Medical surgical equipment supplier / store'
  ];
  /* List<String> homeCategory = [
    'Groceries local shop',
    'Vegetable shop',
    'Mutton / Chicken Shop',
    'Fish Shop',
    'Restaurant',
    'Sweet shop',
    'Electric store',
    'Electrical Electronic local repairing person',
    'Mobile repairing person / shop / Mobil selling store',
    'Air conditioner, fridge, washing machine, water hitter geyser, inverter, ups power supply, computer -  repairing person / shop / selling store',
    'Car Drive',
    'Dry Cleaning and Laundry person / laundry shop',
    'Gold jewelry shop / jewelry making & repairing shop / jewelry marketing person',
    'Internet / Broadband consultant / service provider',
    'CCTV Fire Alarm service provider person / shop',
    'Plumber /  Waters tank cleaner / water supplier / plumbing related hardware shop',
    'Photographer / shop/ photo / video editing shop',
    'Beauty Parlor Saloon barber',
    'Dry Cleaning and Laundry person / laundry shop',
    'Made  / Cook for Home local',
    'Home Cleaning person(girl, Boy)',
    'Gardening mali local /  nursery',
    'Home painter / Color hardware store',
    'Carpentry Work carpenter / wood supplier / play supplier / hardware shop',
    'Ice-cream parlar',
    'Toto driver / Auto driver',
    'Interior dingier / material supplier hardware shop',
    'Online ticket booking & Trading office',
    'Tailor (new / old) individual / tailor shop',
    'legal Adviser civil lower / crime lower / legal adviser office',
    'Account Adviser office / chatter  / person',
    'Online Education provider / academic adviser',
    'Garment  shop',
    'School Dress maker person / seller shop',
    'Land Building Flat Rent Buy and Sales propriety broker',
    'Furniture Fitting / maker person '
  ]; */
  List<String> homeCategory = [
    'Groceries shop',
    'Vegetable shop',
    'Mutton & Chicken shop',
    'Fish shop',
    'Restaurant',
    'Home food supplier',
    'Sweet shop',
    'Fruit shop',
    'Ice-cream parlar',
    'Bakery Food & Cake',
    'Electric store',
    'Electrical Electronic repairing',
    'Mobile repairing & selling store',
    'Air conditioner repairing',
    'Fridge, washing machine, water hitter geyser repairing person / shop',
    'Inverter & Battery',
    'Computer Service & Repairing',
    'Car & Bike Repairing',
    'Toto & Auto Repairing',
    'Toto Service',
    'Auto Service',
    'Car Service',
    'Dry Cleaning and Laundry',
    'Made & Cook for Home local',
    'Home Cleaning person(girl, Boy)',
    'Gardening mali',
    'Purohit / Priest',
    'Pest Control',
    'Home Cleaning',
    'Land Building Flat Rent Buy and Sales',
    'Home painting color',
    'Construction',
    'Tiles Work',
    'Plumber & Waters',
    'Furniture Fitting'
        'Interior Design',
    'Carpentary Work',
    'Photographery services',
    'Beauty Parlor Saloon barber',
    'Catering party & Event management',
    'Gift Items',
    'Flower Service',
    'Education Accessories',
    'Ticket Booking & Trading',
    'Movers & Packers',
    'Printing Service(Xerox/etc)',
    'Courier Service',
    'Internet & Broadband',
    'CCTV Fire Alarm service',
    'Online Education',
    'Education & Tution Class',
    'Dancing Class',
    'Singing Class',
    'Judo,Karate & Marshal Art',
    'Yoga Class',
    'Legal Adviser',
    'Account Adviser',
    'Astrology',
    'Gold Jewellery',
    'Garment shops',
    'School Dress',
    'Fashionable Dress Man,Women,Kids'
  ];

  @override
  void initState() {
    _service = widget.service;
    shopname = widget.shopname;
    ownername = widget.ownername;
    pincode = widget.pincode;
    service = widget.service;
    shopImage = widget.image;
    address = widget.address;
    //totalproducts = 0;
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
        centerTitle: true,
        leading: AppBarLeadingButton(
          color: Colors.black,
        ),
        title: Text('Add Products',
            style: theme.isDarkTheme()
                ? Theme.of(context).textTheme.headline6
                : TextStyle(
                    fontFamily: 'Equinox',
                    fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                    color: Colors.black,
                  )),
        backgroundColor: theme.isDarkTheme()
            ? ThemeData.dark().scaffoldBackgroundColor
            : Colors.white,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: kPrimaryColor,
            ),
            onPressed: () => {
              if (shopProduct.length != 0)
                {
                  print(shopProduct),
                  /* shopProduct = ShopProduct(
                      price: int.parse(_priceController.text),
                      name: _productnameController.text,
                      category: _productCategory) */
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => RegisterShopService(
                            shopproduct: shopProduct,
                            shopname: shopname,
                            ownername: ownername,
                            pincode: pincode,
                            address: address,
                            image: shopImage,
                            service: service,
                          )))
                }
              else
                {
                  Toast.show(
                    'Enter all details',
                    context,
                    duration: 2,
                  )
                }
            },
            child: Text(
              'Done',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ]);
  }

  _body(BuildContext context, ThemeProvider theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _noOfProducts(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildShopImageUpload(),
          _chooseProductCategory(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildInformationFields(),
          _customerPayable(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
        ],
      ),
    );
  }

  _buildShopImageUpload() {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: Center(
            child: Column(children: [
          GestureDetector(
            onTap: () {
              _showPicker(context);
            },
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xffFDCF09),
              child: _featuredImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.file(
                        _featuredImage,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(50)),
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey[800],
                      ),
                    ),
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical),
          ElevatedButton(
            onPressed: () async {
              if (_featuredImage != null) {
                showLoadingDialog(context, 'Uploading...');

                await uploadShopImageToFirebase(context);
                Navigator.pop(context);
                Toast.show('Uploaded', context);
              } else {
                Toast.show('Choose Image First', context);
              }
            },
            child: Text(
              'Click to upload',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(),
              padding: EdgeInsets.all(5),
              primary: kPrimaryColor, // <-- Button color
              onPrimary: Colors.red, // <-- Splash color
            ),
          ),
        ])));
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
      _featuredImage = image;
    });
  }

  _imgFromGallery() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _featuredImage = image;
    });
  }

  _buildInformationFields() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 4,
      ),
      child: Form(
        key: _formKey2,
        child: Column(
          children: [
            _service == 'Health Service'
                ? _chooseProductName()
                : CustomTextField(
                    label: 'Product/Service Name',
                    controller: _productnameController,
                  ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            CustomTextField(
              label: 'Product/Service Price',
              type: '1',
              //obscure: true,

              controller: _priceController,
              onChanged: (v) => setState(() {
                priceCustomer = int.parse(v);
              }),
            ),
          ],
        ),
      ),
    );
  }

  _dropDown() {
    return DropdownButton<String>(
      value: _productCategory,
      //style: TextStyle(color: Colors.black),
      underline: SizedBox(),
      isExpanded: true,
      items: _service == 'Health Service'
          ? heathCategory.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal * 2,
                      vertical: SizeConfig.blockSizeVertical * 1.8,
                    ),
                    child: Text(value)),
              );
            }).toList()
          : homeCategory.map<DropdownMenuItem<String>>((String value) {
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
        "Please choose a product type",
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
      ),
      onChanged: (String value) {
        setState(() {
          _productCategory = value;
          servicename = null;
          servicenameList.clear();
          servicenameList = _serviceHealth[value];
        });
      },
    );
  }

  _dropDownServiceName() {
    return DropdownButton<String>(
      value: servicename,
      //style: TextStyle(color: Colors.black),
      underline: SizedBox(),
      isExpanded: true,
      items: servicenameList.map<DropdownMenuItem<String>>((String value) {
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
        "Please choose a product name",
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
      ),
      onChanged: (String value) {
        setState(() {
          _productnameController.text = value;
          servicename = value;
        });
      },
    );
  }

  _noOfProducts() {
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
                'Products Added',
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
                      totalproducts.toString(),
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

  _customerPayable() {
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
                'Customer payable',
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
                      (104 * priceCustomer / 100).ceil().toString(),
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

  _chooseProductCategory() {
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
                'Product Category',
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

  _chooseProductName() {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 1,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Name',
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
                child: _dropDownServiceName(),
              ),
              //_dropDown(),
            ],
          ),
        ));
  }

  _floatingActionButton(BuildContext context, ThemeProvider theme) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 2,
      child: Icon(FluentIcons.add_12_filled, color: Colors.white),
      onPressed: () async {
        if (_service != 'Health Service') {
          if (_priceController.text != null &&
              _productCategory != null &&
              _productnameController.text != '' &&
              _priceController.text != '' &&
              _productnameController.text != '' &&
              _featuredImage != null) {
            //await uploadShopImageToFirebase(context);
            if (_featuredImageString == null) {
              Toast.show(
                'Please Upload the image first',
                context,
                duration: 2,
              );
              return;
            }
            showLoadingDialog(context, 'Uploading...');
            Navigator.pop(context);
            print("product image" + _featuredImageString);
            shopProduct.add(new ShopProduct(
                image: _featuredImageString,
                category: _productCategory,
                price: int.parse(_priceController.text),
                name: _productnameController.text));

            Toast.show(
              'Successfully added a product',
              context,
              duration: 2,
            );
            print("Product name : " + shopProduct[0].name);
            setState(() {
              totalproducts += 1;
              priceCustomer = 0;
            });

            _priceController.text = '';
            _productnameController.text = '';
          } else {
            Toast.show(
              'Enter all details',
              context,
              duration: 2,
            );
          }
        } else {
          if (_priceController.text != null &&
              _productCategory != null &&
              _productnameController.text != '' &&
              _priceController.text != '' &&
              _productnameController.text != '') {
            if (_featuredImage != null) {
              if (_featuredImageString == null) {
                Toast.show(
                  'Please Upload the image first',
                  context,
                  duration: 2,
                );
                return;
              }/* 
              showLoadingDialog(context, 'Uploading...');
              await uploadShopImageToFirebase(context);
              Navigator.pop(context);
              print("product image" + _featuredImageString); */
            }
            shopProduct.add(new ShopProduct(
                image: _featuredImage != null
                    ? _featuredImageString
                    : 'https://uploads-ssl.webflow.com/5c7da11f03dd897c90e6ef71/5f4009e18aaf4b1363c5fefe_industry_health_products_700_100.jpg',
                category: _productCategory,
                price: int.parse(_priceController.text),
                name: _productnameController.text));

            Toast.show(
              'Successfully added a product',
              context,
              duration: 2,
            );
            print("Product name : " + shopProduct[0].name);
            setState(() {
              totalproducts += 1;
              priceCustomer = 0;
            });

            _priceController.text = '';
            _productnameController.text = '';
          } else {
            Toast.show(
              'Enter all details',
              context,
              duration: 2,
            );
          }
        }
      },
    );
  }

  uploadShopImageToFirebase(BuildContext context) async {
    String fileName = p.basename(_featuredImage.path);
    String img = '';
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_featuredImage);

    await uploadTask.then((res) {
      res.ref.getDownloadURL().then((value) {
        setState(() {
          _featuredImageString = value;

          print("after upload" + value);
          //img = value;
        });
      });
    });
  }
}
