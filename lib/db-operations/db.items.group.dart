import 'dart:developer';

import 'package:app/models/models.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/services/db.service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqlite_api.dart';

import '../services/auth.service.dart';
import 'db.operations.dart';

class DBItemsGroup {
  DBItemOfGroup _dbItemOfGroup = DBItemOfGroup();

  // drop and create item groups table
  static Future dropAndCreateItemGroupsTable() async {
    await db.execute("DROP TABLE IF EXISTS item_groups");
    await DBService().createItemGroupsTable(db);
  }

  Future create() async {
    await DBService().createItemGroupsTable(db);
  }

  // add item group to sqlite
  Future add(ItemsGroups itemsGroup) async {
    return await db.insert('item_groups', itemsGroup.toSqlite());
  }

  Future getByName(String itemGroup) async {
    log("are you here 2 ?????");
    var result = await db.rawQuery(
        'SELECT * FROM item_groups WHERE item_group = ?', [itemGroup]);
    if(result.isEmpty)
      return null;
    if(result.isNotEmpty)
    return ItemsGroups.fromSqlite(result.first);
  }

  Future addAll(List<ItemsGroups> itemsGroup) async {
    for (var itemGroup in itemsGroup) {
      await add(itemGroup);
    }
  }

  Future addGroupWithItems(List<GroupWithItems> groupsWithItems,
  {String tableName = 'default_price_list',
        bool cachItmesImages: false}) async {
    try {
      final stopwatch = Stopwatch()..start();
      for (var groupWithItem in groupsWithItems) {
        await add(groupWithItem.itemsGroups);
        await _dbItemOfGroup.addAll(groupWithItem.itemOfGroup,
            tableName: tableName, cachItmesImages: cachItmesImages);
      }
      print(" ::::::::::::::: addGroupWithItems lpp in addALL :::  ${stopwatch.elapsed} ::::::::::::::: ");
    } on DatabaseException catch (e) {
      throw Failure(e.toString());
    }
  }

  Future addItems(List<GroupWithItems> groupsWithItems,
      {String tableName = 'default_price_list'}) async {
    for (var groupWithItem in groupsWithItems) {
      await _dbItemOfGroup.addAll(
        groupWithItem.itemOfGroup,
        tableName: tableName,
      );
    }
  }

  // get item groups
  static Future<List<ItemsGroups>> getItemGroups() async {
    List<ItemsGroups> itemGroups = [];
    final sql = '''SELECT * FROM item_groups''';
    final data = await db.rawQuery(sql);
    for (final node in data) {
      final ItemsGroups itemsGroup = ItemsGroups.fromSqlite(node);
      itemGroups.add(itemsGroup);
    }
    return itemGroups;
  }

  static Future<ItemsGroups> getItemGroupsById(int itemsGroupId) async {
    try {
      final data = await db
          .rawQuery('SELECT * FROM item_groups WHERE id = ?', [itemsGroupId]);
      return ItemsGroups.fromSqlite(data[0]);
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
      throw e;
    }
  }
}
