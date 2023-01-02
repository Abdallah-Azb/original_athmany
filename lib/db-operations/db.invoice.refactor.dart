import 'dart:developer';

import 'package:app/core/enums/enums.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/services/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DBInvoiceRefactor {
  DBItems _dbItems = DBItems();
  DBItemOptions _dbItemOptions = DBItemOptions();
  DBTaxes _dbTaxes = DBTaxes();
  DBDineInTables _dbTables = DBDineInTables();
  DBPayments _dbPayments = DBPayments();
  DBProfileDetails _dbProfileDetails = DBProfileDetails();
  DBCompanyDetails _dbCompanyDetails = DBCompanyDetails();

  Future create() async {
    await DBService().createInvoicesTable(db);
  }

  Future checkIfInvoicesNotSynced() async {
    final sql = '''SELECT * FROM invoices WHERE is_synced = 0''';
    final data = await db.rawQuery(sql);
    print("xxxxxxxx :${data}");
    return data.length != 0;
  }

  // get items of invoice
  Future<List<Item>> getItemsOfInvoice(int invoiceId) async {
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

  Future<void> updateInvoiceNameFromServer(int invoiceId, String name) async {
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

  // for dublicate issue
  Future<void> updateInvoiceNameFromServer1(
      String offlineInvoice, String name) async {
    var map = <String, dynamic>{'name': name};
    try {
      return await db.update('invoices', map,
          where: 'offline_invoice = ?', whereArgs: [offlineInvoice]);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
    }
  }

  // get all invoices (not deleted)
  Future<List<Invoice>> getAllInvoices() async {
    try {
      final sql =
          '''SELECT * FROM invoices WHERE deleted != 1 ORDER BY id DESC''';
      final data = await db.rawQuery(sql);
      return data.map((e) => Invoice.fromSqlite(e)).toList();
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  // get saved invoices (not deleted)
  Future<List<Invoice>> getSavedInvoices() async {
    try {
      final sql =
          '''SELECT * FROM invoices WHERE deleted != 1 AND doc_status = 0 ORDER BY id DESC''';
      final data = await db.rawQuery(sql);
      return data.map((e) => Invoice.fromSqlite(e)).toList();
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<List<Invoice>> getAllNotSyncedInvoices() async {
    try {
      final sql =
          '''SELECT * FROM invoices WHERE deleted != 1 AND is_synced = 0 ORDER BY id DESC''';
      final data = await db.rawQuery(sql);
      return data.map((e) => Invoice.fromSqlite(e)).toList();
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<List<Payment>> getPaymentsOfInvoice(int invoiceId) async {
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

  // debug point
  Future<Invoice> getCompleteInvoice({int id, String name, int tableNo}) async {
    try {
      var data;
      if (id != null) {
        data = await db.rawQuery('SELECT * FROM invoices WHERE id = ?', [id]);
      }

      if (name != null) {
        data =
            await db.rawQuery('SELECT * FROM invoices WHERE name = ?', [name]);
      }

      if (tableNo != null) {
        data = await db.rawQuery(
            'SELECT * FROM invoices WHERE table_no = ? AND doc_status = ?',
            [tableNo, 0]);
      }
      Invoice invoice = Invoice.fromSqlite(data[0]);
      ProfileDetails profileDetails =
          await _dbProfileDetails.getProfileDetails();
      CompanyDetails companyDetails =
          await _dbCompanyDetails.getCompanyDetails();
      List<Item> items = await _dbItems.getItemsOfInvoice(invoice.id);

      for (Item item in items) {
        List<ItemOption> itemOptions =
            await DBItemOptions().getItemOptionsOfInvoice(item.uniqueId);
        item.itemOptionsWith =
            itemOptions.where((e) => e.optionWith == 1).toList();
      }

      List<Tax> taxes = await DBTaxes().getTaxesOfInvoice(invoice.id);

      List<Payment> payments =
          await _dbPayments.getPaymentsOfInvoice(invoice.id);
      PaymentsInfo paymentsInfo =
          await InvoiceRepositoryRefactor().getPayments(invoice);
      print(
          '===================== paymentsInfo.paidTotal =====================');
      print(paymentsInfo.paidTotal);
      print(invoice.total);

      print(
          '===================== paymentsInfo.paidTotal =====================');
      invoice
        ..profileDetails = profileDetails
        ..defaultReceivableAccount = companyDetails.defaultReceivableAccount
        ..items = items
        ..taxes = taxes
        ..payments = payments
        ..paidTotal = paymentsInfo.paidTotal
        ..coupon_code = invoice.coupon_code;
      print("cccccccccc ${invoice.coupon_code}");

      print('printed ${invoice.paidTotal} ');
      return invoice;
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future findInvoicesByCustomerName(String customerNmae) async {
    var data = await db.rawQuery(
        'SELECT * FROM invoices WHERE customer LIKE ? AND deleted = ? ORDER BY id DESC',
        ['%$customerNmae%', 0]);

    List<Invoice> invoices = data.map((e) => Invoice.fromSqlite(e)).toList();

    return invoices;
  }

  Future<int> getLastInsertedInvoiceId() async {
    var data = await db.rawQuery('SELECT MAX(id) as id FROM invoices');
    return data.first["id"];
  }

  // update invoie total
  Future<void> updateInvoiceTotal(int invoiceId, double invoiceTotal,
      {double discountAmount, double returnTotal}) async {
    if (returnTotal != null) invoiceTotal = returnTotal;

    var map = <String, dynamic>{'total': invoiceTotal};
    // if(discountAmount != 0.0)
    //    map = <String, dynamic>{'total': invoiceTotal-discountAmount};
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

  // additional_discount_percentage DOUBLE,
  //     coupon_code TEXT,
  // discount_amount DOUBLE
  Future<void> updateInvoiceDiscount(int invoiceId, double discountAmount,
      String couponCode, double additionalDiscountPercentage) async {
    var map = <String, dynamic>{
      'discount_amount': discountAmount,
      'coupon_code': couponCode,
      'additional_discount_percentage': additionalDiscountPercentage
    };
    // if(discountAmount != 0.0)
    //    map = <String, dynamic>{'total': invoiceTotal-discountAmount};
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

  Future findInvoicesByName(String name) async {
    // var data = await db
    //     .rawQuery('SELECT * FROM invoices WHERE name LIKE ?', ['%$name%']) ;

    var data = await db.rawQuery(
        'SELECT * FROM invoices WHERE name LIKE ? AND deleted = ? ORDER BY id DESC',
        ['%$name%', 0]);

    List<Invoice> invoices = data.map((e) => Invoice.fromSqlite(e)).toList();

    return invoices;
  }

  Future findInvoicesByTotal(double total) async {
    // var data = await db
    //     .rawQuery('SELECT * FROM invoices WHERE total LIKE ?', ['%$total%']);

    var data = await db.rawQuery(
        'SELECT * FROM invoices WHERE total LIKE ? AND deleted = ? ORDER BY id DESC',
        ['%$total%', 0]);

    List<Invoice> invoices = data.map((e) => Invoice.fromSqlite(e)).toList();

    return invoices;
  }

  Future findInvoicesByTableNo(int tableNo) async {
    // var data = await db.rawQuery(
    //     'SELECT * FROM invoices WHERE table_no LIKE ?', ['%$tableNo%']);

    var data = await db.rawQuery(
        'SELECT * FROM invoices WHERE table_no LIKE ? AND deleted = ? ORDER BY id DESC',
        ['%$tableNo%', 0]);

    List<Invoice> invoices = data.map((e) => Invoice.fromSqlite(e)).toList();

    return invoices;
  }

  Future<int> saveInvoice(Invoice invoice, {DOCSTATUS docstatus}) async {
    String applyDiscountOn;
    double discountAmount;
    double additionalDiscountPercentage;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    applyDiscountOn = sharedPreferences.getString('apply_discount_on');

    print("::: saveInvoice ::::: discountAmount : $discountAmount");
    if (additionalDiscountPercentage != 0.0)
      print(
          "::: saveInvoice ::::: discountAmount : $additionalDiscountPercentage");
    OpeningDetails openingDetails =
        await DBOpeningDetails().getOpeningDetails();
    String offlineInvoice =
        "${openingDetails.name}${DateTime.now().millisecondsSinceEpoch}";

    if (invoice.tableNo != null) {
      await _dbTables.reserveTable(invoice.tableNo);
    }

    invoice
      ..docStatus = docstatus ?? DOCSTATUS.SAVED
      ..offlineInvoice = offlineInvoice;
    invoice..applyDiscountOnInvoice = applyDiscountOn;
    print(":::::::: invoice posting date ::::::::::::: ${invoice.postingDate}");
    print(":::: insert to invoices");

    // return await db
    //     .update('invoices', map, where: 'id = ?', whereArgs: [invoiceId]);
    // Query the table for all The Recipes.
    List<Map<String, dynamic>> maps;
    maps = await db.query('invoices',
        where: 'offline_invoice = ?', whereArgs: [offlineInvoice]);
    await Future.delayed(const Duration(milliseconds: 30), () {});

    print(' ========== >>>>>>>>>>>>>> ${maps.length} <<<<<<<<<<<<< =========');

    var now = DateTime.now();
    print("THE INSERT TIME IS :::::::::::::::::::::::::$now");

    log(" ============ invoice sql object ============");
    log(invoice.toSqlite().toString());
    if (maps.length == 0)
      return await db.insert('invoices', invoice.toSqlite());
    if (maps.length != 0) return null;
  }

  Future<void> isSynced(int invoiceId, int isSynced) async {
    var now = DateTime.now();
    print("THE SYNC TIME IS :::::::::::::::::::::::::${now}");
    print("☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️ isSynced ? ☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️️");
    print("isSynced ::::::::::::$isSynced");
    print("☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️️");
    try {
      var map = <String, dynamic>{'is_synced': isSynced};
      return await db
          .update('invoices', map, where: 'id = ?', whereArgs: [invoiceId]);
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<void> DublicateIsSynced(String offline_invoice, int isSynced) async {
    print(
        "---------------------------- DublicateIsSynced ----------------------------------");
    try {
      var map = <String, dynamic>{'is_synced': isSynced};
      return await db.update('invoices', map,
          where: 'offline_invoice = ?', whereArgs: [offline_invoice]);
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<int> getInvoicesLength() async {
    List<Invoice> invoices = [];
    final sql = '''SELECT * FROM invoices''';
    final data = await db.rawQuery(sql);
    for (final node in data) {
      final Invoice invoice = Invoice.fromSqlite(node);
      invoices.add(invoice);
    }
    return invoices.length;
  }

  Future<void> updateInvoice(Invoice invoice) async {
    if (invoice.tableNo != null) {
      await _dbTables.reserveTable(invoice.tableNo);
      await _dbTables.updateInvoiceTableNo(invoice.id, invoice.tableNo);
    }

    await updateDocStatus(invoice.docStatus, invoice.id);
    await _dbItems.deleteItemsOfInvoice(invoice.id);
    await _dbItemOptions.deleteItemsOptionsOfInvoice(invoice.id);
    await _dbTaxes.deleteTaxesOfInvoice(invoice.id);

    List<Item> items =
        invoice.itemsList.map((e) => e..invoiceId = invoice.id).toList();

    await _dbItems.addItemsToInvoice(items);

    List<ItemOption> itemsOptions = [];

    for (Item item in items) {
      for (ItemOption itemOptionOfItem
          in item.itemOptionsWith.where((e) => e.selected)) {
        ItemOption itemOption = ItemOption(
          invoiceId: invoice.id,
          itemUniqueId: item.uniqueId,
          parent: itemOptionOfItem.parent,
          itemCode: itemOptionOfItem.itemCode,
          itemName: itemOptionOfItem.itemName,
          priceListRate: itemOptionOfItem.priceListRate,
          optionWith: 1,
        );
        itemsOptions.add(itemOption);
      }
      for (ItemOption itemOptionOfItem
          in item.itemOptionsWithout.where((e) => e.selected)) {
        ItemOption itemOption = ItemOption(
          invoiceId: invoice.id,
          itemUniqueId: item.uniqueId,
          parent: itemOptionOfItem.parent,
          itemCode: itemOptionOfItem.itemCode,
          itemName: itemOptionOfItem.itemName,
          priceListRate: 0.0,
          optionWith: 0,
        );
        itemsOptions.add(itemOption);
      }
    }

    for (ItemOption itemOption in itemsOptions) {
      await DBItemOptions().addItemOptionOfInvoice(itemOption);
    }

    await _dbTaxes.saveTaxes(invoice.id, invoice);
  }

  Future<void> saveInvoiceTotal(
      int invoiceId, List<Item> items, Invoice invoice) async {
    List<SalesTaxesDetails> salestaxesDetails =
        await DBSalesTaxesDetails().getSalesTaxeDetails();

    List<ItemOption> itemOptionsWith = [];
    for (Item item in items) {
      for (ItemOption itemOption in item.itemOptionsWith) {
        itemOptionsWith.add(itemOption);
      }
    }
// debug point

    invoice..coupon_code = invoice.coupon_code;
    invoice
      ..additionalDiscountPercentage = invoice.additionalDiscountPercentage;
    invoice..discountAmount = invoice.discountAmount;
    print("inviccce ${invoice.discountAmount}");
    print('PAidTotal ::::: ${invoice.total}');
    InvoiceTotal invoiceTotal = InvoiceRepositoryRefactor().calculateInvoice(
        items, salestaxesDetails,
        discountAmount: invoice.discountAmount);
    print('PAidTotal ::::: ${invoice.total}');

    await DBInvoiceRefactor().updateInvoiceTotal(
        invoiceId, invoiceTotal.totalWithVat,
        returnTotal: invoice.total, discountAmount: invoice.discountAmount);
    print('PAidTotal ::::: ${invoice.total}');
    await DBInvoiceRefactor().updateInvoiceDiscount(
        invoiceId,
        invoice.discountAmount,
        invoice.coupon_code,
        invoice.additionalDiscountPercentage);
    print('PAidTotal ::::: ${invoice.total}');
  }

  Future updateDocStatus(DOCSTATUS docstatus, int invoiceId) async {
    return await db.update('invoices', {'doc_status': docstatus.index},
        where: 'id = ?', whereArgs: [invoiceId]);
  }

  Future<List<Invoice>> getInvoicesOfDeliveryApp(String deliveryAppName) async {
    var data = await db.rawQuery(
        'SELECT * FROM invoices WHERE customer = ? AND doc_status = ?',
        [deliveryAppName, 1]);
    // 'SELECT * FROM invoices WHERE customer = ?', [deliveryAppName]);
    List<Invoice> invoices = data.map((e) => Invoice.fromSqlite(e)).toList();
    return invoices;
  }

  Future<void> deleteInvoice(int invoiceId) async {
    await db
        .rawUpdate('UPDATE invoices SET deleted = 1 WHERE id = ?', [invoiceId]);
  }

  Future<void> deleteInvoicePermanently(int invoiceId) async {
    await db.rawQuery(
        'DELETE FROM items_of_invoices WHERE FK_item_invoice_id = ?',
        [invoiceId]);
    print("⛔️deleteInvoicePermanently⛔  1️");
    await db.rawQuery(
        'DELETE FROM items_options_of_invoices WHERE FK_item_option_invoice_id = ?',
        [invoiceId]);
    print("⛔️deleteInvoicePermanently⛔  2️");
    await db.rawQuery(
        'DELETE FROM payments_of_invoices WHERE FK_payment_invoice_id = ?',
        [invoiceId]);
    print("⛔️deleteInvoicePermanently⛔  3️");
    await db.rawQuery(
        'DELETE FROM taxes_of_invoices WHERE FK_tax_invoice_id = ?',
        [invoiceId]);
    print("⛔️deleteInvoicePermanently⛔  4️");
    await db.rawDelete('DELETE FROM invoices WHERE id = ?', [invoiceId]);
  }
}
