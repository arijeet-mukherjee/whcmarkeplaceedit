import 'package:answer_me/models/Message.dart';
import 'package:flutter/material.dart';

class MyMessageCard extends StatelessWidget {
  final Message message;
  const MyMessageCard({
    Key key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 6, bottom: 6, left: 0, right: 5),
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(left: 20),
        padding: EdgeInsets.only(top: 13, bottom: 13, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(23),
              topRight: Radius.circular(23),
              bottomLeft: Radius.circular(23)),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8)
            ],
          ),
        ),
        child: Text(
          message.body,
          textAlign: TextAlign.start,
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'OverpassRegular',
              fontWeight: FontWeight.w300),
        ),
      ),
    );
  }
}
