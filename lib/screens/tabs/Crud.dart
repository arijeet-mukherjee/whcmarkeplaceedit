import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:answer_me/models/Merchant.dart';
import 'package:answer_me/models/Order.dart';
import 'package:answer_me/models/Product.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/AddShopProductAfterPaid.dart';
import 'package:answer_me/screens/other/EditShopProduct.dart';
import 'package:answer_me/screens/other/Notifications.dart';
import 'package:answer_me/widgets/ExpandableText.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:answer_me/widgets/ShopProductList.dart';
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
import 'package:toast/toast.dart';

import '../../config/SizeConfig.dart';

class CrudHomeScreen extends StatefulWidget {
  @override
  _CrudHomeState createState() => _CrudHomeState();
}

class _CrudHomeState extends State<CrudHomeScreen>
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
  int productId = 0;
  bool _shouldStopRequests = false;
  bool _waitForNextRequest = false;
  final databaseRef = FirebaseDatabase.instance.reference();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String midText = '';
  List mid = [];
  bool _isLoading = true;
  String shopname = 'Hospital';
  String ownername = 'Dr. Suman';
  String shopimage = 'https://i.stack.imgur.com/y9DpT.jpg';
  Merchant myMerchant;
  List<Products> myProduct = [];
  List keysProduct = [];
  String merchantKey;
  String totCompleted = '';
  int c = 0;
  int totProduct = 0;
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
    _notificationSubscription = NotificationsBloc.instance.notificationStream
        .listen(_performActionOnNotification);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    appProvider = Provider.of<AppProvider>(context, listen: false);
    //_fetchData('merchant');
    _tabController = new TabController(vsync: this, length: tabs.length);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
        _checkIfDataExists(getEndpoint(_selectedIndex)).then((exist) async {
          if (!exist) await _fetchData(getEndpoint(_selectedIndex));
        });
        // print("Selected Index: " + _tabController.index.toString());
      } else {
        // print(
        //     "tab is animating. from active (getting the index) to inactive(getting the index) ");
      }
    });

    if (appProvider.recentQuestions.isNotEmpty) {
      _questions = appProvider.recentQuestions;

      setState(() {
        _isLoading = false;
      });
    } else
      _fetchData('recentQuestions');

    // myBanner.load();
    midText = auth.currentUser.uid.toString();
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

  _todoList() {
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
          _buildCategoryAndDate(theme),
          SizedBox(height: SizeConfig.blockSizeVertical),
          _buildQuestionTitle(context),
          _buildDescription(context, theme),
          SizedBox(height: SizeConfig.blockSizeVertical),
          //_buildViewsText(context, theme),
        ],
      ),
    );
  }

  _productListItem(String name, String category, String url, String price) {
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
          _buildProductImage(context, theme, url, category),
          _buildName(context, name),
          _buildPrice(context, price),
          SizedBox(height: SizeConfig.blockSizeVertical),
          //_buildViewsText(context, theme),
        ],
      ),
    );
  }

  _buildProductImage(
      BuildContext context, ThemeProvider theme, String url, String name) {
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
                  child: Image.network(url),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
                GestureDetector(
                  //onTap: () => _navigateToQuestionDetail(context),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ))
          ],
        ));
  }

  _buildCategoryAndDate(ThemeProvider theme) {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
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
                '${formatDate(formatter.format(DateTime.now()))}',
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

  _buildName(BuildContext context, String name) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        //onTap: () => _navigateToQuestionDetail(context),
        child: Text(
          name,
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.8,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  _buildPrice(BuildContext context, String name) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        //onTap: () => _navigateToQuestionDetail(context),
        child: Text(
          name,
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.8,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  _buildQuestionTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        //onTap: () => _navigateToQuestionDetail(context),
        child: Text(
          'Health Service',
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.8,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  _buildDescription(BuildContext context, ThemeProvider theme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical,
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        //onTap: () => _navigateToQuestionDetail(context),
        child: ExpandableText(
          'Mr. Das Booked Your Service',
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

  _buildShopName(BuildContext context, ThemeProvider theme) {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              //onTap: () => _navigateToQuestionDetail(context),
              child: Text(
                shopname != 'N/A' ? shopname : '',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ));
  }

  _buildCard(BuildContext context, ThemeProvider theme) {
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
          _buildImageName(context, theme),
          SizedBox(height: SizeConfig.blockSizeVertical),

          //_buildViewsText(context, theme),
        ],
      ),
    );
  }

  _ownerName(BuildContext context, ThemeProvider theme) {
    return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              //onTap: () => _navigateToQuestionDetail(context),
              child: Text(
                ownername,
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
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
      /* _questions = [];
      _page = 1; */
    });

    _shouldStopRequests = false;
    _waitForNextRequest = false;

    await _getData(endpoint);

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

  _getTotalProduct() async {
    int c = 0;
    databaseRef
        .child('/merchant/' + midText)
        .once()
        .then((DataSnapshot snapshot) {
      var map = HashMap.from(snapshot.value);
      map.forEach((key, value) {
        List tag = value['Products'];
        for (int i = 0; i < tag.length; i++) {
          if (tag[i] != null) {
            c += 1;
          }
        }
      });
    });
    setState(() {
      totProduct = c;
    });
    print('counter product :' + totProduct.toString());
  }

  _getData(String endpoint) async {
    int c = 0;
    if (totCompleted != '') {
      totCompleted = '';
    }

    midText = auth.currentUser.uid.toString();
    setState(() {
      midText = auth.currentUser.uid.toString();
    });
    databaseRef.child('/merchant').once().then((DataSnapshot snapshot) {
      print("UID : " + midText);
      print(snapshot.value.runtimeType);
      var map = HashMap.from(snapshot.value);
      //print(map.toString());

      map.forEach((key, value) {
        Merchant m = Merchant.fromJson(value);
        print(m.mid);
        mid.add(m.mid);
        print(m.ownername);
        print(m.address);
        if (m.mid == midText) {
          setState(() {
            myMerchant = Merchant.fromJson(value);
            merchantKey = key;
          });
          print("Merchant Key : " + merchantKey);
          List tag = value['products'];
          myProduct.clear();
          keysProduct.clear();
          print('Prdouct Tag' + tag.toString());
          print("Tag Length : " + tag.length.toString());
          for (int i = tag.length-1; i >= 0; i--) {
            if (tag[i] != null) {
              c++;
              Products p = Products.fromJson(tag[i]);
              setState(() {
                myProduct.add(p);
                keysProduct.add(i.toString());
              });
            }
          }
        }
      });
      /* print('My Merchant : ' +
          myMerchant.mid +
          '\n' +
          myMerchant.ownername +
          '\n' +
          myMerchant.shopname); */
      setState(() {
        shopname = myMerchant.shopname;
        ownername = myMerchant.ownername;
        shopimage = myMerchant.shopimage;
        totProduct = c;
      });
    });
    // c = 0;
    await databaseRef
        .child('completedorder')
        .once()
        .then((DataSnapshot snapshot) {
      var map = HashMap.from(snapshot.value);
      map.forEach((key, value) {
        Order o = Order.fromJson(value);

        //List tag = value['products'];
        if (o.mid == midText) {
          c++;
        }
      });
    });
    print('counter :' + c.toString());

    setState(() {
      totCompleted = "$c";
    });
    print('totC :' + totCompleted.toString());
    print('totProduct :' + totProduct.toString());
  //  _getTotalProduct();
  }

  void _onRefresh(String tab) async {
    setState(() {
      _isLoading = true;
    });
    _questions = [];
    _page = 1;
    _shouldStopRequests = false;
    _waitForNextRequest = false;
    switch (tab) {
      case 'HOME':
        await _getData('merchant');
        break;

      default:
    }
    _refreshController.refreshCompleted();
    _isLoading = false;
  }

  void _onLoading(String endpoint) async {
    await _getData('merchant');

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //_getData('merchant');
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          theme.isDarkTheme() ? Colors.black54 : Colors.grey.shade200,
      appBar: _appBar(context),
      body: !_isLoading
          ? Stack(children: [
              ListView(children: [
                _buildCard(context, theme),
                //SizedBox(height: SizeConfig.blockSizeVertical),
                _totalOrderCompleted(),
                //SizedBox(height: SizeConfig.blockSizeVertical),
                SizedBox(height: SizeConfig.blockSizeVertical),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 1000), // **THIS is the important part**
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            showCupertinoModalBottomSheet(
                              context: context,
                              elevation: 0,
                              topRadius: Radius.circular(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              builder: (context) => EditShopProductScreen(
                                product: myProduct[index],
                                keyP: keysProduct[index],
                                service: myMerchant.servicetype,
                                merchantKey: merchantKey,
                              ),
                            );
                            /* Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => EditShopProductScreen(
                                      product: myProduct[index],
                                      keyP: keysProduct[index],
                                      service: myMerchant.servicetype,
                                    ))); */
                          },
                          child: ShopProductList(
                            products: myProduct[index],
                            merchantKey: merchantKey,
                            productKey: keysProduct[index],
                            totProduct: totProduct,
                            services: myMerchant.servicetype,
                            onTap: () {},
                          ));
                    },
                    itemCount: myProduct.length,
                  ),
                ),
              ]),
            ])
          : LoadingShimmerLayout(),
      floatingActionButton: _floatingActionButton(context, theme),
    );
  }

  _appBar(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return AppBar(
      elevation: 4,
      centerTitle: false,
      backgroundColor: theme.isDarkTheme()
          ? ThemeData.dark().scaffoldBackgroundColor
          : kPrimaryColor,
      automaticallyImplyLeading: false,
      leadingWidth: SizeConfig.blockSizeHorizontal * 35,
      title: Row(
        children: [
          /* Image.asset(
            theme.isDarkTheme()
                ? 'assets/images/app_icon_dark.png'
                : 'assets/images/app_icon.png',
            width: SizeConfig.blockSizeHorizontal * 13,
          ), */
          Text(
            APP_NAME,
            style: TextStyle(
              fontFamily: 'Equinox',
              fontSize: SizeConfig.safeBlockHorizontal * 4.8,
              color: theme.isDarkTheme() ? Colors.white : Colors.white,
            ),
          ),
        ],
      ),

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
      onRefresh: () => _onRefresh(endpoint),
      onLoading: () => _onLoading(getEndpoint(_tabController.index)),
      child: ListView(
        children: [_todoList()],
      ),
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

  _totalOrderCompleted() {
    ThemeProvider _theme = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
        decoration: new BoxDecoration(color: Theme.of(context).cardColor),
        child: ListTile(
          //onTap: onTap,
          //backcolor: Theme.of(context).cardColor,

          leading: ClipOval(
            child: Image.network(
              'https://www.kindpng.com/picc/m/642-6420298_blank-package-png-image-jumbo-box-cargo-transparent.png',
              width: SizeConfig.blockSizeHorizontal * 12.5,
              height: SizeConfig.blockSizeHorizontal * 12.5,
              fit: BoxFit.cover,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Total Orders Completed',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 5.8,
                ),
              ),
              Text(
                totCompleted,
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 5.8,
                ),
              ),
            ],
          ),
        ));
  }

  _buildImageName(BuildContext context, ThemeProvider theme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical,
      ),
      child: Column(
        children: [
          GestureDetector(
            child: Container(
              width: double.infinity,
              height: SizeConfig.blockSizeVertical * 20,
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 6,
              ),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Image.network(
                shopimage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical),
          _buildShopName(context, theme),
          _ownerName(context, theme),
        ],
      ),
    );
  }

  _floatingActionButton(BuildContext context, ThemeProvider theme) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 2,
      child: Icon(FluentIcons.add_12_filled, color: Colors.white),
      onPressed: () async {
        showCupertinoModalBottomSheet(
          context: context,
          elevation: 0,
          topRadius: Radius.circular(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          builder: (context) => AddShopProductAfterPaidScreen(
            keyP: keysProduct.length.toString(),
            service: myMerchant.servicetype,
            merchantKey: merchantKey,
            productType: myProduct != null ? myProduct[0].category.trim() : '',
          ),
        );
      },
    );
  }
}
