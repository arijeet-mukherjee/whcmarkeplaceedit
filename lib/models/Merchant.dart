import 'package:answer_me/models/Product.dart';
import 'package:answer_me/models/ShopProduct.dart';

class Merchant {
  String mid;
  String shopname;
  String shopimage;
  String ownername;
  String address;
  String pincode;
  String servicetype;
  String paid;
  String paymentid;
  Map<dynamic,dynamic> products;
  Merchant(
      {this.mid,
      this.shopname,
      this.shopimage,
      this.ownername,
      this.address,
      this.pincode,
      this.servicetype,
      this.paid,
      this.paymentid,
      this.products});
  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
    data['mid'] = this.mid;
    data['shopname'] = this.shopname;
    data['shopimage'] = this.shopimage;
    data['ownername'] = this.ownername;
    data['address'] = this.address;
    data['pincode'] = this.pincode;
    data['servicetype'] = this.servicetype;
    data['paid'] = this.paid;
    data['paymentid'] = this.paymentid;
    data['products'] = this.products;
    return data;
  }

  factory Merchant.fromJson(Map<dynamic, dynamic> json) {
    return Merchant(
        mid: json['mid'],
        shopname: json['shopname'],
        shopimage: json['shopimage'],
        ownername: json['ownername'],
        address: json['address'],
        pincode: json['pincode'],
        servicetype: json['servicetype'],
        //products: json['products'],
        paymentid: json['paymentid'],
        paid: json['paid']);
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

   static Merchant fromMap(Map value) {
    if (value == null) {
      return null;
    }

    return Merchant(
      mid: value['id'],
      shopname: value['shopname'],
      shopimage: value['shopimage'],
        ownername: value['ownername'],
        address: value['address'],
        pincode: value['pincode'],
        servicetype: value['servicetype'],
        //products: value['products'],
        paymentid: value['paymentid'],
        paid: value['paid']);
    
  }
}
