class Registered {
  String mid;

  String number;
  Registered({this.mid, this.number});
  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['mid'] = this.mid;

    data['number'] = this.number;
    return data;
  }

  factory Registered.fromJson(Map<dynamic, dynamic> json) {
    return Registered(mid: json['mid'], number: json['mobile']);
  }
}
