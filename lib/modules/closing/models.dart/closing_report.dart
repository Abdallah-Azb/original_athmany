// To parse this JSON data, do
//
//     final closingReport = closingReportFromJson(jsonString);

import 'dart:convert';

ClosingReport closingReportFromJson(String str) =>
    ClosingReport.fromJson(json.decode(str));

String closingReportToJson(ClosingReport data) => json.encode(data.toJson());

class ClosingReport {
  ClosingReport({
    this.item,
    this.itemGroup,
  });

  List<StockItem> item;
  List<ItemGroup> itemGroup;

  factory ClosingReport.fromJson(Map<String, dynamic> json) => ClosingReport(
        item: List<StockItem>.from(
            json["item"].map((x) => StockItem.fromJson(x))),
        itemGroup: List<ItemGroup>.from(
            json["item_group"].map((x) => ItemGroup.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "item": List<dynamic>.from(item.map((x) => x.toJson())),
        "item_group": List<dynamic>.from(itemGroup.map((x) => x.toJson())),
      };
}

class StockItem {
  StockItem({
    this.itemCode,
    this.itemName,
    this.qty,
    this.totalAmount,
  });

  String itemCode;
  String itemName;
  double qty;
  double totalAmount;

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
        itemCode: json["item_code"],
        itemName: json["item_name"],
        qty: json["qty"],
        totalAmount: json["total_amount"],
      );

  Map<String, dynamic> toJson() => {
        "item_code": itemCode,
        "item_name": itemName,
        "qty": qty,
        "total_amount": totalAmount,
      };
}

class ItemGroup {
  ItemGroup({
    this.itemGroup,
    this.qty,
    this.totalAmount,
  });

  String itemGroup;
  double qty;
  double totalAmount;

  factory ItemGroup.fromJson(Map<String, dynamic> json) => ItemGroup(
        itemGroup: json["item_group"],
        qty: json["qty"],
        totalAmount: json["total_amount"],
      );

  Map<String, dynamic> toJson() => {
        "item_group": itemGroup,
        "qty": qty,
        "total_amount": totalAmount,
      };
}
