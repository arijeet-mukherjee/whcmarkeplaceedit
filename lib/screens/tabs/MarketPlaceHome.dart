import 'dart:async';
import 'dart:collection';
import 'package:answer_me/models/Order.dart';
import 'package:answer_me/models/Product.dart';
import 'package:answer_me/models/Registered.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/Notifications.dart';
import 'package:answer_me/screens/tabs/Crud.dart';
import 'package:answer_me/widgets/ExpandableText.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:answer_me/config/AdmobConfig.dart';
import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/screens/other/AskQuestion.dart';
import 'package:answer_me/screens/other/UserProfile.dart';
import 'package:answer_me/screens/other/QuestionDetail.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/services/NotificationBloc.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/QuestionListItem.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:twilio_phone_verify/twilio_phone_verify.dart';

import '../../config/SizeConfig.dart';
import '../HomeMarketplace.dart';

class MarketplaceHomeScreen extends StatefulWidget {
  @override
  _MarketplaceHomeState createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHomeScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<Map> _notificationSubscription;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TabController _tabController;
  int _selectedIndex = 0;
  AuthProvider authProvider;
  AppProvider appProvider;
  List<Question> _questions = [];
  List todolist = [];
  int _page;
  String otp, authStatus = "";
  bool _shouldStopRequests = false;
  bool _waitForNextRequest = false;
  bool _isLoading = true;
  List<Order> incoming = [];
  List<Order> completed = [];
  List<Products> myProductIncoming = [];
  List<Products> myProductCompleted = [];
  List<String> productName = [];
  List<String> orderKey = [];
  TwilioFlutter twilioFlutter;
  final databaseRef = FirebaseDatabase.instance.reference();
  final FirebaseAuth auth = FirebaseAuth.instance;
  TwilioPhoneVerify _twilioPhoneVerify;
  String merchantNumber = '';
  bool isVerified = false;
  /* final BannerAd myBanner = BannerAd(
    adUnitId: AdmobConfig.bannerAdUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: AdListener(),
  ); */

  final List<Tab> tabs = <Tab>[
    Tab(text: 'HOME'),
    /* Tab(text: 'MOST REPLIED'),
    Tab(text: 'MOST INTERESTING'),
    Tab(text: 'MOST LIKED'),
    Tab(text: 'NO REPLIES'), */
  ];

  @override
  void initState() {
    super.initState();
    _getMerchantNumber();
    _notificationSubscription = NotificationsBloc.instance.notificationStream
        .listen(_performActionOnNotification);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    appProvider = Provider.of<AppProvider>(context, listen: false);
    _twilioPhoneVerify = TwilioPhoneVerify(
      accountSid: 'AC06b85e72cec1706cf34dfda202a0bf01',
      serviceSid: 'VA0b397348a4349634a45f6404b73e2fe4',
      authToken: '707c1ebd56fe85737e6424e84c937c0c',
    );
    twilioFlutter = TwilioFlutter(
        accountSid: 'AC06b85e72cec1706cf34dfda202a0bf01',
        authToken: '707c1ebd56fe85737e6424e84c937c0c',
        twilioNumber: '+14053582196');

    _tabController = new TabController(vsync: this, length: tabs.length);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });

        // print("Selected Index: " + _tabController.index.toString());
      } else {
        // print(
        //     "tab is animating. from active (getting the index) to inactive(getting the index) ");
      }
    });
    _getData();

    // myBanner.load();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    _tabController.dispose();
    super.dispose();
  }

  _setQuestionsInProvider(String endpoint) async {
    switch (endpoint) {
      case 'recentQuestions':
        await appProvider.setRecentQuestions(_questions);
        break;
      case 'mostAnsweredQuestions':
        await appProvider.setMostAnsweredQuestions(_questions);
        break;
      case 'mostVisitedQuestions':
        await appProvider.setMostVisitedQuestions(_questions);
        break;
      case 'mostVotedQuestions':
        await appProvider.setMostVotedQuestions(_questions);
        break;
      case 'noAnsweredQuestions':
        await appProvider.setNoAnswersQuestions(_questions);
        break;
      default:
    }
  }

  _todoList(Order o, String s, int i) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(
        0,
        SizeConfig.blockSizeVertical * 3,
        0,
        SizeConfig.blockSizeVertical,
      ),
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 1),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryAndDate(theme, o.date),
          SizedBox(height: SizeConfig.blockSizeVertical),
          _buildQuestionTitle(context, o),
          _buildDescription(context, theme, o.mid, s, o),
          SizedBox(height: SizeConfig.blockSizeVertical),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockSizeVertical,
                        horizontal: SizeConfig.blockSizeHorizontal * 6,
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          //launch("tel://" + o.usernumber);
                          //add here
                          
                          if (o.paid == '0') {
                            Toast.show('Ask User To Pay First!', context);
                          }
                          else{
                             sendCode(o.usernumber);
                            _otpDialogBox(context, o.usernumber, o, i);
                            
                            
                            }
                          /* if (isVerified) {
                            _pushCompleted(o, i);
                          } */

                          /* if (o.paid == '0') {
                            Toast.show('Ask User To Pay First!', context);
                          } else {
                            await databaseRef
                                .child('/incomingorder/' + orderKey[i])
                                .remove();
                            // o.products = myProductIncoming[i].toJson();
                            await databaseRef
                                .child('/completedorder')
                                .push()
                                .set(o.toJson());
                          } */
                        },
                        child: Icon(
                          EvaIcons.doneAll,
                          color: Colors.white,
                          size: 15,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                          primary: Colors.green, // <-- Button color
                          onPrimary: Colors.red, // <-- Splash color
                        ),
                      )
                      ),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                  Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockSizeVertical,
                        horizontal: SizeConfig.blockSizeHorizontal * 6,
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            if (UniversalPlatform.isAndroid) {
                              String s = '*Booking date :* ' +
                                  o.date +
                                  '\n' +
                                  '*Booked by :* ' +
                                  o.name +
                                  '\n' +
                                  '*Booking Address :* ' +
                                  o.address +
                                  '\n' +
                                  '*Total Price :* ' +
                                  o.price.toString();
                              Share.share(s);
                            } else if (UniversalPlatform.isIOS) {
                              Share.share(s);
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Icon(
                          EvaIcons.share,
                          color: Colors.white,
                          size: 15,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                          primary: Colors.lightBlueAccent, // <-- Button color
                          onPrimary: Colors.red, // <-- Splash color
                        ),
                      )),
                  SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                  Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockSizeVertical,
                        horizontal: SizeConfig.blockSizeHorizontal * 6,
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          launch("tel://" + o.usernumber);
                          //add here
                        },
                        child: Icon(
                          EvaIcons.phoneCall,
                          color: Colors.white,
                          size: 15,
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(20),
                          primary: kPrimaryColor, // <-- Button color
                          onPrimary: Colors.red, // <-- Splash color
                        ),
                      ))
                ],
              ))
            ],
          ),

          //_buildViewsText(context, theme),
        ],
      ),
    );
  }

  _otpDialogBox(BuildContext context, String number, Order o, int i) {
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  if (otp != null) {
                    verifyCode(number, otp,o,i);
                    
                    //_navigateToDevScreen();
                    //_loginUser();
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

  _pushCompleted(Order o, int i) async {
    if (o.paid == '0') {
      Toast.show('Ask User To Pay First!', context);
    } else {
      await databaseRef.child('/incomingorder/' + orderKey[i]).remove();
      // o.products = myProductIncoming[i].toJson();
      await databaseRef.child('/completedorder').push().set(o.toJson());
      String price = o.price.toString();
      String number = o.usernumber;
      String message =
          "Service completed successfully. Against payment of INR $price \n\n - WHC India Services";

      String n =
          '+91 ' + number.substring(0, 5) + ' ' + number.substring(5, 10);
      String n2 = '+91 ' +
          merchantNumber.substring(0, 5) +
          ' ' +
          merchantNumber.substring(5, 10);
      sendSms(n, message);
      sendSms(n2, message);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (ctx) => HomeMarketplaceScreen()),
      );
    }
  }

  _buildCategoryAndDate(ThemeProvider theme, String d) {
    // DateFormat formatter = DateFormat('yyyy-MM-dd');
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$d',
                style: TextStyle(
                  color: theme.isDarkTheme() ? Colors.white70 : Colors.black54,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                ),
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
              /*GestureDetector(
                  onTap: _shareQuestion,
                  child: Icon(
                    FluentIcons.share_android_24_regular,
                    color:
                        theme.isDarkTheme() ? Colors.white70 : Color(0xFF480000),
                    size: SizeConfig.blockSizeHorizontal * 6,
                  ),
                ), */
              /* GestureDetector(
                  onTap: _openActions,
                  child: Icon(
                    EvaIcons.moreVerticalOutline,
                    color:
                        theme.isDarkTheme() ? Colors.white70 : Colors.black45,
                    size: SizeConfig.blockSizeHorizontal * 6.2,
                  ),
                ), */
            ],
          ))
        ],
      ),
    );
  }

  _buildQuestionTitle(BuildContext context, Order o) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        //onTap: () => _navigateToQuestionDetail(context),
        child: Text(
          '₹' + o.price.toString(),
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.8,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  _buildDescription(
      BuildContext context, ThemeProvider theme, String id, String s, Order o) {
    String txt = '';
    if (o.paid == '0') {
      txt = "Not Paid";
    } else {
      txt = "Paid";
    }
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical,
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        //onTap: () => _navigateToQuestionDetail(context),
        child: ExpandableText(
          o.address +
              '\n\n' +
              'Your Service has been booked by\n' +
              o.name +
              ' (' +
              txt +
              ')',
          trimLines: 5,
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.1,
            fontWeight: FontWeight.w400,
            color: theme.isDarkTheme()
                ? Colors.white.withOpacity(0.8)
                : Colors.black87,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  _buildViewsText(BuildContext context, ThemeProvider theme) {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  //onTap: () => _navigateToQuestionDetail(context),
                  child: Text(
                    '₹500',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                      fontWeight: FontWeight.w400,
                      color:
                          theme.isDarkTheme() ? Colors.white60 : Colors.black54,
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                GestureDetector(
                  onTap: () => {
                    Toast.show(
                        'Under Development You can cancel and approve from here!',
                        context),
                  },
                  child: Icon(
                    EvaIcons.arrowIosForwardOutline,
                    color: theme.isDarkTheme()
                        ? Colors.white70
                        : Color(0xFF480000),
                    size: SizeConfig.blockSizeHorizontal * 5.6,
                  ),
                ),
              ],
            ))
          ],
        ));
  }

  _performActionOnNotification(Map<String, dynamic> message) async {
    if (message['data']['question_id'] != null)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuestionDetailScreen(
            questionId: int.parse(message['data']['question_id']),
          ),
        ),
      );
    else if (message['data']['author_id'] != null)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserProfile(
            authorId: int.parse(message['data']['author_id']),
          ),
        ),
      );
  }

  _fetchData(String endpoint) async {
    setState(() {
      _isLoading = true;
      _questions = [];
      _page = 1;
    });

    _shouldStopRequests = false;
    _waitForNextRequest = false;

    await _getQuestions(endpoint);

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _checkIfDataExists(String endpoint) async {
    switch (endpoint) {
      case 'recentQuestions':
        if (appProvider.recentQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.recentQuestions;
          });
          return true;
        } else
          return false;
        break;
      case 'mostAnsweredQuestions':
        if (appProvider.mostAnsweredQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.mostAnsweredQuestions;
          });
          return true;
        } else
          return false;
        break;
      case 'mostVisitedQuestions':
        if (appProvider.mostVisitedQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.mostVisitedQuestions;
          });
          return true;
        } else
          return false;
        break;
      case 'mostVotedQuestions':
        if (appProvider.mostVotedQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.mostVotedQuestions;
          });
          return true;
        } else
          return false;
        break;
      case 'noAnsweredQuestions':
        if (appProvider.noAnswersQuestions.isNotEmpty) {
          setState(() {
            _questions = appProvider.noAnswersQuestions;
          });
          return true;
        } else
          return false;
        break;
      default:
        return false;
    }
  }

  _getQuestions(String endpoint) async {
    if (_shouldStopRequests) return;
    if (_waitForNextRequest) return;
    _waitForNextRequest = true;
    await ApiRepository.getRecentQuestions(context, endpoint,
            offset: PER_PAGE,
            page: _page,
            userId: authProvider.user != null ? authProvider.user.id : 0)
        .then((questions) async {
      setState(() {
        _page = _page + 1;
        _waitForNextRequest = false;
        if (questions.data != null) _questions.addAll(questions.data.toList());
        _setQuestionsInProvider(endpoint);
      });
    });

    setState(() {});
  }

  void _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await _getData();
    _refreshController.refreshCompleted();
    _isLoading = false;
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          theme.isDarkTheme() ? Colors.black54 : Colors.grey.shade200,
      appBar: _appBar(context),
      body: !_isLoading ? _body2() : LoadingShimmerLayout(),
      //floatingActionButton: _floatingActionButton(context, theme),
    );
  }

  _body2() {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return swipeToRefresh(context,
        refreshController: _refreshController,
        onRefresh: () => _onRefresh(),
        onLoading: () => _onLoading(), // **THIS is the important part**
        child: incoming != null
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                //physics: NeverScrollableScrollPhysics(),
                //physics: const AlwaysScrollableScrollPhysics(),
                itemCount: incoming.length,
                itemBuilder: (ctx, i) {
                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      // i != 0 && (i == 1 || (i - 1) % 5 == 0)
                      //     ? Container(
                      //         width: double.infinity,
                      //         height: myBanner.size.height.toDouble(),
                      //         color: Theme.of(context).cardColor,
                      //         alignment: Alignment.center,
                      //         child: AdWidget(ad: myBanner),
                      //         margin: EdgeInsets.only(
                      //           bottom: SizeConfig.blockSizeVertical * 1,
                      //         ),
                      //       )
                      //     : Container(),
                      _todoList(incoming[i], productName[i], i),
                    ],
                  );
                },
              )
            : Center(
                child: Text('No Orders Yet!',
                    style: theme.isDarkTheme()
                        ? Theme.of(context).textTheme.headline6
                        : TextStyle(
                            fontFamily: 'Equinox',
                            fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                            color: Colors.white,
                          )),
              ));
    //
  }

  _appBar(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return AppBar(
      elevation: 4,
      centerTitle: true,
      backgroundColor: theme.isDarkTheme()
          ? ThemeData.dark().scaffoldBackgroundColor
          : kPrimaryColor,
      automaticallyImplyLeading: false,
      title: Text('Todo List',
          style: theme.isDarkTheme()
              ? Theme.of(context).textTheme.headline6
              : TextStyle(
                  fontFamily: 'Equinox',
                  fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  color: Colors.white,
                )),

      // bottom: _tabBar(),
    );
  }

  _body() {
    return TabBarView(
      controller: _tabController,
      children: tabs.map((Tab tab) {
        return _recentQuestions(tab.text);
      }).toList(),
    );
  }

  //Chnage for home
  Widget _recentQuestions(String endpoint) {
    return swipeToRefresh(
      context,
      refreshController: _refreshController,
      onRefresh: () => _onRefresh(),
      onLoading: () => _onLoading(),
      child: ListView(children: [
        //_todoList()],]
      ]),
    );
  }

  String getEndpoint(int index) {
    switch (index) {
      case 0:
        return 'recentQuestions';
        break;
      case 1:
        return 'mostAnsweredQuestions';
        break;
      // case 2:
      //   return 'mostAnsweredQuestions';
      //   break;
      case 2:
        return 'mostVisitedQuestions';
        break;
      case 3:
        return 'mostVotedQuestions';
        break;
      case 4:
        return 'noAnsweredQuestions';
        break;
    }
    return 'recentQuestions';
  }

  _getData() async {
    String uid = auth.currentUser.uid.toString();

    if (incoming != null) {
      setState(() {
        incoming.clear();
      });
    }
    if (completed != null) {
      setState(() {
        completed.clear();
      });
    }
    if (myProductIncoming != null) {
      setState(() {
        myProductIncoming.clear();
      });
    }
    if (myProductCompleted != null) {
      setState(() {
        myProductCompleted.clear();
      });
    }

    if (orderKey != null) {
      setState(() {
        orderKey.clear();
      });
    }

    await databaseRef
        .child('incomingorder')
        .once()
        .then((DataSnapshot snapshot) {
      var map = HashMap.from(snapshot.value);
      map.forEach((key, value) {
        Order o = Order.fromJson(value);
        String s = '';
        List tag = value['products'];
        if (o.mid == uid) {
          setState(() {
            incoming.add(o);
            orderKey.add(key);
          });

          for (int i = 0; i < tag.length; i++) {
            Products p = Products.fromJson(tag[i]);
            s += p.name;
            s += '\n';
            setState(() {
              myProductIncoming.add(p);
            });
          }

          setState(() {
            productName.add(s);
          });
        }
      });
    });
    //print('Size of incoming' + incoming.length.toString());
    setState(() {
      _isLoading = false;
    });
    /* await databaseRef
        .child('completedorder')
        .once()
        .then((DataSnapshot snapshot) {
      var map = HashMap.from(snapshot.value);
      map.forEach((key, value) {
        Order o = Order.fromJson(value);

        List tag = value['products'];
        if (o.uid == uid) {
          setState(() {
            completed.add(o);
          });

          for (int i = 0; i < tag.length; i++) {
            Products p = Products.fromJson(tag[i]);
            setState(() {
              myProductCompleted.add(p);
            });
          }
        }
      });
    }); */
  }

  void sendCode(String number) async {
    String n = '+91 ' + number.substring(0, 5) + ' ' + number.substring(5, 10);
    TwilioResponse twilioResponse = await _twilioPhoneVerify.sendSmsCode(n);

    if (twilioResponse.successful) {
      await Future.delayed(Duration(seconds: 1));
      //switchToSmsCode();
    } else {
      //changeErrorMessage(twilioResponse.errorMessage);
      print('error sms' + twilioResponse.errorMessage.toString());
    }
    //changeLoading(false);
  }

   verifyCode(String number, String sms, Order o, int i) async {
    /* if (phoneNumberController.text.isEmpty ||
        smsCodeController.text.isEmpty ||
        loading) return;
    changeLoading(true); */
    setState(() {
      _isLoading = true;
    });
    String n = '+91 ' + number.substring(0, 5) + ' ' + number.substring(5, 10);
    TwilioResponse twilioResponse =
        await _twilioPhoneVerify.verifySmsCode(phone: n, code: sms);
    if (twilioResponse.successful) {
      if (twilioResponse.verification.status == VerificationStatus.approved) {
        print('Order Verify :' + 'Verified Order');
        _pushCompleted(o, i);
        setState(() {
          isVerified = true;
          _isLoading = false;
        });
        
        //changeSuccessMessage('Phone number is approved');
      } else {
        // changeSuccessMessage('Invalid code');
        Toast.show('Invalid Otp', context);
      }
    } else {
      //changeErrorMessage(twilioResponse.errorMessage);
    }
    //changeLoading(false);
  }

  void sendSms(String to, String mg) async {
    twilioFlutter.sendSMS(toNumber: to, messageBody: mg);
  }

  _getMerchantNumber() async {
    String uid = auth.currentUser.uid.toString();
    await databaseRef.child('registered').once().then((DataSnapshot snapshot) {
      var map = HashMap.from(snapshot.value);
      map.forEach((key, value) {
        Registered r = Registered.fromJson(value);
        // String s = '';

        if (r.mid == uid) {
          setState(() {
            merchantNumber = r.number;
            // _isCall = false;
          });
        }
      });
    });
    setState(() {
      _isLoading = false;
    });
  }
}
