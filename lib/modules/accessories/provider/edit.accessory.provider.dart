import 'package:app/db-operations/db.operations.dart';
import 'package:app/services/accessory.service.dart';
import 'package:flutter/material.dart';

import '../accessories.dart';

class EditAccessoryProvider extends ChangeNotifier {
  AccessoryRepository _accessoryRepository = AccessoryRepository();
  List<CategoriesAccessories> categoriesAccessories = [];
  List<TemporaryActions> temporaryActions = [];
  Accessory accessory;
  String accessoryName;
  String accessoryIp;
  bool isSave = false;

  Future onSaveCategories(context) async {
    updateStatus();
    print("=========== temporaryActions ::: ${temporaryActions.first.categoriesAccessories} ");
    for (var tempAction in temporaryActions) {
      if (tempAction.action) {
        // add
        await DBCategoriesAccessories.add(tempAction.categoriesAccessories);
      } else {
        // remove
        await DBCategoriesAccessories.remove(tempAction.categoriesAccessories);
      }
    }
    Navigator.pop(context);
    updateStatus();
  }

  Future onSaveAccessory() async {
    var newAccessory = accessory
      ..deviceName = accessoryName
      ..ip = accessoryIp;

    await DBAccessory().updateDevice(newAccessory);
    await AccessoryService().udpateDeviceAccessory(newAccessory);
  }

  onSwitch(bool value, categoriesAccessories) async {
    var tempAction = TemporaryActions(
      categoriesAccessories: categoriesAccessories,
      action: value,
    );

    if (!temporaryActions.contains(tempAction)) {
      temporaryActions.add(tempAction);
    }
  }

  Future<void> getCategories(int accessoryId) async {
    List<CategoriesAccessories> categories =
        await _accessoryRepository.getCategories(accessoryId);

    categoriesAccessories = categories;
    notifyListeners();
  }

  void updateStatus() {
    isSave = !isSave;
    notifyListeners();
  }

  void onAccessoryName(String newAccessoryName) {
    accessoryName = newAccessoryName;
    isFormValid();
    notifyListeners();
  }

  void onAccessoryIp(String newAccessoryIp) {
    accessoryIp = newAccessoryIp;
    isFormValid();
    notifyListeners();
  }

  bool isFormValid() =>
      accessoryName != null &&
      accessoryName.isNotEmpty &&
      (accessory.connection == Connection.BUILTIN ||
          (accessoryIp != null && accessoryIp.isNotEmpty));
}
