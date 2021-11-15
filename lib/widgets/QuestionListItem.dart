// import 'package:admob_flutter/admob_flutter.dart';
import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/QuestionDetail.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/TagsWrap.dart';
import 'package:answer_me/widgets/UserInfoTile.dart';
import 'package:answer_me/widgets/VoteButtons.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:universal_platform/universal_platform.dart';

import 'ExpandableText.dart';

class QuestionListItem extends StatefulWidget {
  final Question question;
  final Function addToFav;
  final Function fetchData;
  final Function removeFromFav;
  final String endpoint;

  const QuestionListItem(
      {Key key,
      this.question,
      this.addToFav,
      this.fetchData,
      this.removeFromFav,
      this.endpoint})
      : super(key: key);

  @override
  _QuestionListItemState createState() => _QuestionListItemState();
}

class _QuestionListItemState extends State<QuestionListItem> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reportController = TextEditingController();
  AppProvider _appProvider;
  AuthProvider _authProvider;
  ThemeProvider _themeProvider;
  bool _isBookmark = false;
  // AdmobInterstitial interstitialAd = AdmobInterstitial(
  //   adUnitId: AdmobConfig.interstitualAdUnitId,
  // );

  _navigateToQuestionDetail(BuildContext context, {bool answer = false}) async {
    await _appProvider.incrementAdClickCount();

    // if (_appProvider.adClickCount > 9) {
    //   if (await interstitialAd.isLoaded) {
    //     interstitialAd.show();
    //   } else {
    //     print('Interstitial ad is still loading...');
    //   }
    //   await _appProvider.resetAdClickCount();
    // }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => QuestionDetailScreen(
          questionId: widget.question.id,
          answerBtnEnabled: answer,
          endpoint: widget.endpoint,
          fetchData: widget.fetchData,
        ),
      ),
    );
  }

  _updateVotes() {
    setState(() {});
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

  @override
  void initState() {
    super.initState();
    _appProvider = Provider.of<AppProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // interstitialAd = AdmobInterstitial(
    //   adUnitId: AdmobConfig.interstitualAdUnitId,
    //   listener: (AdmobAdEvent event, Map<String, dynamic> args) {
    //     if (event == AdmobAdEvent.closed) interstitialAd.load();
    //   },
    // );

    // interstitialAd.load();

    if (widget.question.bookmark == 1)
      _isBookmark = true;
    else
      _isBookmark = false;
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
        _authProvider.user != null
            ? Column(
                children: [
                  ListTile(
                    leading: !_isBookmark
                        ? Icon(
                            EvaIcons.bookmarkOutline,
                            color: _themeProvider.isDarkTheme()
                                ? Colors.white
                                : Colors.black,
                          )
                        : Icon(EvaIcons.bookmark,
                            color: Theme.of(context).primaryColor),
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
                  Divider(
                    height: 0,
                    indent: 15,
                    endIndent: 15,
                    thickness: 0.5,
                    color: Theme.of(context).dividerColor,
                  ),
                ],
              )
            : Container(),
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

  _selectAction(String name) async {
    Navigator.pop(context);
    switch (name) {
      case 'Report':
        showCustomDialogWithTitle(
          context,
          title: 'Report Inappropriate Content',
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
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _checkIfIsBookmark();
  // }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
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
         // SizedBox(height: SizeConfig.blockSizeVertical * 2),
          //Author Section End
          /* Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: UserInfoTile(
              type: Type.author,
              author: widget.question.author,
              isAnonymous: widget.question.anonymous,
            ),
          ), */
          //Author Section End
          SizedBox(height: SizeConfig.blockSizeVertical),
          _buildQuestionTitle(context),
          _buildDescription(context, theme),
          //Image Removed
         // _buildFeaturedImage(context),
         // _buildTags(context),
         SizedBox(height: SizeConfig.blockSizeVertical),
          _buildViewsText(context, theme),
         /*  Divider(thickness: 1, color: Theme.of(context).dividerColor),
          _buildActionsRow(context, auth, theme), */
        ],
      ),
    );
  }

  _buildFeaturedImage(BuildContext context) {
    return widget.question.featuredImage != null
        ? Padding(
            padding: EdgeInsets.symmetric(
              vertical: SizeConfig.blockSizeVertical,
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _navigateToQuestionDetail(context),
                  child: Container(
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
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
              ],
            ),
          )
        : Container();
  }

  _buildCategoryAndDate(ThemeProvider theme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          widget.question.category != null
          ? Text(
              '${formatDate(widget.question.createdAt)}',
              style: TextStyle(
                color: theme.isDarkTheme() ? Colors.white70 : Colors.black54,
                fontSize: SizeConfig.safeBlockHorizontal * 3.4,
              ),
            )
          : Container(),
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
          )
          )
          ],
          
          ),
    );
  }

  _buildQuestionTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        onTap: () => _navigateToQuestionDetail(context),
        child: Text(
          widget.question.title,
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
    if (widget.question.content.isNotEmpty)
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.blockSizeVertical,
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: GestureDetector(
          onTap: () => _navigateToQuestionDetail(context),
          child: ExpandableText(
            widget.question.content,
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
    else
      return Container();
  }

  _buildViewsText(BuildContext context, ThemeProvider theme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.start,
      children: [
          Expanded(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                       
             
              GestureDetector(
              onTap: () => _navigateToQuestionDetail(context),
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
            ),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 1.5),
            GestureDetector(
                      onTap: () => _navigateToQuestionDetail(context),
                      child: Icon(
                        EvaIcons.arrowIosForwardOutline,
                        color: theme.isDarkTheme()
                            ? Colors.white70
                            : Color(0xFF480000),
                        size: SizeConfig.blockSizeHorizontal * 5.6,
                      ),
                    ),
          
          
        ],))
      ],)
    );
  }

  _buildTags(BuildContext context) {
    return widget.question.tags.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              top: SizeConfig.blockSizeVertical,
              left: SizeConfig.blockSizeHorizontal * 6,
              right: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: TagsWrap(questionTags: widget.question.tags))
        : Container();
  }

  _buildActionsRow(
      BuildContext context, AuthProvider auth, ThemeProvider theme) {
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
                //SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToQuestionDetail(context),
                      child: Icon(
                        EvaIcons.messageCircleOutline,
                        color: theme.isDarkTheme()
                            ? Colors.white70
                            : Color(0xFF480000),
                        size: SizeConfig.blockSizeHorizontal * 5.6,
                      ),
                    ),
                    /* SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                    GestureDetector(
                      onTap: () => _navigateToQuestionDetail(context),
                      child: Text(
                        '${widget.question.answersCount != null ? widget.question.answersCount : 0}',
                        style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                          fontWeight: FontWeight.w500,
                          color: theme.isDarkTheme()
                              ? Colors.white70
                              : Color(0xFF480000),
                        ),
                      ),
                    ), */
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
                    /* widget.question.polled == 1
                        ? Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: theme.isDarkTheme()
                                    ? Colors.white70
                                    : Color(0xFF480000),
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
}
