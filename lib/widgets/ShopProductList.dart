import 'dart:collection';

import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Conversation.dart';
import 'package:answer_me/models/Product.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/other/EditShopProduct.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:toast/toast.dart';

class ShopProductList extends StatelessWidget {
  final Products products;
  final Function onTap;
  final String productKey;
  final String merchantKey;
  final String services;
  final int totProduct;

  const ShopProductList(
      {this.products,
      Key key,
      this.onTap,
      this.productKey,
      this.merchantKey,
      this.services,
      this.totProduct})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider _theme = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      decoration: new BoxDecoration(color: Theme.of(context).cardColor),
      child: ListTile(
        //onTap: onTap,
        //backcolor: Theme.of(context).cardColor,

        leading: ClipOval(
          child: Image.network(
            products.image != null || products.image != ' '
                ? products.image
                : 'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
            width: SizeConfig.blockSizeHorizontal * 12.5,
            height: SizeConfig.blockSizeHorizontal * 12.5,
            fit: BoxFit.cover,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: [
                Text(
                  products.name,
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal * 4.8,
                  ),
                ),
              ],
            ),

            /* Icon(
                EvaIcons.edit,
                color:
                    _theme.isDarkTheme() ? Colors.white70 : Color(0xFF480000),
                //size: SizeConfig.blockSizeHorizontal * 5.6,
              ), */
            Column(
              children: [
                IconButton(
                  icon: Icon(EvaIcons.edit),
                  color:
                      _theme.isDarkTheme() ? Colors.white70 : Color(0xFF480000),
                  onPressed: () {
                    showCupertinoModalBottomSheet(
                      context: context,
                      elevation: 0,
                      topRadius: Radius.circular(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      builder: (context) => EditShopProductScreen(
                        product: products,
                        keyP: productKey,
                        service: services,
                        merchantKey: merchantKey,
                      ),
                    );
                  },
                  //size: SizeConfig.blockSizeHorizontal * 5.6,
                ),
                IconButton(
                  icon: Icon(EvaIcons.trash2Outline),
                  color:
                      _theme.isDarkTheme() ? Colors.white70 : Color(0xFF480000),
                  onPressed: () {
                    int c = 0;
                    final databaseRef = FirebaseDatabase.instance.reference();
                    int x = totProduct - 1;
                    if (x.toString() != productKey) {
                      //int x = int.parse(productKey) - 1;
                      print('delete at' + productKey);
                      Toast.show(
                          'Product cannot be Remove! Start deleting from top',
                          context);
                      return;
                    }

                    if (totProduct > 1) {
                      databaseRef
                          .child('/merchant/' +
                              merchantKey +
                              '/' +
                              'products/' +
                              productKey)
                          .remove();
                      Toast.show('Product Removed!', context);
                    } else {
                      Toast.show('You must have one product in store', context);
                    }
                  },
                  //size: SizeConfig.blockSizeHorizontal * 5.6,
                ),
              ],
            ),
          ],
        ),
        subtitle: Text(
          '₹' + products.price.toString(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4.8),
        ),
      ),
    );
  }
}
