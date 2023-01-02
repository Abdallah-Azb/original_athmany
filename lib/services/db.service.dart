import 'dart:io';
import 'dart:math';
import 'package:app/db-operations/db.delivery.application.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/delivery.application.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'auth.service.dart';

Database db;

class DBService {
  // init database
  Future<void> initDatabase() async {
    final path = await getDatabasePath('invoices_database');
    db = await openDatabase(path,
        version: 1, onCreate: onCreate, onConfigure: onConfigure);
    // print(db);
  }

  // database log
  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>> selectQueryResult,
      int insertAndUpdateQueryResult,
      List<dynamic> params]) {
    print(functionName);
    print(sql);
    if (params != null) {
      print(params);
    }
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  // get database path
  Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);
    print(path);

    //make sure the folder exists
    if (await Directory(dirname(path)).exists()) {
      // await FlutterSession().set('sid', '');
      // await deleteDatabase(path);
    } else {
      await Directory(dirname(path)).create(recursive: true);
      print('dir created');
    }
    return path;
  }

  // configure
  onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute("PRAGMA foreign_keys = ON");
  }

  // on create
  Future<void> onCreate(Database db, int version) async {}

  //////////////////////////////////////
  ///
  ///
  /// user table
  Future<void> createLoggedInUserTable(Database db) async {
    final sql = '''CREATE TABLE user
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      sid TEXT NOT NULL,
      user_id TEXT NOT NULL,
      username TEXT NOT NULL,
      full_name TEXT NOT NULL
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// Opening details table
  Future<void> createOpeningDetailsTable(Database db) async {
    final sql = '''CREATE TABLE opening_details
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      period_start_date TEXT NOT NULL,
      name TEXT NOT NULL,
      pos_profile TEXT NOT NULL,
      company TEXT NOT NULL,
      closing_opening_name TEXT
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  // pos profile details table
  Future<void> createPOSProfileDetailsTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS pos_profile_details
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      pos_logo TEXT,
      customer TEXT,
      company TEXT,
      update_stock INTEGER,
      currency TEXT,
      tax_id TEXT,
      cost_center TEXT,
      selling_price_list TEXT,
      warehouse TEXT,
      income_account TEXT,
      total_of_tables INTEGER,
      write_off_account TEXT,
      write_off_cost_center TEXT,
      address TEXT,
      hide_total_amount INTEGER,
      rating_qr_invoice INTEGER,
      apply_discount_on TEXT
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  // delivery applications table
  Future<void> createDeliveryApplicationsTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS delivery_applications
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT,
      price_list TEXT NOT NULL,
      customer TEXT NOT NULL,
      due_date_after INTEGER NOT NULL,
      allow_payment INTEGER NOT NULL
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  // company details table
  Future<void> createCompanyDetailsTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS company_details
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      default_receivable_account TEXT,
      default_bank_account TEXT,
      default_cash_account TEXT
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  // customers table
  Future<void> createCustomersTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS customers
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      default_customer INTEGER,
      name TEXT,
      customer_name TEXT,
      customer_type TEXT,
      customer_group TEXT,
      territory TEXT,
      default_mobile TEXT,
      default_email TEXT,
      allow_deferment_of_payment INTEGER
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// item groups table
  Future<void> createItemGroupsTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS item_groups
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      item_group TEXT NOT NULL
    )''';

    await db.execute(sql);
  }

  ////////////
  ///
  /// items of group table
  Future<void> createItemsOfGroupTable(Database db,
      {String tableName = "default_price_list"}) async {
    final sql = '''CREATE TABLE IF NOT EXISTS $tableName
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      item_group TEXT NOT NULL,
      item_code TEXT NOT NULL,
      item_name TEXT NOT NULL,
      description TEXT NOT NULL,
      stock_uom TEXT NOT NULL,
      item_image TEXT,
      is_stock_item INTEGER NOT NULL,
      price_list_rate DOUBLE NOT NULL,
      currency TEXT,
      default_cost_center TEXT NOT NULL,
      actual_qty DOUBLE NOT NULL
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// item options table
  Future<void> createItemOptionsTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS item_options
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      parent TEXT NOT NULL,
      item_code TEXT NOT NULL,
      item_name TEXT NOT NULL,
      price_list_rate DOUBLE NOT NULL,
      option_with INTEGER NOT NULL
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// items options of invoices
  Future<void> createItemsOptionsOfInvoicesTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS items_options_of_invoices
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      item_unique_id TEXT NOT NULL,
      parent TEXT NOT NULL,
      item_code TEXT NOT NULL,
      item_name TEXT NOT NULL,
      price_list_rate DOUBLE NOT NULL,
      option_with INTEGER NOT NULL,
      selected TEXT,
      FK_item_option_invoice_id INT NOT NULL,
      FOREIGN KEY (FK_item_option_invoice_id) REFERENCES invoices (id) 
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// payment methods table
  Future<void> createPaymentMethodsTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS payment_methods
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      default_payment_mode INTEGER NOT NULL,
      mode_of_payment TEXT NOT NULL,
      icon TEXT,
      type TEXT NOT NULL,
      allow_in_returns INTEGER NOT NULL,
      account TEXT NOT NULL
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  // sales taxes details table
  Future<void> createSalesTaxesDetailsTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS sales_taxes_details
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      charge_type TEXT NOT NULL,
      account_head TEXT NOT NULL,
      description TEXT NOT NULL,
      rate DOUBLE NOT NULL,
      included_in_print_rate INTEGER NOT NULL
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  // tables table
  Future<void> createTablesTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS tables
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      category TEXT NOT NULL,
      no INTEGER NOT NULL,
      reserved INTEGER NOT NULL
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// invoices table
  Future<void> createInvoicesTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS invoices
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      posting_date TEXT NOT NULL,
      name TEXT,
      deleted INTEGER NOT NULL,
      doc_status INTEGER NOT NULL,
      table_no INTEGER,
      customer TEXT NOT NULL,
      delivery_application TEXT,
      total DOUBLE NOT NULL,
      invoice_reference TEXT,
      offline_invoice TEXT NOT NULL,
      is_synced INTEGER NOT NULL,
      is_return INTEGER,
      return_against TEXT,
      apply_discount_on TEXT NOT NULL,
      additional_discount_percentage DOUBLE,
      coupon_code TEXT,
      discount_amount DOUBLE
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// items of invoices table
  Future<void> createItemsOfInvoicesTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS items_of_invoices
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      unique_id TEXT NOT NULL,
      item_group TEXT NOT NULL,
      uom TEXT NOT NULL,
      stock_uom TEXT NOT NULL,
      item_code TEXT NOT NULL,
      item_name TEXT NOT NULL,
      description_section TEXT NOT NULL,
      rate DOUBLE NOT NULL,
      cost_center TEXT NOT NULL,
      qty INTEGER NOT NULL,
      FK_item_invoice_id INT NOT NULL,
      FOREIGN KEY (FK_item_invoice_id) REFERENCES invoices (id) 
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// taxes of invoices table
  Future<void> createTaxesOfInvoicesTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS taxes_of_invoices
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      charge_type TEXT NOT NULL,
      account_head TEXT NOT NULL,
      description TEXT NOT NULL,
      rate DOUBLE NOT NULL,
      tax_amount DOUBLE NOT NULL,
      total DOUBLE NOT NULL,
      tax_amount_after_discount_amount DOUBLE NOT NULL,
      base_tax_amount DOUBLE NOT NULL,
      base_total DOUBLE NOT NULL,
      base_tax_amount_after_discount_amount DOUBLE NOT NULL,
      cost_center TEXT,
      included_in_print_rate INTEGER NOT NULL,
      FK_tax_invoice_id INT NOT NULL,
      FOREIGN KEY (FK_tax_invoice_id) REFERENCES invoices (id) 
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// payments of invoices table
  Future<void> createPaymentsOfInvoicesTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS payments_of_invoices
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      default_payment_mode INTEGER NOT NULL,
      mode_of_payment TEXT NOT NULL,
      type TEXT NOT NULL,
      account TEXT NOT NULL,
      amount DOUBLE NOT NULL,
      allow_in_returns INTEGER,
      base_amount DOUBLE NOT NULL,
      FK_payment_invoice_id INT NOT NULL,
      FOREIGN KEY (FK_payment_invoice_id) REFERENCES invoices (id) 
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// accessories table
  Future<void> createAccessoriesTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS accessories
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      device_brand INTEGER NOT NULL,
      serial TEXT NOT NULL,
      device_name TEXT NOT NULL,
      ip TEXT NOT NULL,
      device_type INTEGER NOT NULL,
      connection INTEGER NOT NULL,
      device_for INTEGER NOT NULL,
      is_synced INTEGER NOT NULL,
      deleted INTEGER NOT NULL
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// Categoriesaccessories  table
  Future<void> createCategoriesAccessoriesTable(Database db) async {
    final sql = '''CREATE TABLE IF NOT EXISTS categories_of_accessories
    (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      FK_category_accessory_id INT NOT NULL,
      FK_category_group_id INT NOT NULL,
      FOREIGN KEY (FK_category_accessory_id) REFERENCES accessories (id),
      FOREIGN KEY (FK_category_group_id) REFERENCES item_groups (id)
    )''';

    await db.execute(sql);
  }

  //////////////////////////////////////
  ///
  ///
  /// drop all tables
  Future<void> dropTablesForSync(Database db,
      {bool deleteOpeningDetails = false}) async {
    try {
      print(
          " ❌ ========================== dropTablesForSync Called! ========================== ❌ ");
      if (deleteOpeningDetails) db.execute("delete from " + 'opening_details');
      await db.execute("DROP TABLE IF EXISTS pos_profile_details");
      await db.execute("DROP TABLE IF EXISTS company_details");
      await db.execute("DROP TABLE IF EXISTS customers");
      await db.execute("DROP TABLE IF EXISTS item_options");
      await db.execute("DROP TABLE IF EXISTS items_options_of_invoices");
      await db.execute("DROP TABLE IF EXISTS payment_methods");
      await db.execute("DROP TABLE IF EXISTS sales_taxes_details");
      await db.execute("DROP TABLE IF EXISTS tables");
      await db.execute("DROP TABLE IF EXISTS items_of_invoices");
      await db.execute("DROP TABLE IF EXISTS taxes_of_invoices");
      await db.execute("DROP TABLE IF EXISTS payments_of_invoices");
      await db.execute("DROP TABLE IF EXISTS invoices");
      await db.execute("DROP TABLE IF EXISTS categories_of_accessories");
      await db.execute("DROP TABLE IF EXISTS item_groups");
      await db.execute("DROP TABLE IF EXISTS accessories");
      await db.execute("DROP TABLE IF EXISTS default_price_list");
      await db.execute("DROP TABLE IF EXISTS delivery_applications");
      print(
          "❌ ========================== dropTablesForSync finish! ========================== ❌");
      // await dropDeliveryApplicationWithItems(db);
    } on DatabaseException catch (e) {
      throw Failure("database_error ::: $e");
    }
  }

  Future<void> dropAllTables(Database db) async {
    try {
      print(
          " ⛔️⛔️================= dropAllTables called ================= ⛔️⛔️");
      await db.execute("DROP TABLE IF EXISTS user");
      await db.execute("DROP TABLE IF EXISTS opening_details");
      await db.execute("DROP TABLE IF EXISTS pos_profile_details");
      await db.execute("DROP TABLE IF EXISTS company_details");
      await db.execute("DROP TABLE IF EXISTS customers");
      await db.execute("DROP TABLE IF EXISTS item_options");
      await db.execute("DROP TABLE IF EXISTS items_options_of_invoices");
      await db.execute("DROP TABLE IF EXISTS payment_methods");
      await db.execute("DROP TABLE IF EXISTS sales_taxes_details");
      await db.execute("DROP TABLE IF EXISTS tables");
      await db.execute("DROP TABLE IF EXISTS items_of_invoices");
      await db.execute("DROP TABLE IF EXISTS taxes_of_invoices");
      await db.execute("DROP TABLE IF EXISTS payments_of_invoices");
      await db.execute("DROP TABLE IF EXISTS invoices");
      // await db.execute("DROP TABLE IF EXISTS categories_of_accessories");
      // await db.execute("DROP TABLE IF EXISTS item_groups");
      // await db.execute("DROP TABLE IF EXISTS accessories");
      await db.execute("DROP TABLE IF EXISTS default_price_list");
      await dropDeliveryApplicationWithItems(db);
      print(
          " ⛔️⛔️================= dropAllTables execution finished ================= ⛔️⛔️");
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  Future<void> dropAccessoriesTables(Database db) async {
    try {
      print(
          " ⛔️⛔️================= dropAccessoriesTables called ================= ⛔️⛔️");
      await db.execute("DROP TABLE IF EXISTS categories_of_accessories");
      await db.execute("DROP TABLE IF EXISTS item_groups");
      await db.execute("DROP TABLE IF EXISTS accessories");
      print(
          " ⛔️⛔️================= dropAccessoriesTables execution finished ================= ⛔️⛔️");
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  Future<void> dropDeliveryApplicationWithItems(Database db) async {
    List<DeliveryApplication> deliveryApplications =
        await DBDeliveryApplication().getAll();

    print(" deliveryApplications.length${deliveryApplications.length}");
    deliveryApplications.forEach((d) async {
      await db.execute("DROP TABLE IF EXISTS ${d.name}");
    });
    await db.execute("DROP TABLE IF EXISTS delivery_applications");
    // await db.execute("DROP TABLE IF EXISTS item_groups");
  }
}
