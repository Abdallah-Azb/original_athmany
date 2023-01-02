import 'models.dart';

class Item {
  String uniqueId;
  String itemGroup;
  String uom;
  String stockUom;
  String itemCode;
  String itemName;
  String descriptionSection;
  double rate;
  double netRate;
  String costCenter;
  int invoiceId;
  int qty;
  List<ItemOption> itemOptionsWith;
  List<ItemOption> itemOptionsWithout;
  String itemOptions;
  int isSup;
  bool showOptions;

  Item(
      {this.uniqueId,
      this.itemGroup,
      this.itemCode,
      this.itemName,
      this.rate, this.netRate,
      this.costCenter,
      this.qty,
      this.invoiceId,
      this.itemOptionsWith,
      this.itemOptionsWithout,
      this.itemOptions,
      this.isSup,
      this.showOptions = true
      });

  // create invoice item
  Item createItem(ItemOfGroup itemOfGroup,
      {List<ItemOption> itemOptionsWith,
      List<ItemOption> itemOptionsWithout,
      int qty}) {
    Item item = Item();
    item.uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    item.itemGroup = itemOfGroup.itemGroup;
    item.uom = itemOfGroup.stockUom;
    item.stockUom = itemOfGroup.stockUom;
    item.itemCode = itemOfGroup.itemCode;
    item.itemName = itemOfGroup.itemName;
    item.descriptionSection = itemOfGroup.description;
    item.rate = itemOfGroup.priceListRate;
    item.costCenter = itemOfGroup.defaultCostCenter;
    item.qty = qty == null ? 1 : qty;
    item.itemOptionsWith = itemOptionsWith;
    item.itemOptionsWithout = itemOptionsWithout;
    return item;
  }

  // item to  map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'unique_id': this.uniqueId,
      'item_group': this.itemGroup,
      'uom': this.uom,
      'stock_uom': this.stockUom,
      'item_code': this.itemCode,
      'item_name': this.itemName,
      'description_section': this.descriptionSection,
      'rate': this.rate,
      'cost_center': this.costCenter,
      'qty': this.qty,
      'FK_item_invoice_id': this.invoiceId
    };
    return map;
  }

  // map
  Map<String, dynamic> fromServer({dynamic item, int invoiceId}) {
    Map<String, dynamic> map = <String, dynamic>{
      'unique_id': item['unique_id'],
      'uom': item['uom'],
      'item_group': item['item_group'],
      'stock_uom': item['stock_uom'],
      'item_code': item['item_code'],
      'item_name': item['item_name'],
      'description_section': item['description'],
      'rate': item['rate'],
      'cost_center': item['cost_center'],
      'qty': item['qty'],
      'FK_item_invoice_id': invoiceId
    };
    return map;
  }

  Item.fromSqlite(Map<String, dynamic> json) {
    this.uniqueId = json['unique_id'].toString();
    this.itemGroup = json['item_group'].toString();
    this.uom = json['uom'].toString();
    this.stockUom = json['stock_uom'].toString();
    this.itemCode = json['item_code'].toString();
    this.itemName = json['item_name'].toString();
    this.descriptionSection = json['description_section'].toString();
    this.rate = json['rate'];
    this.costCenter = json['cost_center'];
    this.qty = json['qty'];
    this.showOptions = true;
  }

  // item to invoice map
  Map<String, dynamic> toInvoiceMap(ProfileDetails posProfileDetails) {
    Map<String, dynamic> map = <String, dynamic>{
      'unique_id': this.uniqueId,
      'uom': this.stockUom,
      'item_group': this.itemGroup,
      'stock_uom': this.stockUom,
      'item_code': this.itemCode,
      'item_name': this.itemName,
      'conversion_factor': 1,
      'description_section': this.descriptionSection,
      'qty': this.qty,
      'rate': this.rate,
      'warehouse': posProfileDetails.warehouse,
      'income_account': posProfileDetails.incomeAccount,
      'cost_center': this.costCenter,
      'is_sup': this.isSup == null ? 0 : this.isSup,
      "item_options": this.itemOptions
    };
    return map;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Item &&
        other.itemGroup == itemGroup &&
        other.uom == uom &&
        other.stockUom == stockUom &&
        other.itemCode == itemCode &&
        other.itemName == itemName &&
        other.descriptionSection == descriptionSection &&
        other.rate == rate &&
        other.costCenter == costCenter &&
        other.invoiceId == invoiceId &&
        other.qty == qty;
  }

  @override
  int get hashCode {
    return itemGroup.hashCode ^
        uom.hashCode ^
        stockUom.hashCode ^
        itemCode.hashCode ^
        itemName.hashCode ^
        descriptionSection.hashCode ^
        rate.hashCode ^
        costCenter.hashCode ^
        invoiceId.hashCode ^
        qty.hashCode;
  }
}
