import 'dart:io';
import 'dart:math';

import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/ShopProduct.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/AddShopProduct.dart';
import 'package:answer_me/screens/other/UnderDevelopment.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/EmptyScreenText.dart';
import 'package:answer_me/widgets/FeaturedImagePicker.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

class BuildCategoryCircleCard extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final String price;
  final String category;
  const BuildCategoryCircleCard(
      {Key key, this.onTap, this.icon, this.label, this.price,this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.0),
      child: Container(
        width: 75.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Card(
              elevation: 6.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Container(
                width: 50.0,
                height: 45.0,
                padding: EdgeInsets.all(10.0),
                child: Center(
                    child: Icon(
                  icon,
                )),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1.copyWith(),
            ),
            /* SizedBox(height: 8.0),
            Text(
              category,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2.copyWith(),
            ), */
            SizedBox(height: 8.0),
            Text(
              price,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2.copyWith(),
            ),
          ],
        ),
      ),
    );
  }
}
