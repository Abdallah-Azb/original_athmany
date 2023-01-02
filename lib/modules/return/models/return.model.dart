import 'dart:convert';

import 'package:app/models/sales.taxes.details.dart';

class ReturnInvoice {
  String name;
  String invoiceReference;
  List<ReturnItem> returnItems;
  List<SalesTaxesDetails> salestaxesDetails;

  ReturnInvoice.fromServer(Map<String, dynamic> json) {
    this.name = json['return_against'].toString();
    List itemsList = json['items'];
    List mainItems = itemsList.where((e) => e['is_sup'] == 0).toList();
    this.returnItems = mainItems.map((e) => ReturnItem.fromServer(e)).toList();
    List taxes = json['taxes'];
    this.salestaxesDetails =
        taxes.map((e) => SalesTaxesDetails.fromServer(e)).toList();
  }
}

class ReturnItem {
  String itemName;
  int qty;
  int returnQty;
  bool returnAll;
  double rate;
  List<ReturnItemOption> returnItemOptions = [];

  ReturnItem.fromServer(Map<String, dynamic> json) {
    this.itemName = json['item_name'];
    this.qty = json['qty'].round();
    this.returnQty = 0;
    this.returnAll = false;
    this.rate = json['rate'];
    List itemOptionsList = jsonDecode(json['item_options'].toString());
    if (itemOptionsList != null && itemOptionsList.length > 0) {
      this.returnItemOptions =
          itemOptionsList.map((e) => ReturnItemOption.fromServer(e)).toList();
    }
  }
}

class ReturnItemOption {
  int optionWith;
  String itemName;
  double priceListRate;

  ReturnItemOption.fromServer(Map<String, dynamic> json) {
    this.optionWith = json['option_with'];
    this.itemName = json['item_name'];
    this.priceListRate = json['price_list_rate'];
  }
}
