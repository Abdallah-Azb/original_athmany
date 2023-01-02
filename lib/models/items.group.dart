class ItemsGroups {
  int id;
  String itemGroup;

  ItemsGroups({this.id, this.itemGroup});

  //
  ItemsGroups.fromSqlite(Map<String, dynamic> json) {
    this.id = json['id'];
    this.itemGroup = json['item_group'];
  }

  //
  Map<String, dynamic> toSqlite() {
    var map = <String, dynamic>{
      'item_group': this.itemGroup,
    };
    return map;
  }
}
