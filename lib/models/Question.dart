import 'package:answer_me/models/Comment.dart';
import 'package:answer_me/models/QuestionTag.dart';

import 'Category.dart';
import 'Option.dart';
import 'User.dart';

class Question {
  int id;
  String username;
  String email;
  String type;
  int status;
  String title;
  String titlePlain;
  String content;
  String featuredImage;
  String videoURL;
  int categoryId;
  int authorId;
  int asking;
  int attachmentId;
  int views;
  int votes;
  int bestAnswer;
  int answersCount;
  int userOptionsCount;
  String commentStatus;
  String share;
  int anonymous;
  int bookmark;
  int polled;
  int imagePolled;
  String pollTitle;
  int customFieldId;
  String createdAt;
  String updatedAt;
  Category category;
  List<QuestionTag> tags;
  User author;
  List<Option> options;
  List<Comment> answers;
  // Null attachments;
  // CustomField customFields;

  Question({
    this.id,
    this.username,
    this.email,
    this.type,
    this.status,
    this.title,
    this.titlePlain,
    this.content,
    this.featuredImage,
    this.videoURL,
    this.categoryId,
    this.authorId,
    this.asking,
    this.attachmentId,
    this.views,
    this.votes,
    this.bestAnswer,
    this.answersCount,
    this.userOptionsCount,
    this.commentStatus,
    this.share,
    this.anonymous,
    this.bookmark,
    this.polled,
    this.pollTitle,
    this.imagePolled,
    this.customFieldId,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.author,
    this.tags,
    this.options,
    this.answers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      type: json['type'],
      status: json['status'],
      title: json['title'],
      titlePlain: json['titlePlain'],
      content: json['content'],
      featuredImage: json['featuredImage'],
      videoURL: json['videoURL'],
      categoryId: json['category_id'],
      authorId: json['author_id'],
      asking: json['asking'],
      attachmentId: json['attachment_id'],
      views: json['views'],
      votes: json['votes'],
      bestAnswer: json['bestAnswer'],
      answersCount: json['answersCount'],
      userOptionsCount: json['userOptionsCount'],
      commentStatus: json['commentStatus'],
      share: json['share'],
      anonymous: json['isAnonymous'],
      bookmark: json['favorite'],
      polled: json['polled'],
      imagePolled: json['imagePolled'],
      pollTitle: json['pollTitle'],
      customFieldId: json['custom_field_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      author: json['user'] != null ? User.fromJson(json['user']) : null,
      tags: json["tags"] != null
          ? List<QuestionTag>.from(
              json["tags"].map((x) => QuestionTag.fromJson(x)))
          : null,
      options: json["options"] != null
          ? List<Option>.from(json["options"].map((x) => Option.fromJson(x)))
          : null,
      answers: json["answers"] != null
          ? List<Comment>.from(json["answers"].map((x) => Comment.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['status'] = this.status;
    data['title'] = this.title;
    data['titlePlain'] = this.titlePlain;
    data['content'] = this.content;
    data['featuredImage'] = this.featuredImage;
    data['videoURL'] = this.videoURL;
    data['category_id'] = this.categoryId;
    data['author_id'] = this.authorId;
    data['asking'] = this.asking;
    data['attachment_id'] = this.attachmentId;
    data['views'] = this.views;
    data['votes'] = this.votes;
    data['bestAnswer'] = this.bestAnswer;
    data['answersCount'] = this.answersCount;
    data['userOptionsCount'] = this.userOptionsCount;
    data['answers'] = this.answers;
    data['commentStatus'] = this.commentStatus;
    data['share'] = this.share;
    data['isAnonymous'] = this.anonymous;
    data['favorite'] = this.bookmark;
    data['polled'] = this.polled;
    data['pollTitle'] = this.pollTitle;
    data['imagePolled'] = this.imagePolled;
    data['custom_field_id'] = this.customFieldId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
