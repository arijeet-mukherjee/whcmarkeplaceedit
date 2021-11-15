import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Notification.dart' as n;
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/EmptyScreenText.dart';
import 'package:answer_me/widgets/NotificationListItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = "notifications_screen";

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  AuthProvider _authProvider;
  bool _isLoading = true;
  List<n.Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getUserNotifications();
  }

  _getUserNotifications() async {
    if (_authProvider.user != null) {
      await ApiRepository.getUserNotifications(
        context,
        userId: _authProvider.user.id,
      ).then((notifications) {
        setState(() {
          _notifications = notifications;
        });
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  _deleteNotification(n.Notification notification) async {
    setState(() {
      _notifications.remove(notification);
    });
    if (_notifications.isEmpty) {
      AuthProvider _authProvider = Provider.of<AuthProvider>(context);
      await _authProvider.clearUserNotifications();
    }
    await _authProvider.getUserInfo(context, _authProvider.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
    );
  }

  _appBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Notifications',
        style: Theme.of(context).textTheme.headline6,
      ),
      leading: AppBarLeadingButton(),
    );
  }

  _body() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _authProvider.user != null
            ? _notifications.isNotEmpty
                ? ListView.builder(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: SizeConfig.blockSizeVertical * 3,
                      bottom: SizeConfig.blockSizeVertical * 3,
                      left: SizeConfig.blockSizeHorizontal * 5,
                      right: SizeConfig.blockSizeHorizontal * 4,
                    ),
                    itemCount: _notifications.length,
                    itemBuilder: (ctx, i) => NotificationListItem(
                      notification: _notifications[i],
                      deleteNotification: _deleteNotification,
                    ),
                  )
                : EmptyScreenText(
                    text: 'No Notifications Found',
                    icon: Icons.notifications_outlined,
                  )
            : EmptyScreenText(
                text: 'Please login to start receiving notifications',
                icon: Icons.notifications_outlined,
              );
  }
}
