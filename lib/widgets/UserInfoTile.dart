import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/models/User.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/screens/other/UserProfile.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:flutter/material.dart';
import 'package:answer_me/widgets/QuestionAnswerListItem.dart';

enum Type { author, answerer }

class UserInfoTile extends StatelessWidget {
  final Type type;
  final User author;
  final int votes;
  final String answeredOn;
  final int bestAnswer;
  final int answerId;
  final int isAnonymous;
  final int answerUserId;
  final AnswerType answerType;
  final Question question;
  final Function getQuestion;

  const UserInfoTile({
    Key key,
    this.type,
    this.author,
    this.votes,
    this.answeredOn,
    this.bestAnswer,
    this.answerId,
    this.isAnonymous = 0,
    this.answerUserId,
    this.question,
    this.answerType,
    this.getQuestion,
  }) : super(key: key);

  _navigateToAuthorProfile(BuildContext context) {
    if (author.id != 0 && isAnonymous == 0)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => UserProfile(authorId: author.id)),
      );
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Row(
      children: [
        _buildUserImage(context),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 2.7),
        Expanded(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserName(context),
                  // _buildUserRoleAndState(context),
                  SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                  type == Type.answerer
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Answer On $answeredOn',
                              style: TextStyle(
                                fontSize: SizeConfig.safeBlockHorizontal * 3.4,
                                color: theme.isDarkTheme()
                                    ? Colors.white60
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
              // Spacer(),
              // Icon(
              //   FluentIcons.person_add_24_regular,
              //   color: Colors.black,
              //   size: SizeConfig.blockSizeHorizontal * 6,
              // ),
            ],
          ),
        ),
      ],
    );
  }

  _buildUserImage(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToAuthorProfile(context),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage:
            author != null && author.avatar != null && isAnonymous == 0
                ? NetworkImage(author.avatar)
                : AssetImage('assets/images/user_icon.png'),
        maxRadius: answerType == AnswerType.reply
            ? SizeConfig.blockSizeHorizontal * 4
            : SizeConfig.blockSizeHorizontal * 6,
      ),
    );
  }

  _buildUserName(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _navigateToAuthorProfile(context),
          child: Text(
            author != null && isAnonymous == 0
                ? author.displayname
                : 'Anonymous',
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 4.2,
              fontWeight:
                  type == Type.author ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
        Consumer<AuthProvider>(
          builder: (context, auth, _) => type == Type.answerer &&
                  answerType == AnswerType.answer &&
                  auth.user != null &&
                  auth.user.id == question.authorId &&
                  answerUserId != question.authorId
              ? bestAnswer == null
                  ? _buildBestAnswerButton(
                      name: 'Set as Best Answer',
                      backgroundColor: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      border: Border(),
                      onPressed: () async =>
                          await ApiRepository.setAsBestAnswer(
                        context,
                        questionId: question.id,
                        answerId: answerId,
                      ).then((value) => getQuestion()),
                    )
                  : bestAnswer != null && bestAnswer == answerId
                      ? _buildBestAnswerButton(
                          name: 'Best Answer',
                          backgroundColor: Colors.transparent,
                          textColor: Theme.of(context).primaryColor,
                          border: Border.all(
                            width: 1,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () => null,
                        )
                      : Container()
              : Container(),
        )
      ],
    );
  }

  // _buildUserRoleAndState(BuildContext context) {
  //   return author.badge != null
  //       ? Row(
  //           children: [
  //             Container(
  //               padding: EdgeInsets.symmetric(
  //                 horizontal: SizeConfig.blockSizeHorizontal * 2.4,
  //                 vertical: SizeConfig.blockSizeVertical * 0.2,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: colorConvert(author.badge.color),
  //                 borderRadius: BorderRadius.circular(
  //                   SizeConfig.blockSizeHorizontal * 0.7,
  //                 ),
  //               ),
  //               child: Text(
  //                 author.badge.name,
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: SizeConfig.safeBlockHorizontal * 3.3,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
  //             Consumer<AuthProvider>(
  //               builder: (context, auth, _) => type == Type.answerer &&
  //                       answerType == AnswerType.answer &&
  //                       auth.user != null &&
  //                       auth.user.id == question.authorId
  //                   ? bestAnswer == null
  //                       ? _buildBestAnswerButton(
  //                           name: 'Set as Best Answer',
  //                           backgroundColor: Theme.of(context).primaryColor,
  //                           textColor: Colors.white,
  //                           border: Border(),
  //                           onPressed: () async =>
  //                               await ApiRepository.setAsBestAnswer(
  //                             context,
  //                             questionId: question.id,
  //                             answerId: answerId,
  //                           ).then((value) => getQuestion()),
  //                         )
  //                       : bestAnswer != null && bestAnswer == answerId
  //                           ? _buildBestAnswerButton(
  //                               name: 'Best Answer',
  //                               backgroundColor: Colors.transparent,
  //                               textColor: Theme.of(context).primaryColor,
  //                               border: Border.all(
  //                                 width: 1,
  //                                 color: Theme.of(context).primaryColor,
  //                               ),
  //                               onPressed: () => null,
  //                             )
  //                           : Container()
  //                   : Container(),
  //             )
  //           ],
  //         )
  //       : Container();
  // }

  _buildBestAnswerButton({
    String name,
    Color backgroundColor,
    Color textColor,
    BoxBorder border,
    Function onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 2.4,
          vertical: SizeConfig.blockSizeVertical * 0.6,
        ),
        decoration: BoxDecoration(color: backgroundColor, border: border),
        child: Text(
          name,
          style: TextStyle(
            color: textColor,
            fontSize: SizeConfig.safeBlockHorizontal * 3.3,
          ),
        ),
      ),
    );
  }
}
