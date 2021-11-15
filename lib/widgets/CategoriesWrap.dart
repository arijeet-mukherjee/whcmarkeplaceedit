import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Category.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesWrap extends StatelessWidget {
  final List<Category> categories;
  final Function onTap;

  CategoriesWrap({this.categories, this.onTap});

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Wrap(
      children: categories
          .map(
            (category) => InkWell(
              onTap: () => onTap(category.name),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 1.5,
                  vertical: SizeConfig.blockSizeVertical,
                ),
                margin: EdgeInsets.only(
                  right: SizeConfig.blockSizeHorizontal * 1,
                  bottom: SizeConfig.blockSizeVertical * 0.5,
                ),
                height: SizeConfig.blockSizeVertical * 4,
                child: Text(
                  '${category.name}',
                  style: TextStyle(
                    color:
                        theme.isDarkTheme() ? Colors.white60 : Colors.black54,
                    fontSize: SizeConfig.safeBlockHorizontal * 3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(3)),
              ),
            ),
          )
          .toList()
          .cast<Widget>(),
    );
  }
}
