import 'package:flutter/material.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/question.dart';

class QuestionPollListItem extends StatelessWidget {
  final Question question;
  final int index;
  final bool selected;
  final Function onOptionSelected;

  const QuestionPollListItem(
      {Key key,
      this.question,
      this.index,
      this.selected,
      this.onOptionSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.blockSizeVertical * 6,
      child: CheckboxListTile(
        value: selected,
        checkColor: Colors.white,
        activeColor: Theme.of(context).primaryColor,
        onChanged: (value) => onOptionSelected(question.options[index].id),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          question.options[index].option,
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.3,
          ),
        ),
      ),
    );
  }
}
