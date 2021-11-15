import 'dart:io';

import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ConversationProvider.dart';
import 'package:answer_me/screens/other/ChatScreen.dart';
import 'package:answer_me/screens/other/ConversationScreen.dart';
import 'package:answer_me/screens/other/ConversationsScreenBnav.dart';
import 'package:answer_me/screens/tabs/Crud.dart';
import 'package:answer_me/screens/tabs/HomeScreen.dart';
import 'package:answer_me/screens/tabs/MarketPlaceHome.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/SizeConfig.dart';
import '../providers/ThemeProvider.dart';
import '../screens/tabs/Categories.dart';
import 'tabs/Bookmark.dart';

import '../screens/tabs/Search.dart';
import '../screens/tabs/Settings.dart';

class HomeMarketplaceScreen extends StatefulWidget {
  static String routeName = "/home_marketplace_screen";

  static void setPageIndex(BuildContext context, int index) {
    _HomeMarketplaceScreenState state =
        context.findAncestorStateOfType<_HomeMarketplaceScreenState>();
    state._selectPage(index);
  }

  @override
  _HomeMarketplaceScreenState createState() => _HomeMarketplaceScreenState();
}

class _HomeMarketplaceScreenState extends State<HomeMarketplaceScreen> {
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
      {'page': CrudHomeScreen()},
      {'page': MarketplaceHomeScreen()},
      //{'page': ConversationsScreenBnav()},
      //{'page': SearchScreen()},
      //{'page': BookmarkScreen()},
      {'page': SettingsScreen()},
    ];
    return WillPopScope(
       onWillPop: _onWillPop,
      child: Scaffold(
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    )
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
      selectedItemColor: theme.isDarkTheme() ? Colors.white : kPrimaryColor,
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
            child: Icon(FluentIcons.drafts_16_regular),
          ),
          activeIcon: Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Icon(FluentIcons.drafts_16_filled),
          ),
          label: 'TodoList',
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

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

}
