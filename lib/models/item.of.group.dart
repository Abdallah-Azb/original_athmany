import 'package:app/models/item.option.dart';

class ItemOfGroup {
  String itemGroup;
  String itemCode;
  String itemName;
  String description;
  String stockUom;
  String itemImage;
  int isStockItem;
  double priceListRate;
  String currency;
  String defaultCostCenter;
  double actualQty;
  String tableName;
  List<ItemOption> itemOptions;

  ItemOfGroup({
    this.itemGroup,
    this.itemCode,
    this.itemName,
    this.description,
    this.stockUom,
    this.itemImage,
    this.isStockItem,
    this.priceListRate,
    this.currency,
    this.defaultCostCenter,
    this.actualQty,
    this.tableName,
    this.itemOptions,
  });

  // from server
  factory ItemOfGroup.fromServer(
      Map<String, dynamic> json, String itemGroup, String writeOffCostCenter) {
    ItemOfGroup itemOfGroup = ItemOfGroup();
    itemOfGroup.itemGroup = itemGroup;
    itemOfGroup.itemCode = json['item_code'];
    itemOfGroup.itemName = json['item_name'];
    itemOfGroup.description = json['description'];
    itemOfGroup.stockUom = json['stock_uom'];
    itemOfGroup.itemImage = json['item_image'];
    itemOfGroup.isStockItem = json['is_stock_item'];
    itemOfGroup.priceListRate = json['price_list_rate'] ?? 0.0;
    itemOfGroup.currency = json['currency'];
    itemOfGroup.defaultCostCenter = json['default_cost_center'] == null
        ? writeOffCostCenter
        : json['default_cost_center'];
    itemOfGroup.actualQty = json['actual_qty'].toDouble();
    /////////////
    List<ItemOption> itemOptions = [];
    List itemOptionsWith = json['item_option_with'];
    for (var e in itemOptionsWith) {
      ItemOption itemOption = ItemOption(
          parent: e['parent'],
          itemCode: e['item_code'],
          itemName: e['item_name'],
          priceListRate: e['price_list_rate'].toDouble(),
          optionWith: 1);
      itemOptions.add(itemOption);
    }
    List itemOptionsWithout = json['item_option_without'];
    for (var e in itemOptionsWithout) {
      ItemOption itemOption = ItemOption(
          parent: e['parent'],
          itemCode: e['item_code'],
          itemName: e['item_name'],
          priceListRate: e['price_list_rate'].toDouble(),
          optionWith: 0);
      itemOptions.add(itemOption);
    }
    itemOfGroup.itemOptions = itemOptions;
    // itemOfGroup.itemOptionsWith = json['item_option_with']
    //     .map((e) => ItemOptionWith.fromSqlite(e)).toList();
    // itemOfGroup.itemOptionsWith = [
    //   ItemOptionWith(itemName: 'itemName', parent: 'adsf')
    // ];
    return itemOfGroup;
  }

  List<ItemOption> itemOptionsExample = [
    ItemOption(itemName: 'items_name', parent: 'adsf')
  ];

  //
  Map<String, dynamic> toSqlite() {
    var map = <String, dynamic>{
      'item_group': this.itemGroup,
      'item_code': this.itemCode,
      'item_name': this.itemName,
      'description': this.description,
      'stock_uom': this.stockUom,
      'item_image': this.itemImage,
      // 'item_image':
      //     this.itemImage == "" ? "" : localPath + "/" + this.itemCode + ".png",
      'is_stock_item': this.isStockItem,
      'price_list_rate': this.priceListRate,
      'currency': this.currency,
      'default_cost_center': this.defaultCostCenter,
      'actual_qty': this.actualQty
    };
    return map;
  }

  //
  ItemOfGroup.fromSqlite(Map<String, dynamic> json) {
    this.itemGroup = json['item_group'].toString();
    this.itemCode = json['item_code'].toString();
    this.itemName = json['item_name'].toString();
    this.description = json['description'].toString();
    this.stockUom = json['stock_uom'].toString();
    this.itemImage = json['item_image'].toString();
    this.isStockItem = json['is_stock_item'];
    this.priceListRate = json['price_list_rate'];
    this.currency = json['currency'].toString();
    this.defaultCostCenter = json['default_cost_center'].toString();
    this.actualQty = json['actual_qty'];
  }
}
