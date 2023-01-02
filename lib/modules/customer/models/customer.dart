import 'dart:convert';

import 'package:app/modules/customer-refactor/models/models.dart';

class CustomersModel {
  List<Customer> customers;

  CustomersModel({this.customers});

  factory CustomersModel.fromMap(Map<String, dynamic> map) {
    return CustomersModel(
      customers:
          List<Customer>.from(map['data']?.map((x) => Customer.fromSqlite(x))),
    );
  }

  factory CustomersModel.fromJson(String source) =>
      CustomersModel.fromMap(json.decode(source));
}
