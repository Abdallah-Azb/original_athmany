import 'package:flutter/material.dart';

class ItemName extends StatelessWidget {
  final String itemName;
  const ItemName({Key key, this.itemName}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(child: Text(itemName),);
  }
}
