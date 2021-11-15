import 'package:answer_me/models/Message.dart';
import 'package:flutter/material.dart';

class FriendMessageCard extends StatelessWidget {
  final Message message;
  final String imageUrl;
  const FriendMessageCard({
    Key key,
    this.message,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // CircleAvatar(
    //   backgroundImage: NetworkImage(imageUrl != null
    //       ? imageUrl
    //       : 'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png'),
    //   radius: SizeConfig.safeBlockHorizontal * 5,
    // ),
    return Container(
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 8, right: 0),
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(right: 20),
        padding: EdgeInsets.only(top: 13, bottom: 13, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: [const Color(0xFF000000), const Color(0xFF000000)],
            )),
        child: Text(
          message.body,
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'OverpassRegular',
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
