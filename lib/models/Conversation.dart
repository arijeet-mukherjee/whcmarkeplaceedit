import 'dart:convert';

import 'Message.dart';
import 'User.dart';

List<Conversation> conversationFromJson(String str) => List<Conversation>.from(
    json.decode(str).map((x) => Conversation.fromJson(x)));

String conversationToJson(List<Conversation> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Conversation {
  Conversation({
    this.id,
    this.user,
    this.secondUserId,
    this.createdAt,
    this.messages,
  });

  int id;
  int secondUserId;
  User user;
  DateTime createdAt;
  List<Message> messages;

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json["id"],
        secondUserId: json["secondUserId"],
        user: User.fromJson(json["user"]),
        createdAt: DateTime.parse(json["created_at"]),
        messages: List<Message>.from(
            json["messages"].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "secondUserId": secondUserId,
        "created_at": createdAt.toIso8601String(),
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
      };
}
