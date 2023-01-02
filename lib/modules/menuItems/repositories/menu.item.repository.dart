import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:flutter/material.dart';

class MenuItemRepository {
  // get items of group
  Future<List<ItemOfGroup>> getItemsOfGroup(String selectedItemGroup,
      {String tableName: "default_price_list"}) async {
    return await DBItemOfGroup().getItemsOfGroup(selectedItemGroup, tableName);
  }

  Future<Widget> getLogoForPrint() async {
    ProfileDetails posProfileDetails =
        await DBProfileDetails().getProfileDetails();

    // return await PrintService().logoForPrint(posProfileDetails);
  }
}
