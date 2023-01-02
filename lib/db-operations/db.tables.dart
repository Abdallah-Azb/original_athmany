import 'package:app/modules/tables/models/table.dart';
import 'package:app/services/services.dart';

class DBDineInTables {
  Future create() async {
    await DBService().createTablesTable(db);
  }

  Future<List<TableModel>> getAllTables() async {
    var data = await db.rawQuery('SELECT * FROM tables');
    List<TableModel> tables = data.map((e) => TableModel.fromMap(e)).toList();
    return tables;
  }

  Future<List<TableModel>> getTables(String category) async {
    var data = await db
        .rawQuery('SELECT * FROM tables WHERE category = ?', [category]);
    List<TableModel> tables = data.map((e) => TableModel.fromMap(e)).toList();
    return tables;
  }

  Future addTable(TableModel table) async {
    return await db.insert('tables', table.toMap());
  }

  Future addAll(List<TableModel> tables) async {
    for (var table in tables) {
      table..no = table.no + 1;
      await addTable(table);
    }
  }

  // reserve table
  Future<void> reserveTable(int tableNo) async {
    var map = <String, dynamic>{'reserved': 1};

    return await db
        .update('tables', map, where: 'no = ?', whereArgs: [tableNo]);
  }

  // reserve table
  Future<void> releaseTable(int tableNo) async {
    var map = <String, dynamic>{'reserved': 0};

    return await db
        .update('tables', map, where: 'no = ?', whereArgs: [tableNo]);
  }

  Future<void> changeTableNo(int invoiceId, int tableNo, int oldTableNo) async {
    await reserveTable(tableNo);
    await releaseTable(oldTableNo);
    await updateInvoiceTableNo(invoiceId, tableNo);
  }

  Future<void> updateInvoiceTableNo(int invoiceId, int tableNo) async {
    var map = <String, dynamic>{'table_no': tableNo};

    return await db
        .update('invoices', map, where: 'id = ?', whereArgs: [invoiceId]);
  }
}
