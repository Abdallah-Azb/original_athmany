import 'package:app/models/models.dart';
import 'package:app/services/services.dart';

class DBItems {
  Future create() async {
    await DBService().createItemsOfInvoicesTable(db);
  }

  // get items of invoice
  Future<List<Item>> getItemsOfInvoice(int invoiceId) async {
    final data = await db.rawQuery(
        'SELECT * FROM items_of_invoices WHERE FK_item_invoice_id = ?',
        [invoiceId]);

    List<Item> items = data.map((e) => Item.fromSqlite(e)).toList();

    return items;
  }

  // add item of invoice to sqlite
  Future addItemOfInvoice(Item item) async {
    return await db.insert('items_of_invoices', item.toMap());
  }

  Future addItemsToInvoice(List items) async {
    for (var item in items) {
      await addItemOfInvoice(item);
    }
  }

  // delete items of invoice
  Future<void> deleteItemsOfInvoice(int invoiceId) async {
    await db.rawQuery(
        'DELETE FROM items_of_invoices WHERE FK_item_invoice_id = ?',
        [invoiceId]);
  }
}
