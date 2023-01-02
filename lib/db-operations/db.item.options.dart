import 'package:app/services/db.service.dart';
import 'package:app/models/models.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqlite_api.dart';

class DBItemOptions {
  // drop and create item options with table
  Future dropAndCreateItemWithOptionsTable() async {
    await db.execute("DROP TABLE IF EXISTS item_options");
    await DBService().createItemOptionsTable(db);
  }

  Future create() async {
    await DBService().createItemOptionsTable(db);
    await DBService().createItemsOptionsOfInvoicesTable(db);
  }

  // get item options
  Future<List<ItemOption>> getItemOptions(String parent) async {
    var data = await db
        .rawQuery('SELECT * FROM item_options WHERE parent = ?', [parent]);
    List<ItemOption> itemOptions =
        data.map((e) => ItemOption.itemOptionOfItemOfGroup(e)).toList();
    return itemOptions;
  }

  // add item option
  Future addItemOptionOfInvoice(ItemOption itemOption) async {
    itemOption..selected = true;
    await db.insert('items_options_of_invoices', itemOption.toJson());
  }

  Future addItemOptionOfInvoiceFromServer(
      Map<String, dynamic> itemOption) async {
    await db.insert('items_options_of_invoices', itemOption);
  }

  // get item options of invoice
  Future<List<ItemOption>> getItemOptionsOfInvoice(String itemUniqueId) async {
    try {
      var data = await db.rawQuery(
          'SELECT * FROM items_options_of_invoices WHERE item_unique_id = ?',
          [itemUniqueId]);
      List<ItemOption> itemOptions =
          data.map((e) => ItemOption.fromSqlite(e)).toList();
      return itemOptions;
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  // get items options of invoice
  Future<List<ItemOption>> getItemsOptionsOfInvoice(int invoiceId) async {
    var data = await db.rawQuery(
        'SELECT * FROM items_options_of_invoices WHERE FK_item_option_invoice_id = ?',
        [invoiceId]);
    List<ItemOption> itemOptions =
        data.map((e) => ItemOption.fromSqlite(e)).toList();
    return itemOptions;
  }

  // delete items options of invoice
  Future<void> deleteItemsOptionsOfInvoice(int invoiceId) async {
    await db.rawQuery(
        'DELETE FROM items_options_of_invoices WHERE FK_item_option_invoice_id = ?',
        [invoiceId]);
  }
}
