// import 'package:admob_flutter/admob_flutter.dart';
import 'package:answer_me/config/AdmobConfig.dart';
import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/models/QuestionTag.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/EmptyScreenText.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:answer_me/widgets/QuestionListItem.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TagQuestionsScreen extends StatefulWidget {
  final QuestionTag tag;

  const TagQuestionsScreen({Key key, this.tag}) : super(key: key);

  @override
  _TagQuestionsScreenState createState() => _TagQuestionsScreenState();
}

class _TagQuestionsScreenState extends State<TagQuestionsScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  AuthProvider _authProvider;
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

    _isLoading = true;
    _page = 1;

    _fetchData();

   // myBanner.load();
  }

  _fetchData() async {
    _shouldStopRequests = false;
    _waitForNextRequest = false;
    await _getTags();
    setState(() {
      _isLoading = false;
    });
  }

  _getTags() async {
    if (_shouldStopRequests) return;
    if (_waitForNextRequest) return;
    _waitForNextRequest = true;

    await ApiRepository.getQuestionsByTag(context, widget.tag.tag,
            offset: PER_PAGE,
            page: _page,
            userId: _authProvider.user != null ? _authProvider.user.id : 0)
        .then((questions) {
      setState(() {
        _page = _page + 1;
        _waitForNextRequest = false;
        _questions.addAll(questions.data.toList());
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
    await _getTags();
    _refreshController.refreshCompleted();
    _isLoading = false;
  }

  void _onLoading() async {
    await _getTags();

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
      appBar: _appBar(),
      body: _bookmarkQuestions(),
    );
  }

  _appBar() {
    return AppBar(
      leading: AppBarLeadingButton(),
      title: Text(widget.tag.tag, style: Theme.of(context).textTheme.headline6),
      centerTitle: true,
    );
  }

  _bookmarkQuestions() {
    return !_isLoading
        ? swipeToRefresh(
            context,
            refreshController: _refreshController,
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: _questions.isNotEmpty
                ? ListView.builder(
                    itemCount: _questions.length,
                    itemBuilder: (ctx, i) {
                      return Column(
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
                            removeFromFav: _removeFromBookmark,
                          ),
                        ],
                      );
                    },
                  )
                : EmptyScreenText(
                    text: 'No Questions Found',
                    icon: Icons.question_answer_outlined,
                  ),
          )
        : LoadingShimmerLayout();
  }
}
