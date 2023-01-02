import 'package:app/models/models.dart';
import 'package:flutter/material.dart';

class QtyDialogProvider extends ChangeNotifier {
  String _itemUniqueId;
  String get itemUniqueId => _itemUniqueId;
  setItemUniqueId(String itemUniqueId) {
    _itemUniqueId = itemUniqueId;
    notifyListeners();
  }

  List<ItemOption> _itemOptionsWith = [];
  List<ItemOption> get itemOptionsWith => _itemOptionsWith;

  List<ItemOption> _itemOptionsWithout = [];
  List<ItemOption> get itemOptionsWithout => _itemOptionsWithout;

  initItemOptions(List<ItemOption> itemOptions) {
    _itemOptionsWith = itemOptions.where((element) => element.optionWith == 1).toList();
    _itemOptionsWithout = itemOptions.where((element) => element.optionWith == 0).toList();
    notifyListeners();
  }

  updateItemOptionWithStatus(ItemOption itemOption, bool status) {
    this
        ._itemOptionsWith
        .firstWhere((e) => e.itemCode == itemOption.itemCode)
        .selected = status;
    notifyListeners();
  }

  updateItemOptionWithoutStatus(ItemOption itemOption, bool status) {
    this
        ._itemOptionsWithout
        .firstWhere((e) => e.itemCode == itemOption.itemCode)
        .selected = status;
    notifyListeners();
  }

  String _amount = "1";
  String get amount => _amount;

  void setAmount(String newAmount) {
    _amount = newAmount;
    notifyListeners();
  }

  bool _clearAmount = true;
  bool get clearAmount => _clearAmount;

  setClearAmount(bool state) {
    _clearAmount = state;
    notifyListeners();
  }

  clear() {
    this._itemOptionsWith = [];
    this._itemOptionsWithout = [];
    this._clearAmount = true;
  }
}
