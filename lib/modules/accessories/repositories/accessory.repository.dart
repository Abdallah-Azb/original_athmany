import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/services/accessory.service.dart';
import 'package:app/services/auth.service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../accessories.dart';

class AccessoryRepository {
  Future<List<CategoriesAccessories>> getCategories(int deviceId) async {
    List<CategoriesAccessories> categoriesAccessories = [];
    List<ItemsGroups> itemCategories = await DBItemsGroup.getItemGroups();

    for (var category in itemCategories) {
      var isExist = await DBCategoriesAccessories.cehckIfExists(
        category.id.toString(),
        deviceId.toString(),
      );

      categoriesAccessories.add(
        CategoriesAccessories(
          categoryId: category.id,
          deviceId: deviceId,
          categoryTitle: category.itemGroup,
          isActive: isExist.length != 0,
        ),
      );
    }

    return categoriesAccessories;
  }

  Future<void> deleteAccessory(Accessory accessory) async {
    print(accessory.ip);
    try {
      if (accessory.deviceFor.index == 0) {
        print(accessory.ip);
        await DBAccessory().deleteAccessory(accessory);
      } else if (accessory.deviceFor.index == 1) {
        print(accessory.deviceFor.index);
        // await DBCategoriesAccessories().deleteCategoriesOfAccessory(accessory);
        await DBAccessory().deleteAccessory(accessory);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  // Future<void> newDeleteAccessory(int index) async {
  //   // print(accessory.ip);
  //   try {
  //     if (accessory.deviceFor.index == 0) {
  //       print(accessory.ip);
  //       await DBAccessory().deleteAccessory(accessory);
  //     } else if (accessory.deviceFor.index == 1) {
  //       print(accessory.deviceFor.index);
  //       // await DBCategoriesAccessories().deleteCategoriesOfAccessory(accessory);
  //       await DBAccessory().deleteAccessory(accessory);
  //     }
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(
  //       e,
  //       stackTrace: stackTrace,
  //     );
  //     throw e;
  //   }
  // }

  Future<void> syncAccessories() async {
    List<Accessory> notSyncedAccessories =
        await DBAccessory().getAllNotSyncedAccessories();
    if (notSyncedAccessories.length == 0) print("all accessories are synced");
    for (Accessory accessory in notSyncedAccessories) {
      try {
        if (accessory.deleted == 0) {
          if (accessory.deviceFor.index == 0) {
            await AccessoryService().deleteAccessoryFromServer(accessory);
          } else if (accessory.deviceFor.index == 1) {
            await DBCategoriesAccessories()
                .deleteCategoriesOfAccessory(accessory);
            await AccessoryService().deleteAccessoryFromServer(accessory);
          }
        } else if (accessory.name != null && accessory.deleted == 1) {
          await AccessoryService().deleteAccessoryFromServer(accessory);
        }
      } on Failure catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        print("Could'nt sync(delete) invoice id: ${accessory.id}");
        throw e;
      }
    }
  }
}
