import 'package:provider/provider.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/User.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/UserFollowTile.dart';
import 'package:flutter/material.dart';

class FollowingFollowersScreen extends StatefulWidget {
  static const routeName = "following_followers_screen";

  final int authorId;
  final int index;

  const FollowingFollowersScreen({Key key, this.authorId, this.index = 0})
      : super(key: key);

  @override
  _FollowingFollowersScreenState createState() =>
      _FollowingFollowersScreenState();
}

class _FollowingFollowersScreenState extends State<FollowingFollowersScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  AuthProvider authProvider;
  List<User> _following = [];
  List<User> _followers = [];
  bool _isLoading;
  int userId;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);

    _tabController = new TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.index,
    );

    if (widget.authorId != null)
      userId = widget.authorId;
    else if (authProvider.user != null)
      userId = authProvider.user.id;
    else
      userId = 0;

    _isLoading = true;
    _getUserFollowing();
    _getUserFollowers();
  }

  _getUserFollowing() async {
    await ApiRepository.getUserFollowing(context, userId: userId)
        .then((following) {
      setState(() {
        _following = following;
      });
    });
  }

  _getUserFollowers() async {
    await ApiRepository.getUserFollowers(context, userId: userId)
        .then((followers) {
      setState(() {
        _followers = followers;
      });
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: _isLoading
          ? Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : Scaffold(
              appBar: _appBar(),
              body: _body(),
            ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 4,
      title: Text('John Doe', style: Theme.of(context).textTheme.headline6),
      leading: AppBarLeadingButton(),
      centerTitle: true,
      bottom: _tabBar(),
    );
  }

  _tabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Theme.of(context).textTheme.headline1.color,
      indicatorWeight: 5.0,
      unselectedLabelColor: Theme.of(context).textTheme.headline1.color,
      labelStyle: TextStyle(
        fontSize: SizeConfig.safeBlockHorizontal * 4,
        fontWeight: FontWeight.w600,
      ),
      tabs: [
        Tab(
          text: '${_followers.length == 0 ? '' : _followers.length} Followers',
        ),
        Tab(
          text: '${_following.length == 0 ? '' : _following.length} Following',
        ),
      ],
    );
  }

  _body() {
    return TabBarView(
      controller: _tabController,
      children: [
        _usersList(_followers),
        _usersList(_following),
      ],
    );
  }

  _usersList(List<User> users) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical * 3,
        horizontal: SizeConfig.blockSizeHorizontal * 5,
      ),
      itemCount: users.length,
      itemBuilder: (ctx, i) => UserFollowTile(user: users[i]),
    );
  }
}
