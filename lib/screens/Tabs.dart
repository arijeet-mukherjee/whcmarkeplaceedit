import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ConversationProvider.dart';
import 'package:answer_me/screens/other/ChatScreen.dart';
import 'package:answer_me/screens/other/ConversationScreen.dart';
import 'package:answer_me/screens/other/ConversationsScreenBnav.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/SizeConfig.dart';
import '../providers/ThemeProvider.dart';
import '../screens/tabs/Categories.dart';
import 'tabs/Bookmark.dart';
import '../screens/tabs/HomeScreen.dart';
import '../screens/tabs/Search.dart';
import '../screens/tabs/Settings.dart';

class TabsScreen extends StatefulWidget {
  static String routeName = "/tabs_screen";

  static void setPageIndex(BuildContext context, int index) {
    _TabsScreenState state =
        context.findAncestorStateOfType<_TabsScreenState>();
    state._selectPage(index);
  }

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    ConversationProvider _convProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    _convProvider.getConversations(context);
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _pages = [
      {'page': HomeScreen()},
      {'page': ConversationsScreenBnav()},
      //{'page': SearchScreen()},
      {'page': BookmarkScreen()},
      {'page': SettingsScreen()},
    ];
    return Scaffold(
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  _body(BuildContext context) {
    return Stack(
      children: <Widget>[
        _pages[_selectedPageIndex]['page'],
      ],
    );
  }

  _bottomNavigationBar(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return BottomNavigationBar(
      onTap: _selectPage,
      elevation: 4,
      iconSize: SizeConfig.blockSizeHorizontal * 7,
      backgroundColor: Theme.of(context).cardColor,
      currentIndex: _selectedPageIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      unselectedItemColor:
          theme.isDarkTheme() ? Colors.white70 : Colors.black54,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontSize: SizeConfig.safeBlockHorizontal * 3.4,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: SizeConfig.safeBlockHorizontal * 3.4,
      ),
      selectedItemColor: theme.isDarkTheme()?Colors.white:Color(0xFF440000),
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.home_16_regular),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.home_16_filled),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Stack(children:[
              Icon(FluentIcons.chat_16_regular),
              Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.user != null)
                  return Positioned.fill(
                    child: auth.user.notifications != 0 &&
                            auth.user.notifications != null
                        ? Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20, left: 10),
                              child: CircleAvatar(
                                maxRadius: SizeConfig.blockSizeHorizontal * 1.2,
                                backgroundColor: theme.isDarkTheme()
                                                 ?Colors.white:Color(0xFF480000)
                              ),
                            ),
                          )
                        : Container(),
                  );
                else
                  return Container();
              },
            ),
              ]
              ),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.chat_16_filled),
          ),
          label: 'Chats',
        ),
        /* BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.search_20_regular),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.search_20_filled),
          ),
          label: 'Search',
        ), */
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.bookmark_16_regular),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.bookmark_16_filled),
          ),
          label: 'Bookmark',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.settings_16_regular),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.settings_16_filled),
          ),
          label: 'Settings',
        ),
        
      ],
    );
  }
}
