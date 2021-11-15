//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/widgets/CategoryListItem.dart';
import 'package:flutter/material.dart';

import '../../config/SizeConfig.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  AppProvider appProvider;
  bool isLoading = true;
  double _bottomPadding = 0;

  

  @override
  void initState() {
    super.initState();
    appProvider = Provider.of<AppProvider>(context, listen: false);
    _getCategories();

    /* myBanner = BannerAd(
      adUnitId: AdmobConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: AdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bottomPadding = 48.0;
          });
        },
      ),
    );
    myBanner.load(); */
  }

  Future _getCategories() async {
    if (appProvider.categories.isEmpty) await appProvider.getCategories();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _buildCategoriesList(),
    );
  }

  _appBar() {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text('Interests', style: theme.isDarkTheme()?Theme.of(context).textTheme.headline6:TextStyle(
              fontFamily: 'Equinox',
              fontSize: SizeConfig.safeBlockHorizontal * 4.8,
              color: Colors.white,
            )),
      backgroundColor: theme.isDarkTheme()?ThemeData.dark().scaffoldBackgroundColor:kPrimaryColor,
    );
  }

  _buildCategoriesList() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: _bottomPadding),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Consumer<AppProvider>(
                  builder: (context, app, _) {
                    if (app.categories.isEmpty) {
                      return Center(child: Text('No Categories Found'));
                    } else {
                      return ListView.builder(
                        itemCount: app.categories.length,
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockSizeVertical,
                        ),
                        itemBuilder: (BuildContext context, int i) =>
                            CategoriesListItem(
                          category: app.categories[i],
                          getCategories: _getCategories,
                        ),
                      );
                    }
                  },
                ),
        ),
        /* Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            height: myBanner.size.height.toDouble(),
            color: Theme.of(context).cardColor,
            alignment: Alignment.center,
            child: AdWidget(ad: myBanner),
            margin: EdgeInsets.only(
              bottom: SizeConfig.blockSizeVertical * 1,
            ),
          ),
        ), */
      ],
    );
  }
}
