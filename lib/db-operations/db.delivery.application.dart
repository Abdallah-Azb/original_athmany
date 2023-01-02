import 'package:app/models/models.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/services/db.service.dart';
import 'package:sqflite/sqflite.dart';

import '../services/auth.service.dart';
import 'db.operations.dart';

class DBDeliveryApplication {
  DBItemsGroup _dbItemsGroup = DBItemsGroup();

  // drop and create items of group table
  static Future dropAndCreateDeliveryApplicationsTable() async {
    await db.execute("DROP TABLE IF EXISTS delivery_applications");
    await DBService().createDeliveryApplicationsTable(db);
  }

  Future create() async {
    await DBService().createDeliveryApplicationsTable(db);
  }

  // add item of group to sqlite
  Future add(DeliveryApplication application) async {
    return await db.insert("delivery_applications", application.toJson());
  }

  Future addAll(List<DeliveryApplication> applications) async {
    for (var application in applications) {
      await add(application);
    }
  }

  Future addGroupWithItems(
      List<DeliveryApplicationWithGroupsAndItems>
          deliveryApplicationWithGroupsAndItems) async {
    try {
          for (var deliveryApplication in deliveryApplicationWithGroupsAndItems) {
            _dbItemsGroup.addItems(
             deliveryApplication.groupsWithItems,
              tableName: deliveryApplication.deliveryApplication.name,
            );
          }
        } on DatabaseException catch (e) {
          throw Failure(e.toString());
    }
  }

  Future<List<DeliveryApplication>> getAll() async {
    print("❌❌❌❌❌❌❌❌❌❌❌");
    List<DeliveryApplication> deliveryApplicationList = [];
    final sql = '''SELECT * FROM delivery_applications''';
    final data = await db.rawQuery(sql);
    print(data.length);
    for (final node in data) {
      final DeliveryApplication deliveryApplication =
          DeliveryApplication.fromSqlite(node);
      deliveryApplicationList.add(deliveryApplication);
    }
    return deliveryApplicationList;
  }

  static Future<DeliveryApplication> getByName(String name) async {
    final sql =
        '''SELECT * FROM delivery_applications WHERE customer = "$name" ORDER BY id DESC''';
    final data = await db.rawQuery(sql);
    return DeliveryApplication.fromSqlite(data?.first);
  }
}
