import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppBarLeadingButton extends StatelessWidget {
  final Color color;

  const AppBarLeadingButton({Key key, this.color = Colors.black})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return IconButton(
      icon: Icon(Icons.chevron_left,
          color: theme.isDarkTheme() ? Colors.white : color, size: 33),
      onPressed: () => Navigator.pop(context),
    );
  }
}
