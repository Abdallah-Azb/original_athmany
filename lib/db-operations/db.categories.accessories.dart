import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/services/db.service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

class DBCategoriesAccessories {
  // drop and create categories devices table
  static Future dropAndCreateCategoriesAccessoriesTable() async {
    await db.execute("DROP TABLE IF EXISTS categories_of_accessories");
    await DBService().createCategoriesAccessoriesTable(db);
  }

  Future create() async {
    await DBService().createCategoriesAccessoriesTable(db);
    print(" :::: createCategoriesAccessoriesTable ::::");
  }

  // add category device to sqlite
  static Future add(CategoriesAccessories categoriesAccessories) async {
    return await db.insert(
        'categories_of_accessories', categoriesAccessories.toMap());
  }

  // remove category device from sqlite
  static Future remove(CategoriesAccessories categoriesAccessories) async {
    return await db.rawDelete(
        'DELETE FROM categories_of_accessories WHERE FK_category_group_id = ?',
        [categoriesAccessories.categoryId]);
  }

  // check if category linked to printer
  static Future cehckIfExists(String categoryId, String deviceId) async {
    return await db.rawQuery(
        '''SELECT * FROM categories_of_accessories WHERE FK_category_group_id = $categoryId AND FK_category_accessory_id = $deviceId ORDER BY id DESC''');
  }

  static Future<List<CategoriesAccessories>> getCategoriesOfAccessory(
      int deviceId) async {
    List<CategoriesAccessories> categorisAccessories = [];
    final data = await db.rawQuery(
        'SELECT * FROM categories_of_accessories WHERE FK_category_accessory_id = ?',
        [deviceId.toString()]);
    // '''SELECT * FROM categories_of_accessories WHERE FK_category_device_id = $deviceId''');
    for (var node in data) {
      ItemsGroups itemsGroup =
          await DBItemsGroup.getItemGroupsById(node['FK_category_group_id']);

      CategoriesAccessories categoryAccessory =
          CategoriesAccessories.fromMap(node);
      categoryAccessory..categoryTitle = itemsGroup.itemGroup;
      categorisAccessories.add(categoryAccessory);
    }
    return categorisAccessories;
  }

  Future<void> deleteCategoriesOfAccessory(Accessory accessory) async {
    try {
      final sql =
          '''DELETE FROM categories_of_accessories WHERE FK_category_accessory_id = ?''';
      return db.rawDelete(sql, [accessory.id]);
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  static Future<bool> deleteCategoriesByDevice(String deviceId) async {
    final sql =
        '''DELETE FROM categories_of_accessories WHERE FK_category_accessory_id = ?''';

    var affectedRaws = await db.rawDelete(sql, [deviceId]);
    return affectedRaws != 0;
  }
}
