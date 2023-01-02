import 'dart:async';
import 'dart:io';
import 'package:app/modules/opening/models/models.dart';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'api.service.dart';
import 'auth.service.dart';

class OpeningServiceRefactor {
  Future<List<OpeningDetails>> getOpeningsList(String userId) async {
    String api =
        "/api/method/erpnext.selling.page.point_of_sale.point_of_sale.check_opening_entry";
    Map<String, dynamic> request = {"user": userId};
    try {
      final response = await ApiService().dio.post(api, data: request);
      List data = response.data['message'];
      return data.map((e) => OpeningDetails.fromServer(e)).toList();
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

  Future<List<Company>> getCompaniesList() async {
    String api = "/api/method/frappe.desk.search.search_link";
    final request = {
      "txt": "",
      "doctype": "Company",
    };
    try {
      final response = await ApiService().dio.post(api, data: request);
      List data = response.data['results'];
      return data.map((e) => Company.fromServer(e)).toList();
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

  Future<List<Profile>> getProfilesList(Company company) async {
    String api = "/api/method/frappe.desk.search.search_link";
    final request = {
      "txt": "",
      "doctype": "POS Profile",
      "query":
          "erpnext.accounts.doctype.pos_profile.pos_profile.pos_profile_query",
      "filters": {"company": company.value}
    };
    try {
      final response = await ApiService().dio.post(api, data: request);
      List data = response.data['results'];
      print("DATA IS :$data");
      return data.map((e) => Profile.fromServer(e)).toList();
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

  Future<List<OpeningBalance>> getOpeningBalanceList(Profile profile) async {
    String api = "/api/method/frappe.client.get";
    final request = {"doctype": "POS Profile", "name": profile.value};
    try {
      final response = await ApiService().dio.post(api, data: request);
      List data = response.data['message']['payments'];
      return data.map((e) => OpeningBalance.fromServer(e)).toList();
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

  Future<OpeningDetails> createNewOpening(Company company, Profile posProfile,
      List<OpeningBalance> openingBalanceList, String userId) async {
    String api = "/api/resource/POS Opening Entry";
    List<dynamic> openingAmounts = [];
    openingBalanceList.forEach((e) {
      openingAmounts.add({
        'mode_of_payment': e.modeOfPayment,
        'opening_amount': e.openingAmount
      });
    });
    final request = {
      "docstatus": 1,
      "period_start_date": DateTime.now().toString(),
      "posting_date": DateTime.now().toString(),
      "company": company.value,
      "pos_profile": posProfile.value,
      "user": userId,
      "balance_details": openingAmounts
    };
    try {
      var response = await ApiService().dio.post(api, data: request);
      dynamic data = response.data['data'];
      return OpeningDetails(
        periodStartDate: data['period_start_date'],
        name: data['name'],
        profile: data['pos_profile'],
        company: data['company'],
      );
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      switch (e.response?.statusCode) {
        case 417:
          throw Failure("Opening already exist in this period");
          break;
        case 403:
          throw Failure("user_permissions createNewOpening funv");
          break;
      }
      throw Failure("unexpected_error");
    }
  }
}
