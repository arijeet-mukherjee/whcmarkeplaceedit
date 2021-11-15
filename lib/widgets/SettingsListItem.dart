import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SettingsListItem extends StatelessWidget {
  final String text;
  final bool arrow;
  final bool first;
  final Color color;
  final Function onTap;

  const SettingsListItem({
    Key key,
    this.text,
    this.arrow,
    this.color,
    this.first = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider _theme = Provider.of<ThemeProvider>(context, listen: false);
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !first
              ? Divider(
                  thickness: 1,
                  color: Theme.of(context).dividerColor,
                  height: 0,
                )
              : Container(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              
              children: [
                Text(
                  text,
                  style: GoogleFonts.lato(
                    fontSize: SizeConfig.safeBlockHorizontal * 4,
                    fontWeight: FontWeight.normal,
                    color: color != null
                        ? color
                        : _theme.isDarkTheme()
                            ? Colors.white70
                            : Colors.black87,
                  ),
                ),
                arrow
                    ? Icon(
                        Icons.chevron_right,
                        
                        size: SizeConfig.blockSizeHorizontal * 5,
                        color: color != null
                            ? color
                            : _theme.isDarkTheme()
                                ? Colors.white70
                                : Colors.black87,
                      )
                    : Container()
              ],
            ),
          ),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
        ],
      ),
    );
  }
}
