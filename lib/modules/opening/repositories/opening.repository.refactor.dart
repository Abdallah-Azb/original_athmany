import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app/db-operations/db.opening.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/models/profile.details.dart';
import 'package:app/modules/accessories/models/accessory.dart';
import 'package:app/modules/accessories/repositories/accessory.repository.dart';
import 'package:app/modules/auth/models/models.dart';
import 'package:app/modules/customer-refactor/models/models.dart';
import 'package:app/modules/invoice/models/invoice.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/opening/models/models.dart';
import 'package:app/modules/tables/models/models.dart';
import 'package:app/services/auth.service.dart';
import 'package:app/services/accessory.service.dart';
import 'package:app/services/opening.service.refactor.dart';
import 'package:app/services/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../../core/utils/session.dart';
import '../../../services/session.dart';

class OpeningRepositoryRefactor {
  OpeningServiceRefactor _openingServiceRefactor = OpeningServiceRefactor();
  DBOpeningDetails _dbOpeningDetails = DBOpeningDetails();
  DBUser _dbUser = DBUser();
  ProfileServiceRefactor _profileServiceRefactor = ProfileServiceRefactor();
  DBOpening _dbOpening = DBOpening();
  AccessoryService _deviceService = AccessoryService();
  AuthService _authService = AuthService();
  InvoiceRepositoryRefactor _invoiceRepositoryRefactor =
      InvoiceRepositoryRefactor();
  AccessoryRepository _accessoryRepository = AccessoryRepository();
  // after validating sesssion id
  // check if there is opening details in sqlite
  Future<OpeningDetails> getOpeningDetails() async {
    return _dbOpeningDetails.getOpeningDetails();
  }

  Future<User> getUser() async {
    return await _dbUser.getUser();
  }

  // if there is no opening details in sqlite
  // get openigns list from server
  Future<List<OpeningDetails>> getOpeningList() async {
    try {
      User user = await getUser();
      log('io ${user.userId}');
      return _openingServiceRefactor.getOpeningsList(user.userId);
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure("e2");
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<void> handleOpening(OpeningDetails openingDetails,
      {bool sync: false, bool cachItmesImages: false}) async {
    try {
      // await DBService().dropTablesForSync(db, deleteOpeningDetails: true);
      // await saveOpeningDetails(openingDetails);
      if (!sync) await saveOpeningDetails(openingDetails);
      FlutterSession _session = FlutterSession();
      User user = await getUser();
      Profile profile = Profile(value: openingDetails.profile, description: "");
      Company company = Company(value: openingDetails.company, description: "");
      ProfileDetails profileDetails =
          await _profileServiceRefactor.getProfileDetails(profile, company);
      print("opening name : ${openingDetails.name}");
      print("opening name : ${openingDetails.closingEntryName}");
      // CustomerGroupItem
      // CustomerGroupItem customerGroupItem = CustomerGroupItem(
      //     name: profileDetails.customerGroups[0]["name"],
      //     title: profileDetails.customerGroups[0]["customer_group"]);
      // log("customerGroupItem are : ");
      // log(customerGroupItem);
      if (profileDetails?.sellingPriceList == null)
        throw Failure("no_selling_price_list");
      if (profileDetails?.costCenter == null) throw Failure("no_const_center");
      List<PaymentMethod> paymentMethods = await _profileServiceRefactor
          .getPaymentMethods(profileDetails.payments);
      CompanyDetails companyDetails =
          await _profileServiceRefactor.getCompanyDetails(company);
      // customer groups

      String customerGroups = '';
      for (var custoemrGroup in profileDetails.customerGroups) {
        customerGroups = customerGroups + ',' + custoemrGroup['customer_group'];
      }
      log("HOW MANY GROUPS ? ::::: " + customerGroups);
      log("update stock is ::::: ${profileDetails.updateStock}");
      log("update hideTotalAmount is ::::: ${profileDetails.hideTotalAmount}");
      log("rating_qr_invoice is ::::: ${profileDetails.rating_qr_invoice}");
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString('CUSTOMER_GROUPS', customerGroups);
      _prefs.setString(
          'hide_total_amount', profileDetails.hideTotalAmount.toString());
      _prefs.setString(
          'rating_qr_invoice', profileDetails.rating_qr_invoice.toString());
      _prefs.setString(
          'apply_discount_on', profileDetails.applyDiscountOn.toString());
      log(":::::  applyDiscountOn is  :::::: ${profileDetails.applyDiscountOn}");
      _prefs.setString('update_stock', profileDetails.updateStock.toString());

      Customer defaultCustomer = await _profileServiceRefactor
          .getDefaultCustomer(profileDetails.customer);
      log("defaultCustomer");
      List<SalesTaxesDetails> salesTaxesDetails = await _profileServiceRefactor
          .getSalesTaxesDetails(profileDetails.taxesAndCharges);
      log("salesTaxesDetails");
      List<GroupWithItems> groupsWithItems =
          await _profileServiceRefactor.getItemsWithGroups(profileDetails);
      log("groupsWithItems");
      List<DeliveryApplicationWithGroupsAndItems>
          deliveryapplicationsWithGroupsAndItems = await _profileServiceRefactor
              .getDeliveryApplicationWithGroupsAndItems(profileDetails);
      // update device service
      List<Accessory> accessories =
          await _deviceService.getOrSendDeviceAccessories();
      List<TableModel> tables = [];
      final stopwatch = Stopwatch()..start();
      profileDetails.posTables.forEach((cateogry) {
        int totalOfTables = (cateogry['total_of_table']);
        List<TableModel> categoryTables = List.generate(
          totalOfTables,
          (index) => TableModel(
              no: (index - 1) + cateogry['start_number'],
              category: cateogry['category']),
        );
        for (TableModel tableModel in categoryTables) {
          tables.add(tableModel);
        }
      });
      log('doSomething() executed in ${stopwatch.elapsed}');
      OpeningModel openingModel = OpeningModel(
        paymentMethods: paymentMethods,
        companyDetails: companyDetails,
        defaultCustomer: defaultCustomer,
        salesTaxesList: salesTaxesDetails,
        deliveryApplicationWithGroupsAndItems:
            deliveryapplicationsWithGroupsAndItems,
        groupsWithItems: groupsWithItems,
        profileDetails: profileDetails,
        tables: tables,
        deliveryApplications: profileDetails.deliveryApplications,
        accessories: accessories,
      );
      print("❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌");
      print("${openingDetails.periodStartDate}");
      print("${openingDetails.company}");
      print("❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌");

      String accountNumber = _prefs.getString('account_number');
      Sentry.configureScope(
        (scope) => scope.user = SentryUser(
            id: accountNumber,
            email: user.userId,
            username: user.username,
            extras: {
              'opening start date ': '${openingDetails.periodStartDate}',
              'company': '${openingDetails.company}',
              'opening': '${openingDetails.name}'
            }),
      );
      //
      // Sentry.configureScope(
      //       (scope) => scope.user = SentryUser(id: user.userId,
      //       extras:{'opening':'${openingDetails.name}','company':'${openingDetails.name}'}),
      // );
      await DBService().dropTablesForSync(db);
      await _dbOpening.initProfileTables();
      log("::::::::::: initProfileTables ::::::::");
      await _dbOpening.initDynamicTables(openingModel);
      log("::::::::::: initDynamicTables ::::::::");
      final saveDataToTablesTime = Stopwatch()..start();
      await _dbOpening.saveDataToTables(openingModel,
          cachItmesImages: cachItmesImages);

      log("::::::::::: saveDataToTables time ::: ${saveDataToTablesTime.elapsed}");
      final stopwatch1 = Stopwatch()..start();
      await _dbOpening.cacheImages(openingModel);
      log('doSomething() executed in ${stopwatch1.elapsed}');
      await validateOpening(profileDetails.name);
      // log('doSomething() executed in ${stopwatch1.elapsed}');
    } on Failure catch (e, stackTrace) {
      log("Handle Opening error , error ::: $e");
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<void> handleSync(OpeningDetails openingDetails) async {
    try {
      await saveCompanyDetails(openingDetails.company);
      log("compnay details synced");
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> saveCompanyDetails(String companyName) async {
    Company company = Company(value: companyName, description: "");
    try {
      CompanyDetails companyDetails =
          await _profileServiceRefactor.getCompanyDetails(company);
      log(companyDetails.defaultBankAccount);
      await DBCompanyDetails().add(companyDetails);
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> saveOpeningDetails(OpeningDetails openingDetails) async {
    try {
      await _dbOpeningDetails.add(openingDetails);
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<InvalidOpeningDetails> validateOpening(String profile) async {
    List<Map<String, dynamic>> validators = [
      {
        "name": "Profile Details",
        "table": "pos_profile_details",
        "class": ProfileDetails()
      },
      {
        "name": "Company Details",
        "table": "company_details",
        "class": CompanyDetails()
      }
    ];
    List<InvalidData> invalidData = [];
    print(
        "========= validators.length validators.length ======= ${validators.length}");
    for (var index = 0; index < validators.length; index++) {
      final table = validators[index]['table'];
      try {
        final sql = '''SELECT * FROM $table''';
        final rows = await db.rawQuery(sql);
        Map<String, dynamic> data = rows[0];
        invalidData.add(InvalidData(
            title: validators[index]['name'],
            invalidItems: validators[index]['class'].validate(data)));
      } on DatabaseException catch (e, stackTrace) {
        if (e.isNoSuchTableError()) continue;
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        throw Failure("e1");
      }
    }
    // validate default customer
    try {
      Customer defaultCustomer = await DBCustomer().getDefaultCutomer();
      invalidData.add(InvalidData(
          title: "Default Customer",
          invalidItems:
              defaultCustomer == null ? ["no_default_customer"] : []));
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure("database_error");
    }

    // validate sales taxes details
    List<SalesTaxesDetails> salesTaxesDetails = [];
    try {
      final sql = '''SELECT * FROM sales_taxes_details''';
      final rows = await db.rawQuery(sql);
      for (var index = 0; index < rows.length; index++) {
        Map<String, dynamic> row = rows[index];
        if (SalesTaxesDetails().validate(row).length > 0)
          salesTaxesDetails.add(SalesTaxesDetails.fromSqlite(row));
      }
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure("database_error");
    }

    return InvalidOpeningDetails(
        profile: profile,
        invalidData: invalidData,
        salesTaxesDetails: salesTaxesDetails);
  }

  Future<void> getOpeningResumeData() async {
    print(
        "☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️☎️");
    List invoices = await ApiService().getPOSInvoices();

    invoices.forEach((i) async {
      if (i['docstatus'] == 0 &&
          i['table_number'] != null &&
          i['table_number'].isNotEmpty) {
        await DBDineInTables().reserveTable(int.parse(i['table_number']));
      }

      if (i['docstatus'] == 0) {}

      Map<String, dynamic> invoice = Invoice().fromServer(i);

      int invoiceId = await DBInvoice.addInvoiceFromServer(invoice);

      List items = i['items'];
      items.forEach((it) async {
        if (it['is_sup'] == 0) {
          Map<String, dynamic> item =
              Item().fromServer(item: it, invoiceId: invoiceId);
          await DBInvoice.addItemOfFromServer(item);
          List itemOptions = jsonDecode(it['item_options']);
          if (itemOptions.length > 0) {
            itemOptions.forEach((e) async {
              Map<String, dynamic> map = {
                'item_unique_id': e['item_unique_id'],
                'parent': e['parent'],
                'item_code': e['item_code'],
                'item_name': e['item_name'],
                'price_list_rate': e['price_list_rate'],
                'option_with': e['option_with'],
                'selected': 1,
                'FK_item_option_invoice_id': invoiceId
              };
              await DBItemOptions().addItemOptionOfInvoiceFromServer(map);
            });
          }
        }
      });

      List taxes = i['taxes'];
      taxes.forEach((t) async {
        Tax tax = Tax.fromSqlite(t);
        await DBInvoice.addTaxOfInvoice(tax, invoiceId);
      });

      List payments = i['payments'];
      payments.forEach((p) {
        Payment payment = Payment(
          defaultPaymentMode: p['default'],
          modeOfPayment: p['mode_of_payment'],
          type: p['type'],
          account: p['account'],
          amount: p['amount'],
          baseAmount: p['base_amount'],
        );
        DBInvoice.addPaymentOfInvoice(payment, invoiceId);
      });
    });
  }

  /////////////////////////////////
  ///
  ///
  /// NEW OPENING
  Future<List<Company>> getCompaniesList() async {
    try {
      return _openingServiceRefactor.getCompaniesList();
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure(e.toString());
    }
  }

  Future<List<Profile>> getProfilesList(Company company) async {
    try {
      return _openingServiceRefactor.getProfilesList(company);
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure(e.toString());
    }
  }

  Future<List<OpeningBalance>> getOpeningBalanceList(Profile profile) async {
    try {
      return _openingServiceRefactor.getOpeningBalanceList(profile);
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure(e.toString());
    }
  }

  Future<void> createNewOpening(Company company, Profile posProfile,
      List<OpeningBalance> openingBalanceList) async {
    try {
      String userId = await _authService.getUserId();
      OpeningDetails openingDetails = await _openingServiceRefactor
          .createNewOpening(company, posProfile, openingBalanceList, userId);
      await saveOpeningDetails(openingDetails);
      // await handleOpening(openingDetails);
      await handleOpening(openingDetails, cachItmesImages: true);
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure(e.toString());
    }
  }

  /////////////////////////////////
  ///
  ///
  /// SYNC OPENING
  Future<void> syncOpening({bool cachItmesImages: false}) async {
    try {
      await checkInternetAvailability();
      await syncInvoices();
      // await _syncAccessories();
      OpeningDetails openingDetails =
          await DBOpeningDetails().getOpeningDetails();
      await handleSync(openingDetails);
      // await handleOpening(openingDetails,
      //     sync: true, cachItmesImages: cachItmesImages);
      await getOpeningResumeData();
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<List<InternetAddress>> checkInternetAvailability() async {
    try {
      return await InternetAddress.lookup('www.google.com');
    } on SocketException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure("check_your_internet_connection");
    } on TimeoutException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure("time_out");
    }
  }

  Future<void> syncInvoices() async {
    try {
      log(" :::::::::::::: syncInvoices ::::::::::::::");
      _invoiceRepositoryRefactor.syncInvoices();
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<void> syncAccessories() async {
    try {
      _accessoryRepository.syncAccessories();
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }
}

class InvalidOpeningDetails {
  String profile;
  List<InvalidData> invalidData;
  List<SalesTaxesDetails> salesTaxesDetails;

  InvalidOpeningDetails(
      {this.profile, this.invalidData, this.salesTaxesDetails});
}

class InvalidData {
  String title;
  List invalidItems;

  InvalidData({this.title, this.invalidItems});
}
