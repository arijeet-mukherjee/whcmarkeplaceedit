class Message {
  Message({
    this.id,
    this.body,
    this.read,
    this.userId,
    this.conversationId,
    this.createdAt,
    this.updatedAt,
  });

  int id;
  String body;
  int read;
  int userId;
  int conversationId;
  DateTime createdAt;
  DateTime updatedAt;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"],
        body: json["body"],
        read: json["read"] == 'false' ? 0 : 1,
        userId: json["userId"],
        conversationId: json["conversation_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "body": body,
        "read": read,
        "userId": userId,
        "conversation_id": conversationId,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
