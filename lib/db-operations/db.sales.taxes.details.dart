import 'package:app/models/sales.taxes.details.dart';
import '../services/db.service.dart';

class DBSalesTaxesDetails {
  // drop and create sales taxes details table
  Future dropAndSalesTaxesDetailsTable() async {
    await db.execute("DROP TABLE IF EXISTS sales_taxes_details");
    await DBService().createSalesTaxesDetailsTable(db);
  }

  Future create() async {
    await DBService().createSalesTaxesDetailsTable(db);
  }

  // get sales taxes details
  Future<List<SalesTaxesDetails>> getSalesTaxeDetails() async {
    final sql = '''SELECT * FROM sales_taxes_details''';
    final data = await db.rawQuery(sql);
    List<SalesTaxesDetails> salesTaxeDetailsList = [];

    for (final node in data) {
      SalesTaxesDetails salesTaxeDetails = SalesTaxesDetails.fromSqlite(node);
      salesTaxeDetailsList.add(salesTaxeDetails);
    }
    return salesTaxeDetailsList;
  }

  // add sales taxe details
  Future add(SalesTaxesDetails salesTaxesDetails) async {
    return await db.insert('sales_taxes_details', salesTaxesDetails.toSqlite());
  }

  Future addAll(List<SalesTaxesDetails> salesTaxesDetails) async {
    for (var taxDetail in salesTaxesDetails) {
      await add(taxDetail);
    }
  }
}
