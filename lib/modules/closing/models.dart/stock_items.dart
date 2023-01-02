class StockItems {
  String itemName;
  String itemCode;
  String qty;
  String base_total;
  StockItems({
    this.itemName,
    this.itemCode,
    this.qty,
    this.base_total,
  });

  StockItems.fromServer(Map<dynamic, dynamic> map) {
    this.itemName = map['item_name'];
    this.itemCode = map['item_code'];
    this.qty = map['qty'];
    this.base_total = map['base_total'];
  }
}
