import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Notification.dart' as n;
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/QuestionDetail.dart';
import 'package:answer_me/screens/other/UserProfile.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationListItem extends StatelessWidget {
  final n.Notification notification;
  final Function deleteNotification;

  const NotificationListItem(
      {Key key, this.notification, this.deleteNotification})
      : super(key: key);

  _navigateToRequiredScreen(BuildContext context) {
    if (notification.questionId != null)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) =>
              QuestionDetailScreen(questionId: notification.questionId),
        ),
      );
    else if (notification.authorId != null)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => UserProfile(authorId: notification.authorId),
        ),
      );
  }

  _deleteNotification(BuildContext context) async {
    await deleteNotification(notification);
    ApiRepository.deleteUserNotification(context, id: notification.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical),
          child: Column(
            children: [
              InkWell(
                onTap: () => _navigateToRequiredScreen(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildNotificationImage(context),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 4.5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _buildNotificationTitle(context, theme),
                          SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                          _buildNotificationDate(theme),
                          SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
                        ],
                      ),
                    ),
                    _buildDismissButton(context),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
                color: Theme.of(context).dividerColor,
                indent: SizeConfig.blockSizeHorizontal * 15,
                endIndent: SizeConfig.blockSizeHorizontal * 15,
              ),
            ],
          ),
        );
      },
    );
  }

  _buildNotificationImage(BuildContext context) {
    return CircleAvatar(
      maxRadius: SizeConfig.blockSizeHorizontal * 6,
      backgroundColor: Theme.of(context).primaryColor,
      child: notification.questionId != null
          ? Icon(Icons.question_answer, color: Colors.white)
          : Icon(Icons.person, color: Colors.white),
    );
  }

  _buildNotificationTitle(BuildContext context, ThemeProvider theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            notification.message,
            style: TextStyle(
              color: theme.isDarkTheme()
                  ? Colors.white70
                  : Colors.black.withOpacity(0.75),
              fontSize: SizeConfig.safeBlockHorizontal * 4,
            ),
          ),
        ),
      ],
    );
  }

  _buildNotificationDate(ThemeProvider theme) {
    return Container(
      child: Text(
        '${getTimeAgo(notification.createdAt)}',
        style: TextStyle(
          fontSize: SizeConfig.safeBlockHorizontal * 3.4,
          color: theme.isDarkTheme() ? Colors.white54 : Colors.black54,
        ),
      ),
    );
  }

  _buildDismissButton(BuildContext context) {
    return SizedBox(
      width: SizeConfig.blockSizeHorizontal * 15,
      height: SizeConfig.blockSizeVertical * 4,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.only(left: 5),
        ),
        onPressed: () => _deleteNotification(context),
        child: Icon(Icons.close, color: Theme.of(context).primaryColor),
      ),
    );
  }
}
