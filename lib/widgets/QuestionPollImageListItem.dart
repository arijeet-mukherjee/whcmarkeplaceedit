import 'package:flutter/material.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/services/ApiRepository.dart';

class QuestionPollImageListItem extends StatelessWidget {
  final Question question;
  final int index;
  final bool selected;
  final Function onOptionSelected;

  const QuestionPollImageListItem(
      {Key key,
      this.question,
      this.index,
      this.selected,
      this.onOptionSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.blockSizeHorizontal * 60,
      margin: EdgeInsets.only(
          right: SizeConfig.blockSizeHorizontal * 5,
          top: SizeConfig.blockSizeVertical * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: [
          Image.network(
            '${ApiRepository.OPTION_IMAGES_PATH}${question.options[index].image}',
            height: SizeConfig.blockSizeVertical * 18,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          CheckboxListTile(
            value: selected,
            dense: true,
            checkColor: Colors.white,
            activeColor: Theme.of(context).primaryColor,
            contentPadding: EdgeInsets.all(0),
            onChanged: (value) => onOptionSelected(question.options[index].id),
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              question.options[index].option,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: SizeConfig.safeBlockHorizontal * 4),
            ),
          ),
        ],
      ),
    );
  }
}
