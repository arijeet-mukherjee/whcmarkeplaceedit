import 'package:path/path.dart' as p;
class Products {
  String image;
  String category;
  String name;
  int price;
  Products({this.image, this.category, this.name, this.price});
  factory Products.fromJson(Map<dynamic, dynamic> json) {
    return Products(
        image: json['image'],
        category: json['category'],
        name: json['name'],
        price: json['price']);
  }
  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['image'] = this.image;
    data['category'] = this.category;
    data['name'] = this.name;
    data['price'] = this.price;
    return data;
  }
}
