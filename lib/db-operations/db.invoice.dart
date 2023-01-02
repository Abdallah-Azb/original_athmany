import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/tables/tables.dart';
import 'package:app/services/db.service.dart';
import 'package:app/models/models.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DBInvoice {
  ///////////////////////////////////
  ///
  ///
  ///tables
  // drop and create tables table
  static Future dropAndCreateTablesTable() async {
    await db.execute("DROP TABLE IF EXISTS tables");
    await DBService().createTablesTable(db);
  }

  // add table to sqlite
  static Future addTable(int tableNo) async {
    Map<String, dynamic> map = {'no': tableNo, 'reserved': 0};
    return await db.insert('tables', map);
  }

  // get all tables
  static Future<List<TableModel>> getTables(String category) async {
    var data = await db
        .rawQuery('SELECT * FROM tables WHERE category = ?', [category]);
    List<TableModel> tables = data.map((e) => TableModel.fromMap(e)).toList();
    return tables;
  }

  // reserve table
  static Future<void> reserveTable(int tableNo) async {
    var map = <String, dynamic>{'reserved': 1};

    return await db
        .update('tables', map, where: 'no = ?', whereArgs: [tableNo]);
  }

  // reserve table
  static Future<void> releaseTable(int tableNo) async {
    var map = <String, dynamic>{'reserved': 0};

    return await db
        .update('tables', map, where: 'no = ?', whereArgs: [tableNo]);
  }

  ///////////////////////////////////
  ///
  ///
  ///invoices
  // drop and create invoices table
  static Future dropAndCreateInvoicesTable() async {
    await db.execute("DROP TABLE IF EXISTS invoices");
    await DBService().createInvoicesTable(db);
  }

  Future create() async {
    await DBService().createInvoicesTable(db);
  }

  // get invoices length
  static Future<int> getInvoicesLength() async {
    List<Invoice> invoices = [];
    final sql = '''SELECT * FROM invoices''';
    final data = await db.rawQuery(sql);
    for (final node in data) {
      final Invoice invoice = Invoice.fromSqlite(node);
      invoices.add(invoice);
    }
    return invoices.length;
  }

  // get all invoices (not deleted)
  static Future<List<Invoice>> getAllInvoices() async {
    List<Invoice> invoices = [];
    try {
      final sql = '''SELECT * FROM invoices ORDER BY id DESC''';
      final data = await db.rawQuery(sql);
      for (final node in data) {
        final Invoice invoiceFromSqlite = Invoice.fromSqlite(node);
        Invoice invoice = await DBInvoiceRefactor()
            .getCompleteInvoice(id: invoiceFromSqlite.id);

        invoices.add(invoice);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
    return invoices;
  }

  Future checkIfInvoicesNotSynced() async {
    final sql = '''SELECT * FROM invoices WHERE is_synced = 0''';
    final data = await db.rawQuery(sql);

    return data.length != 0;
  }

  // get all invoices (not deleted)
  static Future<List<Invoice>> getInvoices() async {
    List<Invoice> invoices = [];
    final sql = '''SELECT * FROM invoices WHERE deleted = 0 ORDER BY id DESC''';
    final data = await db.rawQuery(sql);
    for (final node in data) {
      final Invoice invoice = Invoice.fromSqlite(node);
      invoices.add(invoice);
    }
    return invoices;
  }

  // add invoice to sqlite
  static Future add(Invoice invoice, String invoiceReference) async {
    // return await db.insert('invoices', invoice.toMap(invoiceReference));
  }

  // add invoice to sqlite
  static Future addInvoiceFromServer(dynamic invoice) async {
    return await db.insert('invoices', invoice);
  }

  // get one ivnoice
  static Future<Invoice> getInvoice(int id) async {
    final data = await db.rawQuery('SELECT * FROM invoices WHERE id = ?', [id]);
    Invoice invoice = Invoice.fromSqlite(data[0]);
    ProfileDetails profileDetails =
        await DBProfileDetails().getProfileDetails();
    CompanyDetails companyDetails =
        await DBCompanyDetails().getCompanyDetails();
    List<Item> items = await DBItems().getItemsOfInvoice(invoice.id);
    List<Tax> taxes = await DBTaxes().getTaxesOfInvoice(invoice.id);
    PaymentsInfo paymentsInfo =
        await InvoiceRepositoryRefactor().getPayments(invoice);

    invoice
      ..profileDetails = profileDetails
      ..defaultReceivableAccount = companyDetails.defaultReceivableAccount
      ..items = items
      ..taxes = taxes
      ..payments = paymentsInfo.payments
      ..paidTotal = paymentsInfo.paidTotal;

    return invoice;
  }

  // delete invoice and its items
  static Future<void> deleteInvoice(int invoiceId) async {
    await db
        .rawUpdate('UPDATE invoices SET deleted = 1 WHERE id = ?', [invoiceId]);
    await db.rawQuery(
        'DELETE FROM items_of_invoices WHERE FK_item_invoice_id = ?',
        [invoiceId]);
  }

  // update is_synced
  static Future<void> isSynced(int invoiceId, int isSynced) async {
    var map = <String, dynamic>{'is_synced': isSynced};
    try {
      return await db
          .update('invoices', map, where: 'id = ?', whereArgs: [invoiceId]);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  // update invoie table no
  static Future<void> updateInvoiceTableNo(int invoiceId, int tableNo) async {
    var map = <String, dynamic>{'table_no': tableNo};
    try {
      await reserveTable(tableNo);
      return await db
          .update('invoices', map, where: 'id = ?', whereArgs: [invoiceId]);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
    }
  }

  // update invoie total
  static Future<void> updateInvoiceTotal(
      int invoiceId, double invoiceTotal) async {
    var map = <String, dynamic>{'total': invoiceTotal};
    try {
      return await db
          .update('invoices', map, where: 'id = ?', whereArgs: [invoiceId]);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
    }
  }

  static Future<void> changeTableNo(
      int invoiceId, int tableNo, int oldTableNo) async {
    await reserveTable(tableNo);
    await releaseTable(oldTableNo);
    await updateInvoiceTableNo(invoiceId, tableNo);
  }

  // set invioce doc_status 1 => true
  static Future<void> invoiceIsPaid(int invoiceId) async {
    await db.rawUpdate(
        'UPDATE invoices SET doc_status = 1 WHERE id = ?', [invoiceId]);
  }

  static Future<void> updateInvoiceNameFromServer(
      int invoiceId, String name) async {
    var map = <String, dynamic>{'name': name};
    try {
      return await db
          .update('invoices', map, where: 'id = ?', whereArgs: [invoiceId]);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
    }
  }

////////////////////////////////
  ///
  ///
  ///
  ///
  /// items
  // drop and create items table
  static Future dropAndCreateItemsOfInvoicesTable() async {
    await db.execute("DROP TABLE IF EXISTS items_of_invoices");
    await DBService().createItemsOfInvoicesTable(db);
  }

  // get items of invoice
  static Future<List<Item>> getItemsOfInvoice(int invoiceId) async {
    final data = await db.rawQuery(
        'SELECT * FROM items_of_invoices WHERE FK_item_invoice_id = ?',
        [invoiceId]);
    List<Item> items = [];
    for (final node in data) {
      final Item item = Item.fromSqlite(node);
      items.add(item);
    }
    return items;
  }

  // add item of invoice to sqlite
  static Future addItemOfInvoice(Item item, int invoiceId) async {
    return await db.insert('items_of_invoices', item.toMap());
  }

  static Future addItemOfFromServer(dynamic item) async {
    return await db.insert('items_of_invoices', item);
  }

  // delete items of invoice
  static Future<void> deleteItemsOfInvoice(int invoiceId) async {
    await db.rawQuery(
        'DELETE FROM items_of_invoices WHERE FK_item_invoice_id = ?',
        [invoiceId]);
  }

  //////////////////////////////////
  ///
  ///
  ///
  /// taxes
  // drop and create taxes table
  static Future dropAndCreateTaxesOfInvoicesTable() async {
    await db.execute("DROP TABLE IF EXISTS taxes_of_invoices");
    await DBService().createTaxesOfInvoicesTable(db);
  }

  // add tax of invoice to sqlite
  static Future addTaxOfInvoice(Tax tax, int invoiceId) async {
    tax..invoiceId = invoiceId;
    return await db.insert('taxes_of_invoices', tax.toMap());
  }

  // add tax from server
  static Future addTaxFromServer(dynamic tax, int invoiceId) async {
    return await db.insert('taxes_of_invoices', tax);
  }

  // delete taxes of invoice
  static Future<void> deleteTaxesOfInvoice(int invoiceId) async {
    await db.rawQuery(
        'DELETE FROM taxes_of_invoices WHERE FK_tax_invoice_id = ?',
        [invoiceId]);
  }

  // get taxes of invoice
  static Future<List<Tax>> getTaxesOfInvoice(int invoiceId) async {
    final data = await db.rawQuery(
        'SELECT * FROM taxes_of_invoices WHERE FK_tax_invoice_id = ?',
        [invoiceId]);
    List<Tax> taxes = [];
    for (final node in data) {
      final Tax tax = Tax.fromSqlite(node);
      taxes.add(tax);
    }
    return taxes;
  }

  //////////////////////////////////
  ///
  ///
  ///
  /// payments
  // drop and create payments table
  static Future dropAndCreatePaymentsOfInvoicesTable() async {
    await db.execute("DROP TABLE IF EXISTS payments_of_invoices");
    await DBService().createPaymentsOfInvoicesTable(db);
  }

  // add payment of invoice to sqlite
  static Future addPaymentOfInvoice(Payment payment, int invoiceId) async {
    payment..invoiceId = invoiceId;
    return await db.insert('payments_of_invoices', payment.toMap());
  }

  // delete payments of invoice
  static Future<void> deletePaymentsOfInvoice(int invoiceId) async {
    await db.rawQuery(
        'DELETE FROM payments_of_invoices WHERE FK_payment_invoice_id = ?',
        [invoiceId]);
  }

  // get payments of invoice
  static Future<List<Payment>> getPaymentsOfInvoice(int invoiceId) async {
    final data = await db.rawQuery(
        'SELECT * FROM payments_of_invoices WHERE FK_payment_invoice_id = ?',
        [invoiceId]);
    List<Payment> payments = [];
    for (final node in data) {
      final Payment payment = Payment.fromSqlite(node);
      payments.add(payment);
    }
    return payments;
  }
}
