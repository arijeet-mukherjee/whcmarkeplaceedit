import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/User.dart';
import 'package:answer_me/screens/other/AskQuestion.dart';
import 'package:answer_me/screens/other/UserProfile.dart';
import 'package:answer_me/widgets/RoundedCornersButton.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class UserFollowTile extends StatelessWidget {
  final User user;

  const UserFollowTile({Key key, this.user}) : super(key: key);

  _askAQuestion(BuildContext context) {
    showCupertinoModalBottomSheet(
      context: context,
      elevation: 0,
      topRadius: Radius.circular(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (context) => AskQuestionScreen(
        askAuthor: true,
        authorId: user.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildUserImage(context),
            SizedBox(width: SizeConfig.blockSizeHorizontal * 4.5),
            _buildUserName(context),
            Spacer(),
            _buildFollowButton(context),
          ],
        ),
        Divider(
          thickness: 1,
          color: Colors.grey.shade200,
          indent: SizeConfig.blockSizeHorizontal * 20,
        ),
      ],
    );
  }

  _buildUserImage(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => UserProfile(authorId: user.id)),
      ),
      child: user.avatar == null
          ? CircleAvatar(
              backgroundImage: AssetImage('assets/images/user_icon.png'),
              maxRadius: SizeConfig.blockSizeHorizontal * 8,
            )
          : CircleAvatar(
              backgroundImage: NetworkImage(user.avatar),
              maxRadius: SizeConfig.blockSizeHorizontal * 8,
            ),
    );
  }

  _buildUserName(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => UserProfile(authorId: user.id)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            user.displayname,
            style: TextStyle(
              color: Colors.black,
              fontSize: SizeConfig.safeBlockHorizontal * 4.3,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  _buildFollowButton(BuildContext context) {
    return Container(
      width: SizeConfig.blockSizeHorizontal * 18,
      height: SizeConfig.blockSizeVertical * 4.5,
      child: RoundedCornersButton(
        text: 'Ask',
        onPressed: () => _askAQuestion(context),
      ),
    );
  }
}
