import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/services/auth.service.dart';
import 'package:app/services/db.service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';

class DBAccessory {
  // drop and create device table
  Future dropAndCreateDeviceTable() async {
    await db.execute("DROP TABLE IF EXISTS accessories");
    await DBService().createAccessoriesTable(db);
  }

  Future create() async {
    await DBService().createAccessoriesTable(db);
  }

  // add device sqlite
  Future add(Accessory device) async {
    print("========== ${device.toMap()}");
    return await db.insert('accessories', device.toMap());
  }

  Future addAll(List<Accessory> accessories) async {
    for (var accessory in accessories) {
      var accessoryId = await add(accessory);

      if (accessory.itemsGroups != null && accessory.itemsGroups.length != 0)
        await DBAccessory().addCategories(accessory..id = accessoryId);
    }
  }

  Future addCategories(Accessory accessory) async {
    for (var category in accessory.itemsGroups) {
      print("are you here 1 ?????");
      ItemsGroups itemGroups =
          await DBItemsGroup().getByName(category.itemGroup);

      if(itemGroups == null)
        break;
      CategoriesAccessories categoriesAccessories = CategoriesAccessories(
        deviceId: accessory.id,
        categoryId: itemGroups.id,
        isActive: true,
      );

      await DBCategoriesAccessories.add(categoriesAccessories);
    }
  }

  // get device
  Future<List<Accessory>> getAllAccessories() async {
    List<Accessory> accessories = [];
    final sql = '''SELECT * FROM accessories WHERE deleted != 1''';
    final data = await db.rawQuery(sql);
    for (final node in data) {
      final Accessory device = Accessory.fromSqlite(node);
      accessories.add(device);
    }
    return accessories;
  }

  // get one device
  Future<Accessory> getDevice(int id) async {
    final data =
        await db.rawQuery('SELECT * FROM accessories WHERE id = ?', [id]);
    Accessory device = Accessory.fromSqlite(data[0]);
    return device;
  }

  Future updateDevice(Accessory device) async {
    await db.rawUpdate(
        'UPDATE accessories SET device_name = ?, ip = ? WHERE id = ?',
        [device.deviceName, device.ip ?? '0.0.0.0', device.id]);
  }

  Future deleteAccessory(Accessory accessory) async {
    try {
      print('delete accessory from db with an ip ====== ${accessory.ip}');
      await DBCategoriesAccessories.deleteCategoriesByDevice(
          accessory.id.toString());
      await db.rawDelete(
          '''DELETE FROM accessories WHERE id = ?''', [accessory.id]);
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure(e.toString());
    }
  }

  // delete device and its categories
  Future<void> deleteDeviceAndRelatedCategories(int deviceId) async {
    await db.rawUpdate(
        'UPDATE accessories SET deleted = 1 WHERE id = ?', [deviceId]);
    await db.rawQuery(
        'DELETE FROM categories_of_accessories WHERE FK_category_accessory_id = ?',
        [deviceId]);
  }

  // update is_synced
  Future<void> isSynced(int id, int isSynced) async {
    var map = <String, dynamic>{'is_synced': isSynced};
    try {
      return await db
          .update('accessories', map, where: 'id = ?', whereArgs: [id]);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<void> updateDeviceNameFromServer(int id, String name) async {
    var map = <String, dynamic>{'name': name};

    return await db
        .update('accessories', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Accessory>> getAllNotSyncedAccessories() async {
    try {
      final sql =
          '''SELECT * FROM accessories WHERE deleted != 1 AND is_synced = 0 ORDER BY id DESC''';
      final data = await db.rawQuery(sql);
      return data.map((e) => Accessory.fromSqlite(e)).toList();
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }
}
