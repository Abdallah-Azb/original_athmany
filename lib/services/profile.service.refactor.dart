import 'dart:async';
import 'dart:io';
import 'package:app/models/models.dart';
import 'package:app/modules/customer-refactor/models/customer_bills.dart';
import 'package:app/modules/customer-refactor/models/models.dart';
import 'package:app/modules/opening/models/models.dart';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'api.service.dart';
import 'auth.service.dart';

class ProfileServiceRefactor {
  Future<ProfileDetails> getProfileDetails(
      Profile profile, Company company) async {
    String api = "/api/method/frappe.client.get";
    Map<String, dynamic> request = {
      "doctype": "POS Profile",
      "name": profile.value
    };
    try {
      final response = await ApiService().dio.post(api, data: request);
      return ProfileDetails.fromServer(response.data);
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      switch (e.response?.statusCode) {
        case 403:
          throw Failure("+user_permissions profile sevices funcv");
          break;
      }
    }
    throw Failure("unexpected_error");
  }

  // =========== IX ======================
  Future getProfileDetails2(Profile profile, Company company) async {
    String api = "/api/method/frappe.client.get";
    Map<String, dynamic> request = {
      "doctype": "POS Profile",
      "name": profile.value
    };
    try {
      final response = await ApiService().dio.post(api, data: request);
      return response.data;
    } on DioError catch (e) {
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      switch (e.response?.statusCode) {
        case 403:
          throw Failure("+user_permissions");
          break;
      }
    }
    throw Failure("unexpected_error");
  }

  Future getProfileDetailsLocation(name) async {
    String api = "/api/method/frappe.client.get";
    Map<String, dynamic> request = {"doctype": "Location", "name": name};

    try {
      print('getProfileDetailsLocation ==================== ');
      final response = await ApiService().dio.post(api, data: request);
      print('${response.data}');
      return response.data;
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      switch (e.response?.statusCode) {
        case 403:
          throw Failure("+user_permissions");
          break;
      }
    }
    throw Failure("unexpected_error");
  }
  // ==================

  Future<List<PaymentMethod>> getPaymentMethods(List paymentMethodsList) async {
    List<Future<dynamic>> paymentMethodFutures = [];
    for (dynamic paymentMethod in paymentMethodsList) {
      paymentMethodFutures.add(
          _getPaymentMethodTypeAndAccount(paymentMethod['mode_of_payment']));
    }
    try {
      List<dynamic> paymentsData = await Future.wait(paymentMethodFutures);
      return paymentsData
          .asMap()
          .entries
          .map((payment) => PaymentMethod.fromServer(
              paymentMethodsList[payment.key],
              type: payment.value['type'],
              account: payment.value['account']))
          .toList();
    } on FormatException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure("unexpected_error");
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
    }
    throw Failure("unexpected_error");
  }

  Future<dynamic> _getPaymentMethodTypeAndAccount(String modeOfPayment) async {
    String api = "/api/method/frappe.client.get";
    Map<String, dynamic> request = {
      "doctype": "Mode of Payment",
      "name": modeOfPayment
    };
    try {
      var response = await ApiService().dio.post(api, data: request);
      dynamic data = {};
      data['type'] = response.data['message']['type'];
      data['account'] =
          response.data['message']['accounts'][0]['default_account'];
      return data;
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
    throw Failure("unexpected_error");
  }

  Future<CompanyDetails> getCompanyDetails(Company company) async {
    String api = "/api/method/frappe.client.get";
    Map<String, dynamic> request = {
      "doctype": "Company",
      "name": company.value
    };
    try {
      final response = await ApiService().dio.post(api, data: request);
      return CompanyDetails.fromServer(response.data['message']);
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
    }
    throw Failure("unexpected_error");
  }

  Future<List<SalesTaxesDetails>> getSalesTaxesDetails(
      String taxesAndCharges) async {
    String api = "/api/method/frappe.client.get";
    final request = {
      "doctype": "Sales Taxes and Charges Template",
      "name": taxesAndCharges
    };
    try {
      var response = await ApiService().dio.post(api, data: request);
      var data = response.data['message']['taxes'] as List;
      return data
          .map((salesTaxDetail) => SalesTaxesDetails.fromServer(salesTaxDetail))
          .toList();
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
    }
    throw Failure("unexpected_error");
  }

  Future<Customer> getDefaultCustomer(String customerName) async {
    String api =
        '/api/resource/Customer?filters=[["customer_name","=","$customerName"]]&fields=["name","customer_name","email_id","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]';
    try {
      final response = await ApiService().dio.get(api);
      Customer customer = Customer.fromJson(response.data['data'][0]);
      customer.defaultCustomer = 1;
      return customer;
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
    }
    throw Failure("unexpected_error");
  }

  Future<List<GroupWithItems>> getItemsWithGroups(ProfileDetails profileDetails,
      {String priceList}) async {
    List<Future<List<ItemOfGroup>>> itemsGroupFutures = [];
    for (var itemGroup in profileDetails.itemGroups) {
      Future<List<ItemOfGroup>> itemsGroupFuture = _getItemsOfItemsGroup(
        itemGroup.itemGroup,
        profileDetails,
        priceList: priceList,
      );

      itemsGroupFutures.add(itemsGroupFuture);
    }
    try {
      List<List<ItemOfGroup>> data = await Future.wait(itemsGroupFutures);
      return data
          .asMap()
          .entries
          .map((e) => GroupWithItems(
                itemsGroups: profileDetails.itemGroups[e.key],
                itemOfGroup: e.value,
              ))
          .toList();
    } on FormatException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure("unexpected_error");
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
    }
    throw Failure("unexpected_error");
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
    try {
      var data = await Future.wait(itemsOfGroupFutures);

      return profileDetails.deliveryApplications
          .asMap()
          .entries
          .map((e) => DeliveryApplicationWithGroupsAndItems(
                deliveryApplication: e.value,
                groupsWithItems: data[e.key],
              ))
          .toList();
    } on FormatException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure("unexpected_error");
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
    }
    throw Failure("unexpected_error");
  }

  Future<List<ItemOfGroup>> _getItemsOfItemsGroup(
      String itemGroup, ProfileDetails profileDetails,
      {String priceList}) async {
    String api =
        "/api/method/business_layer.utils.pos.sales_get_items.get_items";
    Map<String, dynamic> request = {
      "start": 0,
      "page_length": 100000,
      "price_list": priceList ?? profileDetails.sellingPriceList,
      "item_group": itemGroup,
      "search_value": "",
      "pos_profile": profileDetails.name
    };
    try {
      var response = await ApiService().dio.post(api, data: request);
      var data = response.data['message']['items'] as List;
      print("data :${data}");
      return data
          .map(
            (e) => ItemOfGroup.fromServer(
                e, itemGroup, profileDetails.writeOffCostCenter),
          )
          .toList();
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }
}
