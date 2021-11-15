// import 'package:admob_flutter/admob_flutter.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/widgets/EmptyScreenText.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';

import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:flutter/material.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/QuestionListItem.dart';

class BookmarkScreen extends StatefulWidget {
  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AuthProvider _authProvider;
  AppProvider _appProvider;
  List<Question> _questions = [];
  int _page;
  bool _shouldStopRequests;
  bool _waitForNextRequest;
  bool _isLoading;

  /* final BannerAd myBanner = BannerAd(
    adUnitId: AdmobConfig.bannerAdUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: AdListener(),
  ); */

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    _isLoading = true;
    _page = 1;

    _fetchData();

   // myBanner.load();
  }

  _fetchData() async {
    if (_appProvider.bookmarkQuestions.isNotEmpty) {
      setState(() {
        _questions = _appProvider.bookmarkQuestions;
      });
    } else if (!_appProvider.noBookmarks) {
      _shouldStopRequests = false;
      _waitForNextRequest = false;
      await _getQuestions();
      _appProvider.setNoBookmarks(true);
    }

    setState(() {
      _isLoading = false;
    });
  }

  _getQuestions() async {
    if (_shouldStopRequests) return;
    if (_waitForNextRequest) return;
    _waitForNextRequest = true;

    await ApiRepository.getBookmarkedQuestions(
      context,
      userId: _authProvider.user != null ? _authProvider.user.id : 0,
      offset: PER_PAGE,
      page: _page,
    ).then((questions) {
      setState(() {
        _page = _page + 1;
        _waitForNextRequest = false;
      });
      setState(() {
        _questions.addAll(questions.data.toList());
        _appProvider.setBookmarkedQuestions(questions.data);
      });
    });

    setState(() {});
  }

  void _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    _questions = [];
    _page = 1;
    _shouldStopRequests = false;
    _waitForNextRequest = false;
    await _getQuestions();
    _refreshController.refreshCompleted();
    _isLoading = false;
  }

  void _onLoading() async {
    await _getQuestions();

    if (mounted) {
      setState(() {});
      if (_shouldStopRequests) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  _revomeBookmark(int id) {
    setState(() {
      _questions.removeWhere((question) => question.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:
          theme.isDarkTheme() ? Colors.black54 : Colors.grey.shade200,
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text('Bookmark', style: theme.isDarkTheme()?Theme.of(context).textTheme.headline6:TextStyle(
              fontFamily: 'Equinox',
              fontSize: SizeConfig.safeBlockHorizontal * 4.8,
              color: Colors.white,
            )),
      backgroundColor: theme.isDarkTheme()?ThemeData.dark().scaffoldBackgroundColor:kPrimaryColor,
    );
  }

  _body() {
    return _authProvider.user == null
        ? EmptyScreenText(
            text: 'Please login, so you can add bookmarks.',
            icon: Icons.bookmark_border,
          )
        : !_isLoading
            ? _questions.isEmpty
                ? EmptyScreenText(
                    text: 'No Bookmark Found',
                    icon: Icons.bookmark_border,
                  )
                : _bookmarkQuestions()
            : LoadingShimmerLayout();
  }

  Widget _bookmarkQuestions() {
    return swipeToRefresh(
      context,
      refreshController: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemCount: _questions.length,
        itemBuilder: (ctx, i) {
          return Column(
            children: [
              /* i != 0 && (i == 1 || (i - 1) % 5 == 0)
                  ? Container(
                      /* width: double.infinity,
                      height: myBanner.size.height.toDouble(),
                      color: Theme.of(context).cardColor,
                      alignment: Alignment.center,
                      child: AdWidget(ad: myBanner),
                      margin: EdgeInsets.only(
                        bottom: SizeConfig.blockSizeVertical * 1,
                      ), */
                    )
                  : Container(), */
              QuestionListItem(
                question: _questions[i],
                removeFromFav: _revomeBookmark,
              ),
            ],
          );
        },
      ),
    );
  }
}
