import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:flutter/material.dart';

import '../menu.item.dart';

class MenuItemProvider extends ChangeNotifier {
  String selectedItemGroup;
  Widget logo;
  int selectedItemGroupIndex = 0;
  TabController tabController;
  final _itemsGroups = <ItemsGroups>[];
  List<ItemsGroups> get itemsGroup => _itemsGroups;
  MenuItemRepository _menuItemRepository = MenuItemRepository();

  final GlobalKey<ItemGroupsContainerState> itemGroupsContainerState =
      GlobalKey<ItemGroupsContainerState>();

  Future<List<ItemOfGroup>> getItemsOfGroupsAndLogo(
      String itemGroup, String tableName) async {
    return await _menuItemRepository.getItemsOfGroup(itemGroup,
        tableName: tableName);
  }

  void updateSelectedIndex(int index) {
    if (tabController != null) tabController.animateTo(index);
  }

  Future<int> getItemGroupIndex(String itemGroup) async {
    // List<ItemsGroups> itemsGroups = await DBItemsGroup.getItemGroups();
    List<ItemsGroups> itemsGroups = [];
    if (_itemsGroups.isNotEmpty) {
      itemsGroups = await DBItemsGroup.getItemGroups();
      _itemsGroups.addAll(itemsGroups);
    }
    ItemsGroups item =
        itemsGroups.where((element) => element.itemGroup == itemGroup).first;

    return itemsGroups.indexOf(item);
  }

  Future<ItemOfGroup> getItemGroup(String itemGroup, String tableName) async {
    return await DBItemOfGroup().getItemOfGroup(itemGroup, tableName);
  }

  Future getLogo() async {
    logo = await _menuItemRepository.getLogoForPrint();
    notifyListeners();
  }

  void updateMainWidget(String itemGroup) {
    selectedItemGroup = itemGroup;
    notifyListeners();
  }

  void resetItemGroup() {
    getItemsOfGroup(0);
  }

  void getItemsOfGroup(int index) {
    selectedItemGroupIndex = index;
    notifyListeners();
  }
}
