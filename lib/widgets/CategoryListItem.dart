import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:answer_me/models/Category.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/screens/other/CategoryQuestions.dart';
import 'package:flutter/material.dart';
import 'package:answer_me/services/ApiRepository.dart';

class CategoriesListItem extends StatefulWidget {
  final Category category;
  final Function getCategories;

  const CategoriesListItem({Key key, this.category, this.getCategories})
      : super(key: key);

  @override
  _CategoriesListItemState createState() => _CategoriesListItemState();
}

class _CategoriesListItemState extends State<CategoriesListItem> {
  AuthProvider auth;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    auth = Provider.of<AuthProvider>(context, listen: false);

    if (auth.user != null)
      isFollowing = widget.category.followers.any(
        (follower) => follower.userId == auth.user.id,
      );
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => CategoryQuestionsScreen(category: widget.category),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 2,
              vertical: SizeConfig.blockSizeVertical,
            ),
            padding: EdgeInsets.only(
              left: SizeConfig.blockSizeHorizontal * 3,
              top: SizeConfig.blockSizeVertical,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.name,
                        style: TextStyle(
                          color: theme.isDarkTheme()
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      SizedBox(height: SizeConfig.blockSizeVertical * 1.4),
                      Text(
                        '${widget.category.followers.length.toString()} Followers',
                        style: TextStyle(
                          fontSize: SizeConfig.safeBlockHorizontal * 3.6,
                          color: theme.isDarkTheme()
                              ? Colors.white60
                              : Colors.black54,
                        ),
                      ),
                      SizedBox(height: SizeConfig.blockSizeVertical),
                    ],
                  ),
                ),
                Consumer<AuthProvider>(builder: (context, auth, _) {
                  if (auth.user == null || auth.user.username == null) {
                    return Container();
                  } else {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: SizeConfig.blockSizeHorizontal * 5,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal * 20,
                            height: SizeConfig.blockSizeVertical * 4.5,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: !isFollowing
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                shape: !isFollowing
                                    ? RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2),
                                      )
                                    : RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          color: Colors.blueGrey,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                padding: EdgeInsets.symmetric(horizontal: 0),
                              ),
                              onPressed: () async {
                                isFollowing = !isFollowing;
                                await ApiRepository.followCategory(
                                  context,
                                  auth.user.id,
                                  widget.category.id,
                                );

                                await Provider.of<AppProvider>(context,
                                        listen: false)
                                    .getCategories();
                              },
                              child: !isFollowing
                                  ? Text(
                                      'Follow',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    )
                                  : Text(
                                      'Unfollow',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
          Divider(height: 0, thickness: 0.6),
        ],
      ),
    );
  }

  Widget overlappedUserImages() {
    final overlap = 15.0;

    List<Widget> items = [];
    widget.category.followers.forEach((follower) {
      items.add(_userIconCircleAvatar());
    });

    List<Widget> stackLayers = List<Widget>.generate(items.length, (index) {
      return Padding(
        padding: EdgeInsets.fromLTRB(index.toDouble() * overlap, 0, 0, 0),
        child: items[index],
      );
    });

    return widget.category.followers.length != 0
        ? Row(
            children: [
              Stack(children: stackLayers),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
            ],
          )
        : Row();
  }

  Widget _userIconCircleAvatar() {
    return CircleAvatar(
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/user_icon.png'),
        backgroundColor: Colors.white,
        maxRadius: SizeConfig.blockSizeHorizontal * 4,
      ),
      maxRadius: SizeConfig.blockSizeHorizontal * 4.5,
      backgroundColor: Colors.white,
    );
  }
}
