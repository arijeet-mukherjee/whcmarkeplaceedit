class QTag {
  int id;
  String name;
  String description;
  int parent;
  int status;
  String createdAt;
  String updatedAt;

  QTag(
      {this.id,
      this.name,
      this.description,
      this.parent,
      this.status,
      this.createdAt,
      this.updatedAt});

  factory QTag.fromJson(Map<String, dynamic> json) {
    return QTag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      parent: json['parent'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['parent'] = this.parent;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
