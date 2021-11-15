import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/AskQuestion.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:answer_me/widgets/QuestionAnswerListItem.dart';
import 'package:answer_me/widgets/QuestionDetailItem.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share/share.dart';
import 'package:universal_platform/universal_platform.dart';

class QuestionDetailScreen extends StatefulWidget {
  final int questionId;
  final bool answerBtnEnabled;
  final Function fetchData;
  final String endpoint;

  const QuestionDetailScreen(
      {Key key,
      this.questionId,
      this.fetchData,
      this.answerBtnEnabled = false,
      this.endpoint})
      : super(key: key);

  @override
  _QuestionDetailScreenState createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final _answerKey = new GlobalKey();
  AutoScrollController _controller;
  ThemeProvider _themeProvider;
  AuthProvider _authProvider;
  AppProvider _appProvider;
  bool _answerBtnEnabled = false;
  bool _isLoading = true;
  Question _question;
  final scrollDirection = Axis.vertical;

  @override
  void initState() {
    super.initState();
    _controller = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: scrollDirection,
    );

    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    _getQuestion();

    _updateQuestionViews();

    // setState(() {
    _answerBtnEnabled = widget.answerBtnEnabled;
    // });
  }

  _getQuestion() async {
    // setState(() {
    //   _isLoading = true;
    // });
    await ApiRepository.getQuestion(
      context,
      widget.questionId,
      _authProvider.user != null ? _authProvider.user.id : 0,
    ).then((question) {
      if (mounted)
        setState(() {
          _question = question;
          _isLoading = false;
        });
    });
  }

  _answerQuestion() {
    setState(() {
      _answerBtnEnabled = !_answerBtnEnabled;
    });
    if (_answerBtnEnabled)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          _answerKey.currentContext,
          duration: const Duration(milliseconds: 800),
        );
      });
  }

  _removeComment(int commentId) {
    setState(() {
      _question.answers.removeWhere((answer) => answer.id == commentId);
    });
  }

  _replyToAnswer(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.scrollToIndex(index,
          preferPosition: AutoScrollPosition.begin);
      _controller.highlight(index);
    });
  }

  _updateQuestionViews() async {
    await ApiRepository.updateQuestionViews(
      context,
      questionId: widget.questionId,
    );
  }

  _deleteQuestion() async {
    ApiRepository.deleteQuestion(context, questionId: widget.questionId).then(
      (value) async {
        await widget.fetchData('recentQuestions');
        await _appProvider.clearAllQuestions();
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );
  }

  _shareQuestion() {
    try {
      if (UniversalPlatform.isAndroid) {
        Share.share(
          '${_question.title}\n\n${_question.content}\n\n$SHARE_TEXT\n$ANDROID_SHARE_URL',
          subject: _question.title,
        );
      } else if (UniversalPlatform.isIOS) {
        Share.share(
          '${_question.title}\n\n${_question.content}\n\n$SHARE_TEXT\n$IOS_SHARE_URL',
          subject: _question.title,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_answerBtnEnabled)
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Scrollable.ensureVisible(
          _answerKey.currentContext,
          duration: const Duration(milliseconds: 800),
        );
      });

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      leading: AppBarLeadingButton(),
      actions: [
        /* IconButton(
          icon: Icon(
            FluentIcons.share_ios_20_filled,
            color: _themeProvider.isDarkTheme() ? Colors.white : Colors.black87,
          ),
          onPressed: () => _shareQuestion(),
        ), */
        (_authProvider.user != null && _question != null) &&
                _authProvider.user.id == _question.authorId
            ? PopupMenuButton(
                icon: Icon(
                  FluentIcons.more_vertical_20_regular,
                  color: _themeProvider.isDarkTheme()
                      ? Colors.white
                      : Colors.black87,
                ),
                itemBuilder: (BuildContext bc) => [
                  PopupMenuItem(child: Text("Edit"), value: 0),
                  PopupMenuItem(child: Text("Delete"), value: 1),
                ],
                onSelected: (value) {
                  if (value == 0) {
                    showCupertinoModalBottomSheet(
                      context: context,
                      elevation: 0,
                      topRadius: Radius.circular(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      builder: (context) => AskQuestionScreen(
                        questionId: _question.id,
                        edit: true,
                      ),
                    );
                  } else
                    showConfirmationDialog(
                      context,
                      text: 'Are you sure you want to delete this question?',
                      yes: () => _deleteQuestion(),
                      no: () => Navigator.pop(context),
                    );
                },
              )
            : Container(),
      ],
    );
  }

  _body() {
    return SafeArea(
      child: _isLoading
          ? LoadingShimmerLayout()
          : SingleChildScrollView(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    QuestionDetailItem(
                      question: _question,
                      answerQuestion: _answerQuestion,
                      answerBtnEnabled: _answerBtnEnabled,
                      endpoint: widget.endpoint,
                      getQuestion: _getQuestion,
                    ),
                    /* Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _buildAnswerRow(),
                        // SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                        _question.answers.isNotEmpty
                            ? ListView.builder(
                                padding: EdgeInsets.only(
                                  bottom: SizeConfig.blockSizeVertical * 5,
                                ),
                                itemCount: _question.answers.length,
                                scrollDirection: scrollDirection,
                                physics: NeverScrollableScrollPhysics(),
                                controller: _controller,
                                shrinkWrap: true,
                                itemBuilder: (context, i) => AutoScrollTag(
                                  key: ValueKey(i),
                                  controller: _controller,
                                  index: i,
                                  child: QuestionAnswerListItem(
                                    key: ValueKey(i),
                                    answer: _question.answers[i],
                                    index: i,
                                    question: _question,
                                    questionId: _question.id,
                                    getQuestion: _getQuestion,
                                    bestAnswer: _question.bestAnswer,
                                    replyToAnswer: _replyToAnswer,
                                    controller: _controller,
                                    removeComment: _removeComment,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Divider(height: 2, thickness: 1),
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: SizeConfig.blockSizeVertical * 4,
                                      bottom: SizeConfig.blockSizeVertical * 4,
                                    ),
                                    child:
                                        Center(child: Text('No Answers Yet')),
                                  ),
                                ],
                              ),
                      ],
                    ), */
                  ],
                ),
              ),
            ),
    );
  }
}
