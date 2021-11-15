import 'package:answer_me/config/SizeConfig.dart';
import 'package:flutter/material.dart';

class RectangularInfoButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final int count;
  final Function onPressed;

  const RectangularInfoButton(
      {Key key, this.icon, this.count, this.text, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 4,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              child: Container(
                height: SizeConfig.blockSizeHorizontal * 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          size: SizeConfig.blockSizeHorizontal * 4,
                          color: Colors.black,
                        ),
                        SizedBox(width: SizeConfig.blockSizeHorizontal),
                        Text(
                          count.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                          ),
                        )
                      ],
                    ),
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                      ),
                    )
                  ],
                ),
              ),
              onTap: () => onPressed(),
            ),
          ],
        ),
      ),
    );
  }
}
