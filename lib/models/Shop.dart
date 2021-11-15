import 'package:answer_me/models/ShopProduct.dart';

class Shop {
  int id;
  String shopName;
  String ownerName;
  String address;
  String pincode;
  String serviceType;
  List<ShopProduct> shopproduct;

  Shop(
      {this.id,
      this.shopName,
      this.ownerName,
      this.address,
      this.pincode,
      this.serviceType,
      this.shopproduct});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['shopname'] = this.shopName;
    data['ownername'] = this.ownerName;
    data['address'] = this.address;
    data['pincode'] = this.pincode;
    data['servicetype'] = this.serviceType;
    data['shopproduct'] = this.shopproduct;
    return data;
  }
}
