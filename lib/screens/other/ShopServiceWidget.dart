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
import 'package:answer_me/widgets/BuildCircularCard.dart';
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

class CategorySection extends StatelessWidget {
  
  final String service;
  final List<ShopProduct> shopProduct;
  

      IconData imageUri(String n) {
      if (n == "Health Service") {
        return EvaIcons.heart;
      }
      if (n == "Home Service") {
        return EvaIcons.home;
      }
      
      return EvaIcons.questionMark;
    }


  const CategorySection({
    Key key,
    
    this.service,
    this.shopProduct
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    

    /* return Container(
      width: Screens.width(context),
      height: 90.0,
      margin: EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: LocalList.topCategoryList()
            .map((e) => Expanded(
                  child: _BuildCategoryCircleCard(
                    onTap: () => onTap(e.id!),
                    icon: e.icon!,
                    label: label(e.label!),
                  ),
                ))
            .toList(),
      ),
    ); */
    Future<List<ShopProduct>> _fetchCategory() async {
    //List<ShopProduct> c = [];
      
      return shopProduct;
      // return c;
    
  }
    Container _categoryView(List<ShopProduct> data, context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 102.0,
        margin: EdgeInsets.only(bottom: 15.0),
        child: Row(
          children: data
              .map((e) => Expanded(
                    child: BuildCategoryCircleCard(
                      
                      icon: imageUri(service),
                      label: e.name+'('+e.category+')',
                      price: e.price.toString(),
                    ),
                  ))
              .toList(),
        ),
      );
    }
    Column buildproduct(List<ShopProduct> dataCat, context) {
      return Column(
        children: [
          Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('All Products / Services',),
          
        ],
      ),
      ),
          SizedBox(height: SizeConfig.blockSizeVertical * 1),
          
          Container(
            width: MediaQuery.of(context).size.width,
            height: 250,
            margin: EdgeInsets.only(bottom: 15.0),
            child: ListView.builder(
              itemCount: dataCat.length,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 18.0),
              itemBuilder: (context, index) {
                ShopProduct data = dataCat[index];
                return BuildCategoryCircleCard(
                  
                  icon: imageUri(service),
                  label: data.name ,
                  category: data.category,
                  price: '₹'+' '+data.price.toString(),
                );
              },
            ),
          ),
        ],
      );
    }


    return FutureBuilder<List<ShopProduct>>(
      future: _fetchCategory(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<ShopProduct> data = snapshot.data;

          return buildproduct(data, context);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }
}
