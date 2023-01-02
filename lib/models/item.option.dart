class ItemOption {
  String itemUniqueId;
  String parent;
  String itemCode;
  String itemName;
  double priceListRate;
  bool selected = false;
  int optionWith;
  int invoiceId;

  ItemOption(
      {this.itemUniqueId,
      this.parent,
      this.itemCode,
      this.itemName,
      this.priceListRate,
      this.selected,
      this.optionWith,
      this.invoiceId});

  // from server
  // factory ItemOptionWith.fromServer(Map<String, dynamic> json) {
  //   ItemOptionWith itemOptionWith = ItemOptionWith();
  //   itemOptionWith.parent = json['parent'];
  //   itemOptionWith.itemName = json['name'];
  //   return itemOptionWith;
  // }

  // from server
  ItemOption.fromServer(Map<String, dynamic> json) {
    this.parent = json['parent'];
    this.itemCode = json['item_code'];
    this.itemName = json['item_name'];
    this.priceListRate = json['item_name'].toDouble();
    this.optionWith = 1;
  }

  // for sync item option of invoice from server
  Map<String, dynamic> itemOptionFromServer(
      {dynamic item, String parent, String itemUniqueId, int invoiceId}) {
    Map<String, dynamic> map = <String, dynamic>{
      'item_unique_id': itemUniqueId,
      'parent': parent,
      'item_code': item['item_code'],
      'item_name': item['item_name'],
      'price_list_rate': item['price_list_rate'],
      'option_with': 1,
      'selected': this.selected,
      'FK_item_option_invoice_id': this.invoiceId
    };
    return map;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'parent': this.parent,
      'item_code': this.itemCode,
      'item_name': this.itemName,
      'price_list_rate': this.priceListRate,
      'option_with': this.optionWith
    };
    return map;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = <String, dynamic>{
      "item_unique_id": this.itemUniqueId,
      "parent": this.parent,
      "item_code": this.itemCode,
      "item_name": this.itemName,
      "price_list_rate": this.priceListRate,
      "option_with": this.optionWith,
      "selected": this.selected,
      "FK_item_option_invoice_id": this.invoiceId
    };
    return map;
  }

  ItemOption.itemOptionOfItemOfGroup(Map<String, dynamic> json) {
    this.itemUniqueId = json['item_unique_id'].toString();
    this.parent = json['parent'].toString();
    this.itemCode = json['item_code'].toString();
    this.itemName = json['item_name'].toString();
    this.priceListRate = json['price_list_rate'].toDouble();
    this.optionWith = json['option_with'];
  }

  ItemOption.fromSqlite(Map<String, dynamic> json) {
    this.itemUniqueId = json['item_unique_id'].toString();
    this.parent = json['parent'].toString();
    this.itemCode = json['item_code'].toString();
    this.itemName = json['item_name'].toString();
    this.priceListRate = json['price_list_rate'].toDouble();
    this.optionWith = json['option_with'];
    this.selected = json['option_with'] == 1 ? true : false;
  }
}
