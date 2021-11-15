import 'package:answer_me/config/AdmobConfig.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:flutter/material.dart';


class EmptyScreenText extends StatelessWidget {
  final String text;
  final IconData icon;

  const EmptyScreenText({Key key, this.text, this.icon}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    /* final BannerAd myBanner = BannerAd(
      adUnitId: AdmobConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: AdListener(),
    ); */
    //myBanner.load();
    return Stack(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.grey.shade300,
                  size: SizeConfig.blockSizeHorizontal * 11,
                ),
                SizedBox(height: SizeConfig.blockSizeVertical),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                  ),
                ),
              ],
            ),
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
