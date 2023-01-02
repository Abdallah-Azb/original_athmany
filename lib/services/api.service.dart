import 'dart:async';
import 'dart:io';

import 'package:app/db-operations/db.opening.details.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/customer-refactor/models/Territory.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/modules/customer-refactor/models/customer_bills.dart';
import 'package:app/modules/customer/customer.dart';
import 'package:app/modules/opening/models/profile.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/services/services.dart';
import 'package:app/services/api.interceptor.dart';
import 'package:app/services/session.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_session/flutter_session.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class ApiService {
  Dio _dio;
  String sid = '';
  ProfileService _profileService = ProfileService();

  BaseOptions options() {
    return new BaseOptions(
      connectTimeout: 1800000,
      receiveTimeout: 1800000,
    );
  }

  Future getSavedBaseUrl() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.get('base_url');
  }

  // explain
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  Dio get dio => _dio;

  ApiService._internal() {
    _dio = Dio(options());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String sessionId = await FlutterSession().get('sid') ?? "";

          _dio.interceptors.requestLock.lock();
          options.headers["cookie"] = sessionId;
          options.headers['accept'] = 'application/json';
          _dio.interceptors.requestLock.unlock();
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioError e, handler) {
          if (e.error is SocketException || e.error is TimeoutException) {
            print("No internet connection");
          }

          return handler.next(e);
        },
      ),
    );
    _dio.interceptors.add(ApiInterceptor());
  }

  setApiBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  // ping pong
  Future<dynamic> pingPong(context, {bool login = false}) async {
    try {
      final Response response = await _dio.get('/api/method/frappe.ping');
      // check sid validation only if not login
      if (!login) {
        if (response.data['session_expired'] == 1) {
          await FlutterSession().set('sid', '');
          Navigator.pushReplacementNamed(context, '/');
        }
      }
      return response.data;
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
      throw e;
    }
  }

  // check pos profile details
  Future<List<String>> checkPosProfileDetails(Profile posProfile) async {
    List<String> invalidMessages = [];
    final Map request = {"doctype": "POS Profile", "name": posProfile.value};
    var response =
        await _dio.post('/api/method/frappe.client.get', data: request);
    if (response.statusCode == 200) {
      if (response.data['message']['selling_price_list'] == null) {
        invalidMessages.add('Could not find selling price list');
      }
      if (response.data['message']['cost_center'] == null) {
        invalidMessages.add('Could not find selling cost center');
      }
    }
    return invalidMessages;
  }

  // get customers list
  Future<List<Customer>> getCustomersList() async {
    List<Customer> customers;
    try {
      var response = await _dio.get('/api/resource/Customer?filters=');
      if (response.statusCode == 200) {
        var data = CustomersModel.fromMap(response.data);
        customers = data.customers;
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('error');
      print(e);
    }
    return customers;
  }

  Future<Territory> getTerritories() async {
    Territory data;
    try {
      var response = await _dio.get('/api/resource/Territory');
      if (response.statusCode == 200) {
        data = Territory.fromJson(response.data);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
    return data;
  }

  Future<List<CustomerBill>> getCustomerBills(String customerName) async {
    Map<String, dynamic> request = {
      "doctype": "POS Invoice",
      "filters": '{"customer":"${customerName}","docstatus":1}',
      "limit": 20,
      "fields":
          '["name","grand_total","status","posting_date","posting_time","currency"]',
    };
    String api = '/api/method/frappe.desk.reportview.get_list';
    try {
      var response = await ApiService().dio.post(api, data: request);
      var data = response.data['message'] as List;
      print(data);
      return data
          .map((customerBills) => CustomerBill.fromJson(customerBills))
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

  // delete invoice from server
  Future<dynamic> deleteInvoiceFromServer(String name) async {
    dynamic data;
    try {
      var response = await _dio.delete('/api/resource/POS Invoice/$name');
      if (response.statusCode == 202) {
        data = response.data['data'];
        // print(data);
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw (e);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
    return data;
  }

  /////
  // get POS invoices
  Future<dynamic> getPOSInvoices() async {
    final User user = await DBUser().getUser();
    final ProfileDetails posProfile =
        await DBProfileDetails().getProfileDetails();
    final OpeningDetails openingDetails =
        await DBOpeningDetails().getOpeningDetails();
    final request = {
      'start': openingDetails.periodStartDate,
      'end': DateTime.now().toString(),
      'pos_profile': posProfile.name,
      'user': user.userId
    };
    // print(request);
    dynamic data;
    try {
      var response = await _dio.post(
          '/api/method/business_layer.utils.pos.sales_get_items.get_pos_invoices',
          data: request);
      if (response.statusCode == 200) {
        data = response.data['message'];
        // print(data);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('error');
      print(e.toString());
    }
    return data;
  }
}
