// import 'package:admob_flutter/admob_flutter.dart';
import 'package:answer_me/config/AdmobConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Conversation.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/models/User.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ConversationProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/AskQuestion.dart';
import 'package:answer_me/screens/other/ChatScreen.dart';
import 'package:answer_me/screens/other/EditProfile.dart';
import 'package:answer_me/screens/other/FollowingFollowers.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/ExpandableText.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:answer_me/widgets/QuestionListItem.dart';
import 'package:answer_me/widgets/RoundedCornersButton.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class UserProfile extends StatefulWidget {
  final int authorId;

  const UserProfile({Key key, this.authorId}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  ThemeProvider _themeProvider;
  AuthProvider _authProvider;
  bool _isFollowing = false;
  bool isLoading = true;
  bool _isLoading = true;
  List<Question> _questions = [];
  var _scrollViewController = ScrollController();
  var _listViewController = ScrollController();
  ScrollPhysics _scrollViewPhysics;
  ScrollPhysics _listViewPhysics = NeverScrollableScrollPhysics();
  User _author;
  int initPosition = 1;

  /* final BannerAd myBanner = BannerAd(
    adUnitId: AdmobConfig.bannerAdUnitId,
    size: AdSize.banner,
    request: AdRequest(),
    listener: AdListener(),
  ); */

  final List<Tab> _tabs = <Tab>[
    Tab(text: 'QUESTIONS'),
    Tab(text: 'POLLS'),
    Tab(text: 'FAVORITE'),
    Tab(text: 'ASKED'),
    // Tab(text: 'Followed Questions'),
    // Tab(text: 'Posts'),
  ];

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_authProvider.user != null &&
        _authProvider.user.id == widget.authorId) {
      _tabs.add(Tab(text: 'PENDING'));
      _tabController = new TabController(length: 5, vsync: this);
    } else {
      _tabController = new TabController(length: 4, vsync: this);
    }
    _tabController.addListener(onPositionChange);

    _scrollViewController.addListener(() {
      if (_scrollViewController.position.atEdge) {
        if (_scrollViewController.position.pixels == 0) {
          setState(() {
            _scrollViewPhysics = ScrollPhysics();
            _listViewPhysics = NeverScrollableScrollPhysics();
          });
        } else {
          setState(() {
            if (_scrollViewPhysics == NeverScrollableScrollPhysics())
              _scrollViewPhysics = NeverScrollableScrollPhysics();
            _listViewPhysics = ScrollPhysics();
          });
        }
      }
    });

    _listViewController.addListener(() {
      if (_listViewController.position.atEdge) {
        if (_listViewController.position.pixels == 0) {
          setState(() {
            _scrollViewPhysics = ScrollPhysics();
            _listViewPhysics = NeverScrollableScrollPhysics();
          });
        }
      }
    });

    _getUserInfo();
    _checkIfIsFollowing();
    _getQuestions('getUserQuestions');

    //myBanner.load();
  }

  onPositionChange() async {
    setState(() {
      isLoading = true;
    });
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          await _checkIfDataExist('getUserQuestions');
          break;
        case 1:
          await _checkIfDataExist('getUserPollQuestions');
          break;
        case 2:
          await _checkIfDataExist('getUserFavQuestions');
          break;
        case 3:
          await _checkIfDataExist('getUserAskedQuestions');
          break;
        case 4:
          await _checkIfDataExist('getUserWaitingQuestions');
          break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _clearQuestions();
  }

  Future _clearQuestions() async {
    await _authProvider.clearProfileQuestions();
  }

  _getUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    await ApiRepository.getUserInfo(context, userId: widget.authorId)
        .then((author) {
      setState(() {
        _author = author;
      });
    });
  }

  _checkIfIsFollowing() async {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiRepository.checkIfIsFollowing(
      context,
      userId: auth.user != null ? auth.user.id : 0,
      followerId: widget.authorId,
    ).then((isFollowing) {
      setState(() {
        _isFollowing = isFollowing;
      });
    });
  }

  _checkIfDataExist(String endpoint) async {
    switch (endpoint) {
      case 'getUserQuestions':
        if (_authProvider.questions.isNotEmpty) {
          setState(() {
            _questions = _authProvider.questions;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;
      case 'getUserPollQuestions':
        if (_authProvider.polls.isNotEmpty) {
          setState(() {
            _questions = _authProvider.polls;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;
      case 'getUserFavQuestions':
        if (_authProvider.bookmarks.isNotEmpty) {
          setState(() {
            _questions = _authProvider.bookmarks;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;
      case 'getUserAskedQuestions':
        if (_authProvider.asked.isNotEmpty) {
          setState(() {
            _questions = _authProvider.asked;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;

      case 'getUserWaitingQuestions':
        if (_authProvider.waiting.isNotEmpty) {
          setState(() {
            _questions = _authProvider.waiting;
          });
        } else {
          await _getQuestions(endpoint);
        }
        break;
    }

    setState(() {
      isLoading = false;
    });
  }

  _getQuestions(String endpoint) async {
    setState(() {
      isLoading = true;
    });
    await ApiRepository.getProfileQuestions(context, endpoint, widget.authorId)
        .then((questions) async {
      setState(() {
        _questions = questions;
        switch (endpoint) {
          case 'getUserQuestions':
            _authProvider.setQuestions(questions);
            break;
          case 'getUserPollQuestions':
            _authProvider.setPolls(questions);
            break;
          case 'getUserFavQuestions':
            _authProvider.setBookmarks(questions);
            break;
          case 'getUserAskedQuestions':
            _authProvider.setAsked(questions);
            break;
          case 'getUserWaitingQuestions':
            _authProvider.setWaiting(questions);
            break;
        }
      });
    });

    setState(() {
      _isLoading = false;
      isLoading = false;
    });
  }

  _followUser() async {
    AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
    await ApiRepository.followOrUnfollowUser(
      context,
      userId: auth.user.id,
      followerId: _author.id,
    ).then((isFollowing) {
      setState(() {
        _isFollowing = isFollowing;
      });
    });
  }

  _openChatScreen(BuildContext context) {
    ConversationProvider _convProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    if (_convProvider.concersations.isNotEmpty) {
      _convProvider.concersations.forEach((conv) {
        print(conv.toJson());
      });
      if (_convProvider.concersations.any((conv) =>
          conv.secondUserId == _author.id ||
          (conv.secondUserId == _authProvider.user.id &&
              conv.user.id == _author.id))) {
        Conversation exist = _convProvider.concersations.firstWhere((conv) =>
            conv.secondUserId == _author.id ||
            (conv.secondUserId == _authProvider.user.id &&
                conv.user.id == _author.id));
        if (exist.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ChatScreen(
                conversation: Conversation(
                  user: _author,
                  secondUserId: _author.id,
                  createdAt: exist.createdAt,
                  messages: exist.messages,
                  id: exist.id,
                ),
              ),
            ),
          );
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ChatScreen(
              user: _author,
            ),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => ChatScreen(
            user: _author,
          ),
        ),
      );
    }
  }

  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      body: _body(context),
    );
  }

  _body(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            controller: _scrollViewController,
            physics: _scrollViewPhysics,
            child: Column(
              children: [
                Container(
                  height: SizeConfig.screenHeight * 1.88,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCoverAndUserInfo(context),
                      _buildBioText(context),
                      SizedBox(height: SizeConfig.blockSizeVertical * 2),
                      _buildAskButton(),
                      SizedBox(height: SizeConfig.blockSizeVertical),
                      _buildFollowingAndFollowersRow(context),
                      // _buildInfoContainers(context),
                      SizedBox(height: SizeConfig.blockSizeVertical * 3),
                      _tabBar(),
                      _tabBarBody(),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  _tabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: Theme.of(context).textTheme.headline1.color,
      indicatorWeight: 5.0,
      unselectedLabelColor: Theme.of(context).textTheme.headline1.color,
      labelStyle: GoogleFonts.lato(
        fontSize: SizeConfig.safeBlockHorizontal * 3.5,
        fontWeight: FontWeight.w600,
      ),
      tabs: _tabs,
    );
  }

  _tabBarBody() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: _tabs.map((Tab tab) {
          return _authorQuestions();
        }).toList(),
      ),
    );
  }

  Widget _authorQuestions() {
    return isLoading
        ? LoadingShimmerLayout()
        : _questions.isNotEmpty
            ? Container(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                      controller: _listViewController,
                      itemCount: _questions.length,
                      physics: _listViewPhysics,
                      itemBuilder: (ctx, i) {
                        return Column(
                          children: [
                            /* i != 0 && (i == 1 || (i - 1) % 5 == 0)
                                ? Container(
                                    width: double.infinity,
                                    height: myBanner.size.height.toDouble(),
                                    color: Theme.of(context).cardColor,
                                    alignment: Alignment.center,
                                    child: AdWidget(ad: myBanner),
                                    margin: EdgeInsets.only(
                                      bottom: SizeConfig.blockSizeVertical * 1,
                                    ),
                                  )
                                : Container(), */
                            QuestionListItem(question: _questions[i]),
                          ],
                        );
                      }),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No questions found',
                      style: GoogleFonts.lato(
                          color: Colors.black54,
                          fontSize: SizeConfig.safeBlockHorizontal * 3.5),
                    )
                  ],
                ),
              );
  }

  _buildCoverAndUserInfo(BuildContext context) {
    return _author != null && _author.cover != null
        ? Stack(
            children: [
              _buildCoverImage(),
              Padding(
                padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBackButton(context, Colors.white),
                        _authProvider.user.id != _author.id
                            ? _buildMessageButton(context, Colors.white)
                            : Container(),
                      ],
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical * 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAvatarImage(context),
                        _buildUserInformation(context),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        : SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3),
              child: Stack(
                children: [
                  _buildBackButton(context, Colors.black),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAvatarImage(context),
                      _buildUserInformation(context),
                    ],
                  ),
                  _authProvider.user.id != _author.id
                      ? _buildMessageButton(
                          context,
                          _themeProvider.isDarkTheme()
                              ? Colors.white
                              : Colors.black,
                        )
                      : Container(),
                ],
              ),
            ),
          );
  }

  _buildCoverImage() {
    return Stack(
      children: [
        _author.cover == null
            ? Image.asset(
                'assets/images/cover_image.png',
                width: double.infinity,
                height: SizeConfig.blockSizeVertical * 30,
                fit: BoxFit.cover,
              )
            : Image.network(
                '${ApiRepository.COVER_IMAGES_PATH}${_author.cover}',
                width: double.infinity,
                height: SizeConfig.blockSizeVertical * 30,
                fit: BoxFit.fill,
              ),
        Container(
          height: SizeConfig.blockSizeVertical * 30,
          color: Colors.black.withOpacity(0.3),
        ),
      ],
    );
  }

  _buildBackButton(BuildContext context, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
          child: AppBarLeadingButton(color: color),
        ),
      ],
    );
  }

  _buildMessageButton(BuildContext context, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeVertical * 2.5,
            left: SizeConfig.blockSizeHorizontal * 4,
            right: SizeConfig.blockSizeHorizontal * 4,
          ),
          child: IconButton(
            onPressed: () => _openChatScreen(context),
            icon: Icon(
              EvaIcons.messageCircleOutline,
              color: color,
              size: SizeConfig.blockSizeHorizontal * 7,
            ),
          ),
        ),
      ],
    );
  }

  // _buildBackButton(BuildContext context, Color color) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [

  //       IconButton(
  //         onPressed: () => Navigator.pop(context),
  //         icon: Icon(Icons.chevron_left, color: color),
  //       ),
  //     ],
  //   );
  // }

  // _buildEditProfileButton(BuildContext context, Color color) {
  //   return Icon(
  //     FluentIcons.edit_16_filled,
  //     color: Colors.white,
  //     size: SizeConfig.blockSizeHorizontal * 5.5,
  //   );
  // }

  _buildAvatarImage(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 6,
            ),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
            ),
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 0.6),
              child: CircleAvatar(
                maxRadius: SizeConfig.blockSizeHorizontal * 13,
                backgroundColor: Colors.black54,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: _author != null && _author.avatar != null
                      ? Image.network(
                          _author.avatar,
                          width: double.infinity,
                          height: SizeConfig.blockSizeVertical * 30,
                          fit: BoxFit.cover,
                        )
                      : Image.asset('assets/images/user_icon.png'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildUserInformation(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: SizeConfig.blockSizeVertical * 2),
        _buildUserName(context),
        // _buildUserRole(),
      ],
    );
  }

  _buildUserName(BuildContext context) {
    return _author != null && _author.displayname != null
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                _author.displayname,
                style: GoogleFonts.lato(
                  fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        : Container();
  }

  _buildBioText(BuildContext context) {
    return _author != null
        ? Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpandableText(
                  _author.description != null ? _author.description : '',
                  trimLines: 3,
                  style: GoogleFonts.lato(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.6,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )
        : Container();
  }

  _buildAskButton() {
    return _authProvider.user != null && _author != null
        ? Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 6,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: RoundedCornersButton(
                        text: _author.id != _authProvider.user.id
                            ? 'Ask ${_author.displayname}'
                            : 'Edit Profile',
                        onPressed: () {
                          if (_authProvider.user != null &&
                              _authProvider.user.id != null) {
                            _author.id != _authProvider.user.id
                                ? showCupertinoModalBottomSheet(
                                    context: context,
                                    elevation: 0,
                                    topRadius: Radius.circular(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    builder: (context) => AskQuestionScreen(
                                      askAuthor: true,
                                      authorId: _author.id,
                                    ),
                                  )
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfileScreen(),
                                    ),
                                  );
                          } else {
                            Toast.show(
                              'You have to login to ask questions',
                              context,
                              duration: 2,
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
                    _author.id != _authProvider.user.id
                        ? Expanded(
                            flex: 2,
                            child: RoundedCornersButton(
                              text: _isFollowing ? 'Unfollow' : 'Follow',
                              inverse: !_isFollowing,
                              onPressed: () {
                                if (_authProvider.user != null &&
                                    _authProvider.user.id != null) {
                                  _followUser();
                                } else {
                                  Toast.show(
                                    'You have to login to follow users',
                                    context,
                                    duration: 2,
                                  );
                                }
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 3),
            ],
          )
        : Container();
  }

  _buildFollowingAndFollowersRow(BuildContext context) {
    return _author != null
        ? Container(
            padding: EdgeInsets.symmetric(
              vertical: SizeConfig.blockSizeVertical,
            ),
            // margin: EdgeInsets.symmetric(
            //   horizontal: SizeConfig.blockSizeHorizontal * 7,
            // ),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: _themeProvider.isDarkTheme()
                    ? Colors.black38
                    : Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildFollowCount(
                        context,
                        text: 'Following',
                        count: _author.following ?? 0,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => FollowingFollowersScreen(
                              authorId: _author.id,
                              index: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      child: VerticalDivider(
                        width: 0,
                        thickness: 1,
                        color: _themeProvider.isDarkTheme()
                            ? Colors.black38
                            : Colors.grey.shade200,
                      ),
                    ),
                    Expanded(
                      child: _buildFollowCount(
                        context,
                        text: 'Followers',
                        count: _author.followers ?? 0,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => FollowingFollowersScreen(
                              authorId: _author.id,
                              index: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: _themeProvider.isDarkTheme()
                      ? Colors.black38
                      : Colors.grey.shade200,
                  indent: 10,
                  endIndent: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildFollowCount(
                        context,
                        text: 'Questions',
                        count: _author.questions ?? 0,
                        onPressed: () => null,
                      ),
                    ),
                    Container(
                      height: 50,
                      child: VerticalDivider(
                        width: 0,
                        thickness: 1,
                        color: _themeProvider.isDarkTheme()
                            ? Colors.black38
                            : Colors.grey.shade200,
                      ),
                    ),
                    Expanded(
                      child: _buildFollowCount(
                        context,
                        text: 'Points',
                        count: _author.points ?? 0,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => FollowingFollowersScreen(
                                authorId: _author.id, index: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Container();
  }

  _buildFollowCount(BuildContext context,
      {String text, int count, Function onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: GoogleFonts.lato(
                  fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 0.6),
              Text(
                text,
                style: GoogleFonts.lato(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: _themeProvider.isDarkTheme()
                      ? Colors.white
                      : Colors.black54,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget overlappedUserImages(int count) {
    final overlap = 16.0;

    List<Widget> items = [];
    for (int i = 0; i < count; i++) {
      items.add(_userIconCircleAvatar());
    }

    List<Widget> stackLayers = List<Widget>.generate(items.length, (index) {
      return Padding(
        padding: EdgeInsets.fromLTRB(index.toDouble() * overlap, 0, 0, 0),
        child: items[index],
      );
    });

    return Stack(children: stackLayers);
  }

  _userIconCircleAvatar() {
    return CircleAvatar(
      child: CircleAvatar(
        backgroundImage: AssetImage('assets/images/user_icon.png'),
        backgroundColor: Colors.white,
        maxRadius: SizeConfig.blockSizeHorizontal * 4.1,
      ),
      maxRadius: SizeConfig.blockSizeHorizontal * 4.6,
      backgroundColor: Colors.white,
    );
  }
}
