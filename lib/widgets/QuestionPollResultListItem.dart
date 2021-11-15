import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Option.dart';
import 'package:provider/provider.dart';

class QuestionPollResultListItem extends StatelessWidget {
  final Option option;
  final int count;
  final bool selected;
  final Function onOptionSelected;

  const QuestionPollResultListItem(
      {Key key, this.option, this.count, this.selected, this.onOptionSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical * 0.5,
        horizontal: SizeConfig.blockSizeHorizontal * 4,
      ),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal * 2,
              ),
              child: Text(
                '${option.option} (${option.votes} voters)',
                style: TextStyle(
                  color: theme.isDarkTheme() ? Colors.white70 : Colors.black54,
                  fontSize: SizeConfig.safeBlockHorizontal * 4,
                ),
              ),
            ),
            SizedBox(height: SizeConfig.blockSizeVertical),
            LinearPercentIndicator(
              // width: 140.0,
              lineHeight: 11.0,
              percent: option.votes / count,
              center: Text(
                '${(option.votes / count * 100).toStringAsFixed(2)}%', //"50.0%",
                style: new TextStyle(fontSize: 10.0, color: Colors.white),
              ),
              // trailing: Icon(Icons.mood),
              linearStrokeCap: LinearStrokeCap.roundAll,
              backgroundColor: Colors.grey,
              progressColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
