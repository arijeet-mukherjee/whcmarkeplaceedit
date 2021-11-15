import 'package:answer_me/models/Product.dart';
import 'package:answer_me/models/ShopProduct.dart';

class Order {
  String mid;
  String uid;
  String paymentid;
  String address;
  String name;
  int price;
  String paid;
  String date;
  String usernumber;

  Map<dynamic, dynamic> products;
  Order(
      {this.mid,
      this.uid,
      this.name,
      this.price,
      this.address,
      this.paid,
      this.date,
      this.paymentid,
      this.usernumber,
      this.products});
  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['mid'] = this.mid;
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['price'] = this.price;
    data['address'] = this.address;
    data['paymentid'] = this.paymentid;
    data['paid'] = this.paid;
    data['date'] = this.date;
    data['products'] = this.products;
    data['usernumber'] = this.usernumber;
    return data;
  }

  factory Order.fromJson(Map<dynamic, dynamic> json) {
    return Order(
        mid: json['mid'],
        uid: json['uid'],
        name: json['name'],
        price: json['price'],
        address: json['address'],
        paid: json['paid'],
        date: json['date'],
        usernumber: json['usernumber'],
        paymentid: json['paymentid']);
  }

  /* factory Merchant.fromJson(dynamic json) {
    return Merchant(
        mid: json['mid'],
        shopname: json['shopname'],
        shopimage: json['shopimage'],
        ownername: json['ownername'],
        address: json['address'],
        pincode: json['pincode'],
        servicetype: json['servicetype'],
        products: json['products'],
        paymentid: json['paymentid'],
        paid: json['paid']);
  } */

  static Order fromMap(Map value) {
    if (value == null) {
      return null;
    }

    return Order(
        mid: value['mid'],
        uid: value['uid'],
        name: value['name'],
        price: value['price'],
        address: value['address'],
        date: value['date'],
        paid: value['paid'],
        usernumber: value['usernumber'],
        paymentid: value['paymentid']);
  }
}
