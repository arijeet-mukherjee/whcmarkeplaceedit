import 'package:answer_me/config/SizeConfig.dart';
import 'package:flutter/material.dart';

class RoundedCornersButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool hasPadding;
  final bool loading;
  final bool inverse;

  const RoundedCornersButton({
    Key key,
    this.text,
    this.onPressed,
    this.hasPadding,
    this.loading = false,
    this.inverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: SizeConfig.blockSizeVertical * 6.5,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor:
              inverse ? Theme.of(context).primaryColor : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(width: 1, color: Theme.of(context).primaryColor),
          ),
        ),
        onPressed: () => onPressed(),
        child: loading
            ? SizedBox(
                width: SizeConfig.blockSizeVertical * 3,
                height: SizeConfig.blockSizeVertical * 3,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      inverse ? Colors.white : Theme.of(context).primaryColor,
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                  letterSpacing: 1.6,
                ),
              ),
      ),
    );
  }
}
