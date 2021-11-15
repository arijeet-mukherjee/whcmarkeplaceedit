import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Conversation.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final Function onTap;
  const ConversationCard({
    this.conversation,
    Key key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider _theme = Provider.of<ThemeProvider>(context, listen: false);
    return ListTile(
      onTap: onTap,
      leading: ClipOval(
        child: Image.network(
          conversation.user.avatar != null
              ? conversation.user.avatar
              : 'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
          width: SizeConfig.blockSizeHorizontal * 12.5,
          height: SizeConfig.blockSizeHorizontal * 12.5,
          fit: BoxFit.cover,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            conversation.user.displayname,
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 4.8,
            ),
          ),
          Text(
            '${timeago.format(conversation.messages.last.createdAt)}',
            style: TextStyle(
              color: _theme.isDarkTheme() ? Colors.white70 : Colors.black54,
              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
            ),
          ),
          
        ],
      ),
      subtitle: Text(
        conversation.messages.last.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 3.8),
      ),
    );
  }
}
