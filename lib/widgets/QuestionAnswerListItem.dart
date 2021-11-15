import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Comment.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/AskQuestion.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/Utils.dart';
import 'package:answer_me/widgets/UserInfoTile.dart';
import 'package:answer_me/widgets/VoteButtons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autolink_text/flutter_autolink_text.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:toast/toast.dart';

enum AnswerType { answer, reply }

class QuestionAnswerListItem extends StatefulWidget {
  final Function replyOnPressed;
  final Function cancelOnPressed;
  final Function getQuestion;
  final Comment answer;
  final Question question;
  final int bestAnswer;
  final int questionId;
  final bool hasActions;
  final bool last;
  final AnswerType type;
  final GlobalKey globalKey;
  final int index;
  final Function replyToAnswer;
  final ScrollController controller;
  final Function removeComment;

  const QuestionAnswerListItem({
    Key key,
    this.replyOnPressed,
    this.cancelOnPressed,
    this.getQuestion,
    this.answer,
    this.index,
    this.bestAnswer,
    this.questionId,
    this.question,
    this.hasActions = true,
    this.last = false,
    this.type = AnswerType.answer,
    this.globalKey,
    this.controller,
    this.replyToAnswer,
    this.removeComment,
  }) : super(key: key);

  @override
  _QuestionAnswerListItemState createState() => _QuestionAnswerListItemState();
}

class _QuestionAnswerListItemState extends State<QuestionAnswerListItem> {
  AutoScrollController _controller;
  ThemeProvider _themeProvider;
  AuthProvider _authProvider;
  bool _isDeleting = false;

  final _formKey = GlobalKey<FormState>();
  final replykey = new GlobalKey();

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  _deleteComment() async {
    setState(() {
      _isDeleting = true;
    });
    await ApiRepository.deleteComment(context, commentId: widget.answer.id);
    await widget.removeComment(widget.answer.id);
    setState(() {
      _isDeleting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _controller,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Divider(height: 2, thickness: 1),
        !widget.hasActions
            ? SizedBox(height: SizeConfig.blockSizeVertical * 2)
            : Container(),
        Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.only(
              bottom: widget.last ? 0 : SizeConfig.blockSizeVertical * 0.8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height:
                      widget.hasActions ? SizeConfig.blockSizeVertical * 2 : 0,
                ),
                _buildAuthorInfoAndFollowButton(),
                SizedBox(height: SizeConfig.blockSizeVertical),
                _buildFeaturedImage(context),
                _buildDescription(context),
                widget.last
                    ? Container()
                    : Padding(
                        padding: EdgeInsets.only(
                          left: widget.hasActions
                              ? 0
                              : SizeConfig.blockSizeHorizontal * 5,
                        ),
                        child: widget.hasActions
                            ? Divider(
                                indent: SizeConfig.blockSizeHorizontal * 21,
                              )
                            : Container(height: SizeConfig.blockSizeVertical),
                      ),
                SizedBox(
                  height: widget.last ? 0 : SizeConfig.blockSizeVertical * 0.2,
                ),
                widget.hasActions ? _buildActionsRow(context) : Container(),
                SizedBox(
                  height: widget.hasActions ? SizeConfig.blockSizeVertical : 0,
                ),
                _buildAnswerReplies(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildAuthorInfoAndFollowButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 4,
      ),
      child: Row(
        children: [
          Expanded(
            child: UserInfoTile(
              type: Type.answerer,
              author: widget.answer.author,
              answeredOn: widget.answer.date,
              bestAnswer: widget.bestAnswer,
              answerId: widget.answer.id,
              answerType: widget.type,
              question: widget.question,
              getQuestion: widget.getQuestion,
              answerUserId: widget.answer.authorId,
              isAnonymous: widget.answer.anonymous,
            ),
          ),
          _authProvider.user.id == widget.answer.author.id
              ? GestureDetector(
                  onTap: () => _deleteComment(),
                  child: _isDeleting
                      ? Center(
                          child: SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 5,
                          height: SizeConfig.blockSizeHorizontal * 5,
                          child: CircularProgressIndicator(),
                        ))
                      : Icon(FluentIcons.delete_16_regular),
                )
              : Container(),
        ],
      ),
    );
  }

  _buildFeaturedImage(BuildContext context) {
    return widget.answer.featuredImage != null
        ? GestureDetector(
            onTap: () => showImagePreviewDialog(
              context,
              widget.answer.featuredImage,
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: SizeConfig.blockSizeVertical * 30,
                  child: Image.network(
                    '${ApiRepository.FEATURED_IMAGES_PATH}${widget.answer.featuredImage}',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
              ],
            ),
          )
        : Container();
  }

  _buildDescription(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.hasActions
            ? SizeConfig.blockSizeHorizontal * 19
            : SizeConfig.blockSizeHorizontal * 14.5,
        right: SizeConfig.blockSizeHorizontal * 2,
      ),
      child: AutolinkText(
        humanize: false,
        onWebLinkTap: (link) => launchURL(link),
        text: widget.answer.content,
        textStyle: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 4.1,
          fontWeight: FontWeight.w400,
          color: _themeProvider.isDarkTheme()
              ? Colors.white.withOpacity(0.8)
              : Colors.black87,
          height: 1.2,
        ),
        linkStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }

  _buildActionsRow(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: SizeConfig.blockSizeHorizontal * 19,
        right: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /* VoteButtons(
            commentId: widget.answer.id,
            votes: widget.answer.votes,
            type: VoteType.comment,
          ), */
          Spacer(),
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
                        answerId: widget.answer.id,
                        answer: true,
                        reply: true,
                        getQuestion: widget.getQuestion,
                      ),
                    );
                  } else {
                    Toast.show(
                        'You need to login to answer questions', context);
                  }
                }),
          ),
        ],
      ),
    );
  }

  _buildAnswerReplies(BuildContext context) {
    return widget.answer.replies != null
        ? ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.answer.replies.length,
            itemBuilder: (ctx, i) => Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal * 10,
                right: SizeConfig.blockSizeHorizontal * 2,
              ),
              child: Column(
                children: [
                  QuestionAnswerListItem(
                    answer: widget.answer.replies[i],
                    questionId: widget.questionId,
                    hasActions: false,
                    last: i == widget.answer.replies.length - 1 ? true : false,
                    type: AnswerType.reply,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
