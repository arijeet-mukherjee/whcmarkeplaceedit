import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Conversation.dart';
import 'package:answer_me/models/Message.dart';
import 'package:answer_me/models/ResultOption.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/AskQuestion.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/Utils.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/QuestionPollImageListItem.dart';
import 'package:answer_me/widgets/QuestionPollListItem.dart';
import 'package:answer_me/widgets/QuestionPollResultListItem.dart';
import 'package:answer_me/widgets/TagsWrap.dart';
import 'package:answer_me/widgets/UserInfoTile.dart';
import 'package:answer_me/widgets/VoteButtons.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autolink_text/flutter_autolink_text.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:toast/toast.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:answer_me/models/User.dart' as u;
class QuestionDetailItem extends StatefulWidget {
  final Question question;
  final Function answerQuestion;
  final Function getQuestion;
  final bool answerBtnEnabled;
  final Function addToFav;
  final Function removeFromFav;
  final String endpoint;
  

  const QuestionDetailItem({
    Key key,
    this.question,
    this.answerQuestion,
    this.getQuestion,
    this.answerBtnEnabled,
    this.addToFav,
    this.removeFromFav,
    this.endpoint,
  }) : super(key: key);

  @override
  _QuestionDetailItemState createState() => _QuestionDetailItemState();
}

class _QuestionDetailItemState extends State<QuestionDetailItem> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reportController = TextEditingController();
  int _selectedOption;
  AuthProvider _authProvider;
  ThemeProvider _themeProvider;
  bool _showResults = false;
  bool _loadingPolls = false;
  bool _isBookmark = false;
  ResultOption _resultOptions;
  //Adding here
  Conversation conversation;

  Message message;
  //End Here
  _onOptionSelected(int option) {
    setState(() {
      _selectedOption = option;
    });
  }

  _submitOption() async {
    if (_selectedOption != 0) {
      await ApiRepository.submitOption(
        context,
        userId: _authProvider.user != null ? _authProvider.user.id : 0,
        questionId: widget.question.id,
        optionId: _selectedOption,
      ).then((value) => _checkIfOptionSelected());
    } else {
      Toast.show('Please select an option', context, duration: 2);
    }
  }

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (widget.question.bookmark == 1)
      _isBookmark = true;
    else
      _isBookmark = false;

    if (widget.question.polled == 1) {
      _checkIfOptionSelected();
    }
    //added 
    message = Message();
  }

  _checkIfOptionSelected() async {
    setState(() {
      _loadingPolls = true;
    });
    await ApiRepository.checkIfOptionSelected(
      context,
      questionId: widget.question.id,
      userId: _authProvider.user != null ? _authProvider.user.id : 0,
    ).then((value) {
      setState(() {
        _selectedOption = value;
      });
      if (value != 0)
        _displayVoteReult();
      else
        setState(() {
          _loadingPolls = false;
        });
    });
  }

  _updateVotes() {
    setState(() {});
  }

  _displayVoteReult() async {
    await ApiRepository.displayVoteResult(
      context,
      questionId: widget.question.id,
      userId: _authProvider.user != null ? _authProvider.user.id : 0,
    ).then((value) {
      setState(() {
        _resultOptions = value;
        if (_resultOptions.votesCount != 0) {
          setState(() {
            _showResults = true;
          });
        } else {
          Toast.show(
            'No Result yet, be the first answering this question!',
            context,
            duration: 2,
          );
        }
      });

      setState(() {
        _loadingPolls = false;
      });
    });
  }

  _submitReport(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      AuthProvider _auth = Provider.of<AuthProvider>(context, listen: false);
      await ApiRepository.submitReport(
        context,
        userId: _auth.user != null ? _auth.user.id : 0,
        questionId: widget.question.id,
        content: _reportController.text,
        type: 'Question',
      ).then((value) => Navigator.of(context).pop());
    }
  }

  _shareQuestion() {
    try {
      if (UniversalPlatform.isAndroid) {
        Share.share(
          '${widget.question.title}. By ${widget.question.author.displayname}\n\n$SHARE_TEXT\n$ANDROID_SHARE_URL',
          subject: widget.question.title,
        );
      } else if (UniversalPlatform.isIOS) {
        Share.share(
          '${widget.question.title}. By ${widget.question.author.displayname}\n\n$SHARE_TEXT\n$IOS_SHARE_URL',
          subject: widget.question.title,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  _openActions() {
    showModalBottomSheet(
      context: context,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return _buildBottomNavigationMenu();
      },
    );
  }

  _selectAction(String name) async {
    Navigator.pop(context);
    switch (name) {
      case 'Report':
        showCustomDialogWithTitle(
          context,
          title: 'Report',
          body: Form(
            key: _formKey,
            child: CustomTextField(
              label: 'Message',
              labelSize: SizeConfig.safeBlockHorizontal * 4,
              controller: _reportController,
            ),
          ),
          onTapCancel: () => Navigator.pop(context),
          onTapSubmit: () => _submitReport(context),
        );
        break;
      case 'Bookmark':
        setState(() {
          _isBookmark = !_isBookmark;
        });
        await ApiRepository.addToBookmarks(
          context,
          userId: _authProvider.user.id,
          questionId: widget.question.id,
        ).then((value) async {
          if (!_isBookmark)
            await widget.removeFromFav(widget.question.id);
          else {
            await widget.addToFav(widget.question.id);
            await Provider.of<AppProvider>(context, listen: false)
                .clearBookmarkQuestions();
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.only(
        top: SizeConfig.blockSizeVertical * 3,
        bottom: SizeConfig.blockSizeVertical,
      ),
      margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryAndDate(theme),
          //SizedBox(height: SizeConfig.blockSizeVertical * 2),
         // _buildUserInfo(),
          SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
          _buildQuestionTitle(context),
          _buildQuestionPoll(context, theme),
          _buildDescription(context, theme),
         // _buildVideoButton(context),
          //_buildFeaturedImage(),
         // _buildTags(context),
          _buildViewsText(context, theme),
          (_authProvider.user != null && widget.question != null) &&
                _authProvider.user.id == widget.question.authorId
            ?Container():
          Divider(thickness: 1, color: Theme.of(context).dividerColor),
          (_authProvider.user != null && widget.question != null) &&
                _authProvider.user.id == widget.question.authorId
            ?Container():
          SizedBox(height: SizeConfig.blockSizeVertical * 0.2),
          (_authProvider.user != null && widget.question != null) &&
                _authProvider.user.id == widget.question.authorId
            ?Container():
          _buildActionsRow(context, theme),
        ],
      ),
    );
  }

  _buildFeaturedImage() {
    return widget.question.featuredImage != null
        ? Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.blockSizeVertical * 2,
            ),
            child: GestureDetector(
              onTap: () => showImagePreviewDialog(
                context,
                widget.question.featuredImage,
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: SizeConfig.blockSizeVertical * 30,
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
                      '${ApiRepository.FEATURED_IMAGES_PATH}${widget.question.featuredImage}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical),
                ],
              ),
            ),
          )
        : Container();
  }

  _buildCategoryAndDate(ThemeProvider theme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: widget.question.category != null
          ? Text(
              '${formatDate(widget.question.createdAt)}',
              style: TextStyle(
                color: theme.isDarkTheme() ? Colors.white70 : Colors.black54,
                fontSize: SizeConfig.safeBlockHorizontal * 3.4,
              ),
            )
          : Container(),
    );
  }

  _buildQuestionTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Text(
        widget.question.title,
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 4.8,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }

  _buildVideoButton(BuildContext context) {
    return widget.question.videoURL != null
        ? Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.blockSizeVertical * 2,
              left: SizeConfig.blockSizeHorizontal * 6,
              right: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => launchURL(widget.question.videoURL),
                  child: Container(
                    width: double.infinity,
                    height: SizeConfig.blockSizeVertical * 6.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                      borderRadius: BorderRadius.circular(
                        SizeConfig.safeBlockHorizontal * 10,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockSizeHorizontal,
                        vertical: SizeConfig.blockSizeVertical * 1.1,
                      ),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Watch Video'.toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                                fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  _buildUserInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: UserInfoTile(
              type: Type.author,
              author: widget.question.author,
              isAnonymous: widget.question.anonymous,
            ),
          ),
          //Vote Option
          /* Container(
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: VoteButtons(
              votes: widget.question.votes,
              questionId: widget.question.id,
              type: VoteType.question,
              userId: widget.question.authorId,
              updateVotes: _updateVotes,
              endpoint: widget.endpoint,
            ),
          ), */
          //Vote End
        ],
      ),
    );
  }

  _buildDescription(BuildContext context, ThemeProvider theme) {
    if (widget.question.content.isNotEmpty)
      return Padding(
        padding: EdgeInsets.only(
          top: SizeConfig.blockSizeVertical,
          left: SizeConfig.blockSizeHorizontal * 6,
          right: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: AutolinkText(
          humanize: false,
          onWebLinkTap: (link) => launchURL(link),
          text: widget.question.content,
          textStyle: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.1,
            fontWeight: FontWeight.w400,
            color: theme.isDarkTheme()
                ? Colors.white.withOpacity(0.8)
                : Colors.black87,
            height: 1.2,
          ),
          linkStyle: TextStyle(color: Theme.of(context).primaryColor),
        ),
      );
    else
      return Container();
  }

  _buildTags(BuildContext context) {
    return widget.question.tags.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.blockSizeVertical * 2,
              left: SizeConfig.blockSizeHorizontal * 6,
              right: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: TagsWrap(questionTags: widget.question.tags))
        : Container();
  }

  _buildViewsText(BuildContext context, ThemeProvider theme) {
    return Padding(
      padding: EdgeInsets.only(
        top: SizeConfig.blockSizeVertical,
        left: SizeConfig.blockSizeHorizontal * 6,
        right: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Text(
        widget.question.views == 1
            ? '${widget.question.views} view'
            : '${widget.question.views} views',
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 3.5,
          fontWeight: FontWeight.w400,
          color: theme.isDarkTheme() ? Colors.white60 : Colors.black54,
          height: 1.2,
        ),
      ),
    );
  }

  _buildActionsRow(BuildContext context, ThemeProvider theme) {
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
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 4.5,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: FittedBox(
                      child: Text(
                        'Reply',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      AuthProvider _authProvider =
                          Provider.of<AuthProvider>(context, listen: false);
                      if (_authProvider.user != null) {
                        showCupertinoModalBottomSheet(
                          context: context,
                          elevation: 0,
                          topRadius: Radius.circular(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          builder: (context) => AskQuestionScreen(
                            questionId: widget.question.id,
                            answer: true,
                            getQuestion: widget.getQuestion,
                            authorId: widget.question.authorId,
                          ),
                        );
                        //Adding to chat

                      } else {
                        Toast.show(
                            'You need to login to answer questions', context);
                      }
                    },
                  ),
                ),
                SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                Row(
                  children: [
                    /* Icon(
                      EvaIcons.messageCircleOutline,
                      color:
                          theme.isDarkTheme() ? Colors.white70 : Colors.black54,
                      size: SizeConfig.blockSizeHorizontal * 5.6,
                    ), */
                    /* SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                    Text(
                      '${widget.question.answersCount != null ? widget.question.answersCount : 0}',
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                        fontWeight: FontWeight.w500,
                        color: theme.isDarkTheme()
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ), */
                    /* SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                    widget.question.polled == 1
                        ? Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: theme.isDarkTheme()
                                    ? Colors.white70
                                    : Colors.black54,
                                size: SizeConfig.blockSizeHorizontal * 5.8,
                              ),
                              SizedBox(
                                  width: SizeConfig.blockSizeHorizontal * 2),
                              Text(
                                widget.question.userOptionsCount.toString(),
                                style: TextStyle(
                                  fontSize:
                                      SizeConfig.safeBlockHorizontal * 3.5,
                                  fontWeight: FontWeight.w400,
                                  color: theme.isDarkTheme()
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          )
                        : Container(), */
                  ],
                ),
                /* SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                GestureDetector(
                  onTap: _shareQuestion,
                  child: Icon(
                    FluentIcons.share_android_24_regular,
                    color:
                        theme.isDarkTheme() ? Colors.white70 : Colors.black54,
                    size: SizeConfig.blockSizeHorizontal * 6,
                  ),
                ), */
                GestureDetector(
                  onTap: _openActions,
                  child: Icon(
                    EvaIcons.moreHorizotnalOutline,
                    color:
                        theme.isDarkTheme() ? Colors.white70 : Color(0xFF480000),
                    size: SizeConfig.blockSizeHorizontal * 6.2,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildQuestionPoll(BuildContext context, ThemeProvider theme) {
    return widget.question.polled == 1
        ? Column(
            children: [
              SizedBox(height: SizeConfig.blockSizeVertical * 1.5),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 5,
                  vertical: SizeConfig.blockSizeVertical * 3,
                ),
                color:
                    theme.isDarkTheme() ? Colors.black26 : Colors.grey.shade200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(
                            FluentIcons.question_16_regular,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: SizeConfig.blockSizeHorizontal * 4,
                            ),
                            child: Text(
                              'Participate in poll, Choose your answer',
                              style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 4,
                              ),
                            ),
                          ),
                          _loadingPolls
                              ? Container(
                                  height: SizeConfig.blockSizeVertical * 20,
                                  child: Center(
                                      child: SizedBox(
                                    height: SizeConfig.blockSizeVertical * 4,
                                    width: SizeConfig.blockSizeVertical * 4,
                                    child: CircularProgressIndicator(),
                                  )),
                                )
                              : Column(
                                  children: [
                                    !_showResults
                                        ? widget.question.imagePolled == 0
                                            ? ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: widget
                                                    .question.options.length,
                                                itemBuilder: (context, i) =>
                                                    QuestionPollListItem(
                                                  question: widget.question,
                                                  index: i,
                                                  selected: _selectedOption ==
                                                          widget.question
                                                              .options[i].id
                                                      ? true
                                                      : false,
                                                  onOptionSelected:
                                                      _onOptionSelected,
                                                ),
                                              )
                                            : Container(
                                                height: SizeConfig
                                                        .blockSizeVertical *
                                                    28,
                                                padding: EdgeInsets.only(
                                                  left: SizeConfig
                                                          .blockSizeHorizontal *
                                                      4,
                                                ),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: widget
                                                      .question.options.length,
                                                  itemBuilder: (context, i) =>
                                                      QuestionPollImageListItem(
                                                    question: widget.question,
                                                    index: i,
                                                    selected: _selectedOption ==
                                                            widget.question
                                                                .options[i].id
                                                        ? true
                                                        : false,
                                                    onOptionSelected:
                                                        _onOptionSelected,
                                                  ),
                                                ),
                                              )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.only(
                                              top: SizeConfig.blockSizeVertical,
                                            ),
                                            itemCount:
                                                _resultOptions.options.length,
                                            itemBuilder: (context, i) =>
                                                QuestionPollResultListItem(
                                              option: _resultOptions.options[i],
                                              count: _resultOptions.votesCount,
                                            ),
                                          ),
                                    !_showResults
                                        ? Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: SizeConfig
                                                          .blockSizeHorizontal *
                                                      4,
                                                  top: SizeConfig
                                                      .blockSizeVertical,
                                                ),
                                                child: TextButton(
                                                  onPressed: () {
                                                    if (_authProvider.user !=
                                                            null &&
                                                        _authProvider.user.id !=
                                                            null) {
                                                      _submitOption();
                                                    } else {
                                                      Toast.show(
                                                        'You have to login to answer polls',
                                                        context,
                                                        duration: 2,
                                                      );
                                                    }
                                                  },
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Submit',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(
                                              left: SizeConfig
                                                      .blockSizeHorizontal *
                                                  4,
                                              top:
                                                  SizeConfig.blockSizeVertical *
                                                      2,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Based on ',
                                                  style: TextStyle(
                                                    color: theme.isDarkTheme()
                                                        ? Colors.white60
                                                        : Colors.black54,
                                                    fontSize: SizeConfig
                                                            .safeBlockHorizontal *
                                                        4,
                                                  ),
                                                ),
                                                Text(
                                                  '(${_resultOptions.votesCount} voters)',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  Column _buildBottomNavigationMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: SizeConfig.blockSizeVertical),
        Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                padding: EdgeInsets.only(right: 10),
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                child: Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        ListTile(
          leading: !_isBookmark
              ? Icon(
                  EvaIcons.bookmarkOutline,
                  color: _themeProvider.isDarkTheme()
                      ? Colors.white
                      : Colors.black,
                )
              : Icon(EvaIcons.bookmark, color: Theme.of(context).primaryColor),
          title: Text(
            !_isBookmark ? 'Add Bookmark' : 'Remove Bookmark',
            style: TextStyle(
              color: _isBookmark
                  ? Theme.of(context).primaryColor
                  : _themeProvider.isDarkTheme()
                      ? Colors.white
                      : Colors.black,
            ),
          ),
          onTap: () => _selectAction('Bookmark'),
        ),
        Divider(height: 0, indent: 15, endIndent: 15, thickness: 0.5),
        ListTile(
          leading: Icon(EvaIcons.flagOutline,
              color:
                  _themeProvider.isDarkTheme() ? Colors.white : Colors.black),
          title: Text('Report Inappropriate Content'),
          onTap: () => _selectAction('Report'),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 4),
      ],
    );
  }
}
