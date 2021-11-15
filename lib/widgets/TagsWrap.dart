import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/QuestionTag.dart';
import 'package:answer_me/screens/other/TagQuestions.dart';
import 'package:flutter/material.dart';

class TagsWrap extends StatelessWidget {
  final List<QuestionTag> questionTags;
  final Function onTap;

  TagsWrap({this.questionTags, this.onTap});

  _navigateToTagQuestionsScreen(BuildContext context, QuestionTag tag) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => TagQuestionsScreen(tag: tag)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: questionTags
            .map(
              (tag) => InkWell(
                onTap: () => onTap != null
                    ? onTap(tag.tag)
                    : _navigateToTagQuestionsScreen(context, tag),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal * 2,
                    vertical: SizeConfig.blockSizeVertical,
                  ),
                  margin: EdgeInsets.only(
                    right: SizeConfig.blockSizeHorizontal * 1.2,
                    bottom: SizeConfig.blockSizeVertical,
                  ),
                  height: SizeConfig.blockSizeVertical * 4,
                  child: Text(
                    '${tag.tag}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: SizeConfig.safeBlockHorizontal * 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3)),
                ),
              ),
            )
            .toList()
            .cast<Widget>());
  }
}
