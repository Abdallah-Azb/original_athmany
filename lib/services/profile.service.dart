import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/services/api.service.dart';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cache.item.image.service.dart';

class ProfileService {
  // get POS profile details
  Future<ProfileDetails> getProfileDetails(
      Profile profile, Company company) async {
    ProfileDetails profileDetails;
    Map<String, dynamic> request = {
      "doctype": "POS Profile",
      "name": profile.value,
    };

    Response response = await ApiService()
        .dio
        .post('/api/method/frappe.client.get', data: request);

    if (response.statusCode == 200) {
      profileDetails = ProfileDetails.fromServer(response.data);
    }

    // await getPaymentMethods(data);
    // await saveCompanyDetailsToSqlite(company);
    // await saveProfileDetailsToSqlite(data);
    // await savePaymentMethodsToSqlite(data);
    // if (data['taxes_and_charges'] != null) {
    //   // await saveSalesTaxesDetailsToSqlite(data['taxes_and_charges']);
    // } else {
    //   await DBSalesTaxesDetails().dropAndSalesTaxesDetailsTable();
    // }
    // await saveItemGroupsToSqlite(data);
    // await _deviceService.saveDeviceAccessories();
    // await DBInvoice.dropAndCreateItemsOfInvoicesTable();
    // await DBInvoice.dropAndCreateInvoicesTable();
    // // await initializeTables(data['total_of_table']);

    return profileDetails;
  }

  // save profile details data in sqlite
  Future<void> saveProfileDetailsToSqlite(dynamic data) async {
    ProfileDetails posProfileDetails = ProfileDetails.fromServer(data);
    await DBProfileDetails().dropAndCreatePOSProfileDetailsTable();
    await DBProfileDetails().add(posProfileDetails);
  }

  Future<void> saveDefaultCustomerDataToSqlite(String customerName) async {
    // Customer customer = await getDefaultCustomerData(customer);
    // await DBCustomer().add(customer);
  }

  Future<List<PaymentMethod>> getPaymentMethods(dynamic data) async {
    List paymentMethods = data;
    List<Future<dynamic>> paymentMethodFutures = [];

    for (var paymentMethod in paymentMethods) {
      paymentMethodFutures.add(
          getPaymentMethodTypeAndAccount(paymentMethod['mode_of_payment']));
    }

    List<dynamic> paymentsData = await Future.wait(paymentMethodFutures);

    return paymentsData
        .asMap()
        .entries
        .map((payment) => PaymentMethod.fromServer(paymentMethods[payment.key],
            type: payment.value['type'], account: payment.value['account']))
        .toList();
  }

  // save payment methods in sqlite
  Future<void> savePaymentMethodsToSqlite(dynamic data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (data['pos_logo'] != null && data['pos_logo'] != '') {
      await CacheItemImageService().cacheImage(
          prefs.getString('base_url') + data['pos_logo'],
          // 'http://athmanytec.alfahhad.net/files/1200px-KFC_logo.svg.png',
          'invoice-logo');
    }

    await DBPaymentMethod().dropAndPaymentMethodsTable();
    List paymentMethods = data['payments'];

    paymentMethods.forEach((p) async {
      dynamic data = await getPaymentMethodTypeAndAccount(p['mode_of_payment']);

      // print(await getPaymentMethodTypeAndAccount(p['mode_of_payment']));

      PaymentMethod paymentMethod = PaymentMethod.fromServer(p,
          type: data['type'], account: data['account']);

      await DBPaymentMethod().add(paymentMethod);

      if (p['icon'] != null || p['icon'] != '') {
        await CacheItemImageService().cacheImage(
            "${prefs.getString('base_url')}/${p['icon']}",
            '${p["mode_of_payment"].replaceAll(new RegExp(r"\s+\b|\b\s"), "")}');
      }
    });

    await DBInvoice.dropAndCreateTaxesOfInvoicesTable();
    await DBInvoice.dropAndCreatePaymentsOfInvoicesTable();
  }

  // save item groups in sqlite
  Future<void> saveItemGroupsToSqlite(ProfileDetails profileDetails) async {
    // await DBItemsGroup.dropAndCreateItemGroupsTable();
    // await DBItemOfGroup().dropAndCreateItemsOfGroupTable();
    // await DBDeliveryApplication.dropAndCreateDeliveryApplicationsTable();

    // List itemGroups = profileDetails['item_groups'];
    // List deliveryApplications = profileDetails['delivery_applications'];

    // itemGroups.forEach((ig) async {
    //   // ItemsGroups itemsGroup = ItemsGroups(
    //   //   itemGroup: ig['item_group'],
    //   // );
    //   // await DBItemsGroup().add(itemsGroup);
    //   await saveItemsOfGroupToSqlite(
    //       itemsGroup.itemGroup, profileDetails['name'], profileDetails);
    // });

    // deliveryApplications.forEach((deliveryApplication) async {
    //   DeliveryApplication application =
    //       DeliveryApplication.fromJson(deliveryApplication);

    //   await DBDeliveryApplication.add(application);

    //   await DBItemOfGroup()
    //       .dropAndCreateItemsOfGroupTable(tableName: application.name);

    //   itemGroups.forEach((ig) async {
    //     ItemsGroups itemsGroup = ItemsGroups(
    //       itemGroup: ig['item_group'],
    //     );

    //     await saveItemsOfGroupToSqlite(
    //       itemsGroup.itemGroup,
    //       profileDetails,
    //       priceList: application.priceList,
    //       tableName: application.name,
    //     );
    //   });
    // });
  }

  Future<List<DeliveryApplicationWithGroupsAndItems>>
      getDeliveryApplicationWithGroupsAndItems(
          ProfileDetails profileDetails) async {
    List<Future<List<GroupWithItems>>> itemsOfGroupFutures = [];

    for (var deliveryApplication in profileDetails.deliveryApplications) {
      var future = getItemsWithGroups(profileDetails,
          priceList: deliveryApplication.priceList);

      itemsOfGroupFutures.add(future);
    }

    var data = await Future.wait(itemsOfGroupFutures);

    return profileDetails.deliveryApplications
        .asMap()
        .entries
        .map((e) => DeliveryApplicationWithGroupsAndItems(
              deliveryApplication: e.value,
              groupsWithItems: data[e.key],
            ))
        .toList();
  }

  Future<List<GroupWithItems>> getItemsWithGroups(ProfileDetails profileDetails,
      {String priceList}) async {
    List<Future<List<ItemOfGroup>>> itemsGroupFutures = [];

    for (var itemGroup in profileDetails.itemGroups) {
      Future<List<ItemOfGroup>> itemsGroupFuture = getItemsOfItemsGroup(
        itemGroup.itemGroup,
        profileDetails,
        priceList: priceList,
      );

      itemsGroupFutures.add(itemsGroupFuture);
    }

    List<List<ItemOfGroup>> data = await Future.wait(itemsGroupFutures);

    return data
        .asMap()
        .entries
        .map((e) => GroupWithItems(
              itemsGroups: profileDetails.itemGroups[e.key],
              itemOfGroup: e.value,
            ))
        .toList();
  }

  // save sales taxes details in sqlite
  Future<void> saveSalesTaxesDetailsToSqlite(String name) async {
    List data = await getSalesTaxesDetails(name);
    await DBSalesTaxesDetails().dropAndSalesTaxesDetailsTable();
    data.forEach((s) async {
      SalesTaxesDetails salesTaxeDetails = SalesTaxesDetails.fromServer(s);
      await DBSalesTaxesDetails().add(salesTaxeDetails);
    });
  }

  // get company details
  Future<CompanyDetails> getCompanyDetails(Company company) async {
    CompanyDetails companyDetails;
    final request = {"doctype": "Company", "name": company.value};

    var response = await ApiService()
        .dio
        .post('/api/method/frappe.client.get', data: request);

    if (response.statusCode == 200) {
      var data = response.data['message'];
      companyDetails = CompanyDetails.fromServer(data);
    }

    return companyDetails;
  }

  Future<Customer> getDefaultCustomerData(
      String customerName, String customerGroups) async {
    print(customerGroups);
    Customer customer;
    try {
      var response = await ApiService().dio.get(
          '/api/resource/Customer?filters=[["customer_name","=","$customerName"]]&fields=["name","customer_name","email_id","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]');

      // var response = await ApiService().dio.get(
      //     '/api/resource/Customer?filters=[["customer_group", "in", "$customerGroups"],["customer_name","like","$customerName"]]&fields=["name","customer_name","email_id","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]');
      //     // '/api/resource/Customer?filters=[["customer_group", "in", "All Customer Groups,Non Profit"],["customer_name","like","$customerName"]]&fields=["name","customer_name","email_id","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]');
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data['data'][0];
        customer = Customer.fromJson(data);
        customer.defaultCustomer = 1;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
    print(customer.toMap());
    return customer;
  }

  // get payment method type and account
  Future<dynamic> getPaymentMethodTypeAndAccount(String modeOfPayment) async {
    dynamic data;
    final request = {"doctype": "Mode of Payment", "name": modeOfPayment};

    var response = await ApiService()
        .dio
        .post('/api/method/frappe.client.get', data: request);

    if (response.statusCode == 200) {
      data = {};
      data['type'] = response.data['message']['type'];
      data['account'] =
          response.data['message']['accounts'][0]['default_account'];
    }

    return data;
  }

  // initialize tables
  Future<void> initializeTables(int totalOfTables) async {
    await DBInvoice.dropAndCreateTablesTable();
    for (int i = 0; i < totalOfTables; i++) {
      await DBInvoice.addTable(i + 1);
    }
  }

  // save items of group in sqlite
  Future<void> saveItemsOfGroupToSqlite(
      String itemGroup, ProfileDetails profileDetails,
      {String priceList, String tableName = "default_price_list"}) async {
    // String localpath = await CacheItemImageService().localPath;
    List items = await getItemsOfItemsGroup(itemGroup, profileDetails,
        priceList: priceList);

    items.forEach((i) async {
      ItemOfGroup itemOfGroup = ItemOfGroup.fromServer(
          i, itemGroup, profileDetails.writeOffCostCenter);

      if (itemOfGroup.priceListRate != null) {
        await DBItemOfGroup().add(itemOfGroup, tableName: tableName);
        // // chache items images
        // if (i['item_image'] != "" && i['item_image'] != null) {
        //   await CacheItemImageService()
        //       .cacheImage(baseUrl + i['item_image'], i['item_code']);
        // }
      }
    });
  }

  // get sales taxes details
  Future<List<SalesTaxesDetails>> getSalesTaxesDetails(String name) async {
    List<SalesTaxesDetails> salesTaxesDetails;

    final request = {
      "doctype": "Sales Taxes and Charges Template",
      "name": name // pose profile details taxes_and_charges
    };

    var response = await ApiService()
        .dio
        .post('/api/method/frappe.client.get', data: request);

    if (response.statusCode == 200) {
      var data = response.data['message']['taxes'] as List;

      salesTaxesDetails = data
          .map((salesTaxDetail) => SalesTaxesDetails.fromServer(salesTaxDetail))
          .toList();
    }

    return salesTaxesDetails;
  }

  // get items of item group
  Future<List<ItemOfGroup>> getItemsOfItemsGroup(
      String itemGroup, ProfileDetails profileDetails,
      {String priceList}) async {
    List<ItemOfGroup> itemsOfGroup;

    Map<String, dynamic> request = {
      "start": 0,
      "page_length": 100000,
      "price_list": priceList ?? profileDetails.sellingPriceList,
      "item_group": itemGroup,
      "search_value": "",
      "pos_profile": profileDetails.name
    };

    var response = await ApiService().dio.post(
        '/api/method/business_layer.utils.pos.sales_get_items.get_items',
        data: request);

    if (response.statusCode == 200) {
      var data = response.data['message']['items'];

      itemsOfGroup = (data as List)
          .map(
            (e) => ItemOfGroup.fromServer(
                e, itemGroup, profileDetails.writeOffCostCenter),
          )
          .toList();
    }

    return itemsOfGroup;
  }
}
