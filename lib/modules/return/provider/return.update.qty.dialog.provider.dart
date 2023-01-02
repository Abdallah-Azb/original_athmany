import 'package:app/modules/return/models/return.model.dart';
import 'package:flutter/material.dart';

class ReturnUpdateDialogProvider extends ChangeNotifier {
  ReturnItem _returnItem;

  int itemQty;

  ReturnUpdateDialogProvider(int returnQty, {this.itemQty}) {
    this._amount = returnQty.toString();
  }
  ReturnItem get returnItem => _returnItem;

  // initialReturnInvoice(context, ReturnItem returnItem) async {
  //   this._returnItem = returnItem;
  //   this._amount = returnQty.toString();
  //   notifyListeners();
  // }

  String _amount;
  String get amount => _amount;

  void setAmount(String newAmount) {
    if (int.parse(newAmount) <= this.itemQty) {
      _amount = newAmount;
    }
    notifyListeners();
  }

  bool _clearAmount = true;
  bool get clearAmount => _clearAmount;

  setClearAmount(bool state) {
    _clearAmount = state;
    notifyListeners();
  }
}
