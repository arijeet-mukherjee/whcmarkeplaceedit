import 'dart:async';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/Notifications.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<Map> _notificationSubscription;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TabController _tabController;
  int _selectedIndex = 0;
  AuthProvider authProvider;
  AppProvider appProvider;
  List<Question> _questions = [];
  int _page;
  bool _shouldStopRequests = false;
  bool _waitForNextRequest = false;
  bool _isLoading = true;

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
    _notificationSubscription = NotificationsBloc.instance.notificationStream
        .listen(_performActionOnNotification);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    appProvider = Provider.of<AppProvider>(context, listen: false);

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
        await _getQuestions('recentQuestions');
        break;
      /* case 'MOST REPLIED':
        await _getQuestions('mostAnsweredQuestions');
        break;
      case 'MOST INTERESTING':
        await _getQuestions('mostVisitedQuestions');
        break;
      case 'MOST LIKED':
        await _getQuestions('mostVotedQuestions');
        break;
      case 'NO REPLIES':
        await _getQuestions('noAnsweredQuestions');
        break; */
      default:
    }
    _refreshController.refreshCompleted();
    _isLoading = false;
  }

  void _onLoading(String endpoint) async {
    await _getQuestions(endpoint);

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  _addToBookmark(int id) {
    AppProvider _appProvider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      _questions.singleWhere((question) => question.id == id).bookmark = 1;
    });
    _appProvider.setNoBookmarks(false);
  }

  _removeFromBookmark(int id) {
    setState(() {
      _questions.singleWhere((question) => question.id == id).bookmark = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          theme.isDarkTheme() ? Colors.black54 : Colors.grey.shade200,
      appBar: _appBar(context),
      body: !_isLoading ? _body() : LoadingShimmerLayout(),
      floatingActionButton: _floatingActionButton(context, theme),
    );
  }

  _appBar(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return AppBar(
      elevation: 4,
      centerTitle: false,
      backgroundColor: theme.isDarkTheme()?ThemeData.dark().scaffoldBackgroundColor:kPrimaryColor,
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
              color: theme.isDarkTheme()?Colors.white:Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              splashRadius: 25,
              icon: Icon(
                EvaIcons.bellOutline,
                color: theme.isDarkTheme()
                    ? Colors.white70
                    : Colors.white70,
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, NotificationsScreen.routeName),
            ),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.user != null)
                  return Positioned.fill(
                    child: auth.user.notifications != 0 &&
                            auth.user.notifications != null
                        ? Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20, left: 10),
                              child: CircleAvatar(
                                maxRadius: SizeConfig.blockSizeHorizontal * 1.2,
                                backgroundColor: theme.isDarkTheme()
                                                 ?Colors.white:Colors.white
                              ),
                            ),
                          )
                        : Container(),
                  );
                else
                  return Container();
              },
            ),
          ],
        ),
      ],
     // bottom: _tabBar(),
     
    );
  }

  _tabBar() {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return TabBar(
      tabs: tabs,
      controller: _tabController,
      isScrollable: true,
      labelColor: Colors.white,
      indicatorWeight: 5.0,
      indicatorColor: theme.isDarkTheme()?Colors.white:kPrimaryColor,
      unselectedLabelColor: Colors.white,
      labelStyle: GoogleFonts.lato(
        fontSize: SizeConfig.safeBlockHorizontal * 3.3,
        fontWeight: FontWeight.w600,
      ),
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

  _floatingActionButton(BuildContext context, ThemeProvider theme) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 2,
      child: Icon(FluentIcons.add_12_filled, color: Colors.white),
      onPressed: () {
        if (authProvider.user != null && authProvider.user.id != null) {
          showCupertinoModalBottomSheet(
            context: context,
            elevation: 0,
            topRadius: Radius.circular(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            builder: (context) => AskQuestionScreen(),
          );
        } else {
          Toast.show(
            'You have to login to ask questions',
            context,
            duration: 2,
          );
        }
      },
    );
  }

  Widget _recentQuestions(String endpoint) {
    return swipeToRefresh(
      context,
      refreshController: _refreshController,
      onRefresh: () => _onRefresh(endpoint),
      onLoading: () => _onLoading(getEndpoint(_tabController.index)),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _questions.length,
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
              QuestionListItem(
                question: _questions[i],
                addToFav: _addToBookmark,
                fetchData: _fetchData,
                removeFromFav: _removeFromBookmark,
                endpoint: getEndpoint(_selectedIndex),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget _recentQuestions(String endpoint) {
  //   return swipeToRefresh(
  //     context,
  //     refreshController: _refreshController,
  //     onRefresh: () => _onRefresh(endpoint),
  //     onLoading: () => _onLoading(getEndpoint(_tabController.index)),
  //     child: ListView.builder(
  //       itemCount: _questions.length + (_isAdLoaded ? 1 : 0),
  //       itemBuilder: (ctx, i) {
  //         if (_isAdLoaded && i == _kAdIndex) {
  //           return Container(
  //             child: AdWidget(ad: _ad),
  //             width: _ad.size.width.toDouble(),
  //             height: 72.0,
  //             alignment: Alignment.center,
  //           );
  //         } else {
  //           return PostListItem(
  //             question: _questions[i],
  //             addToFav: _addToBookmark,
  //             removeFromFav: _removeFromBookmark,
  //             endpoint: getEndpoint(_selectedIndex),
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }

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
}
