import 'package:app/models/item.option.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:app/services/db.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DBItemOfGroup {
  // drop and create items of group table
  Future dropAndCreateItemsOfGroupTable(
      {String tableName = "default_price_list"}) async {
    await db.execute("DROP TABLE IF EXISTS $tableName");
    await create(tableName: tableName);
  }

  Future createDeliveryApplicationsTables(
      List<DeliveryApplicationWithGroupsAndItems> deliveryApplications) async {
    for (var deliveryApplication in deliveryApplications) {
      print(deliveryApplication.deliveryApplication.customer);
      await create(tableName: deliveryApplication.deliveryApplication.name);
    }
  }

  Future create({String tableName = "default_price_list"}) async {
    await DBService().createItemsOfGroupTable(db, tableName: tableName);
  }

  // add item of group to sqlite
  Future add(ItemOfGroup itemOfGroup,
      {String tableName = 'default_price_list'}) async {
    try {
      return await db.insert(tableName, itemOfGroup.toSqlite());
    } on DatabaseException catch (e) {
      if (e.isNoSuchTableError()) {
        await create(tableName: tableName);
        return await db.insert(tableName, itemOfGroup.toSqlite());
      }
      return 0;
    }
  }

  Future addAll(List<ItemOfGroup> itemsOfGroup,
      {String tableName = 'default_price_list',
      bool cachItmesImages: false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final stopwatch = Stopwatch()..start();
    for (ItemOfGroup itemOfGroup in itemsOfGroup) {
      await add(itemOfGroup, tableName: tableName);
      if (tableName == 'default_price_list') {
        if (itemOfGroup.itemImage != null && itemOfGroup.itemImage != "") {
          print("${prefs.getString('base_url')}/${itemOfGroup.itemImage}");
          if (cachItmesImages) {
            await CacheItemImageService().cacheImage(
                "${prefs.getString('base_url')}/${itemOfGroup.itemImage}",
                itemOfGroup.itemCode);
          }
        }
        await addItemOption(itemOfGroup);
      }
    }
    print(" =============== ItemOfGroup lpp in addALL :::  ${stopwatch.elapsed} ===============");
  }

  // add item option with
  Future addItemOption(ItemOfGroup itemOfGroup) async {
    for (ItemOption itemOption in itemOfGroup.itemOptions) {
      await db.insert('item_options', itemOption.toMap());
    }
  }

  // get items of group from sqlite
  Future<List<ItemOfGroup>> getItemsOfGroup(String itemGroup, tableName) async {
    final data = await db
        .rawQuery('SELECT * FROM $tableName WHERE item_group = ?', [itemGroup]);
    List<ItemOfGroup> itemsOfGroup = [];
    print("items data length :::::: ===== ${data.length}");
    for (final node in data) {
      final ItemOfGroup itemOfGroup = ItemOfGroup.fromSqlite(node);
      itemsOfGroup.add(itemOfGroup);
    }
    return itemsOfGroup;
  }

  Future<ItemOfGroup> getItemOfGroup(String itemGroup, String tableName) async {
    final data = await db
        .rawQuery('SELECT * FROM $tableName WHERE item_name = ? ', [itemGroup]);

    return ItemOfGroup.fromSqlite(data.first);
  }

  Future<ItemOfGroup> findItemOfGroup(String itemCode) async {
    final data = await db.rawQuery(
        'SELECT * FROM default_price_list WHERE item_code = ? ', [itemCode]);
    return ItemOfGroup.fromSqlite(data.first);
  }

  Future<List<ItemOfGroup>> getAllItems() async {
    final data = await db.rawQuery('SELECT * FROM default_price_list');
    List<ItemOfGroup> items =
        data.map((e) => ItemOfGroup.fromSqlite(e)).toList();
    return items;
  }
}
