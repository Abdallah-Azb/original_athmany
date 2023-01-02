import 'package:app/db-operations/db.invoice.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/tables/tables.dart';

class TablesRepository {
  Future<List<TableModel>> getTables(String category) async {
    return await DBDineInTables().getTables(category);
  }
}
