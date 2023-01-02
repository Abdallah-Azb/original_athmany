import 'dart:async';
import 'dart:io';
import 'package:app/core/utils/session.dart';
import 'package:app/services/api.service.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AuthService {
  Future<String> getApiBaseUrl(String accountNumber) async {
    String api =
        "http://athmany.tech/api/method/bench_manager.bench_manager.doctype.site_url.site_url.get_url";
    Map<String, dynamic> request = {"account_number": accountNumber};
    try {
      final response = await Dio().post(api, data: request);
      return response.data['message'];
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      switch (e.response?.statusCode) {
        case 404:
          throw Failure("incorrect_data");
          break;
      }
    }
    throw Failure("unexpected_error");
  }

  Future<void> logOut() async {
    String api = "/api/method/logout";
    try {
      final response = await ApiService().dio.post(api);
      print("${response.statusCode}");
      print("${response.realUri}");
      print("${response} for logOut API");
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      switch (e.response?.statusCode) {
        case 401:
          throw Failure("incorrect_data");
          break;
        case 500:
          throw Failure("many_wrong_login_data");
          break;
      }
      throw Failure("unexpected_error");
    }
  }

  Future<SessionData> getSessionId(String username, String password) async {
    String api = "/api/method/login";
    Map<String, dynamic> request = {
      "usr": username,
      "pwd": password,
    };
    try {
      final response = await ApiService().dio.post(api, data: request);
      final sessionId = response.headers.map['set-cookie'][0].split(';')[0];
      final fullName = response.data['full_name'];
      print(sessionId);
      print(fullName);
      return SessionData(sessionId, fullName);
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      switch (e.response?.statusCode) {
        case 401:
          throw Failure("incorrect_data");
          break;
        case 500:
          throw Failure("many_wrong_login_data");
          break;
      }
      throw Failure("unexpected_error");
    }
  }

  Future<SessionData> getSessionIdOTP(int otp, String tmpId) async {
    String api = "/api/method/login";
    Map<String, dynamic> request = {
      "otp": otp,
      "tmp_id": tmpId,
    };
    try {
      final response = await ApiService().dio.post(api, data: request);
      final sessionId = response.headers.map['set-cookie'][0].split(';')[0];
      final fullName = response.data['full_name'];
      return SessionData(sessionId, fullName);
    } on DioError catch (e) {
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      switch (e.response?.statusCode) {
        case 401:
          Fluttertoast.showToast(msg: 'Incorrect Validation Code');
          throw Failure("incorrect_data");
          break;
        case 500:
          Fluttertoast.showToast(msg: 'many wrong login data');

          throw Failure("many_wrong_login_data");
          break;
      }
      Fluttertoast.showToast(msg: 'unexpected_error');

      throw Failure("unexpected_error");
    }
  }

  Future<String> getUserId() async {
    String api = "/api/method/frappe.auth.get_logged_user";
    try {
      final response = await ApiService().dio.get(api);
      print(response.data['message']);
      return response.data['message'];
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      // switch (e.response?.statusCode) {
      //   case 403:
      //     throw Failure("incorrect_data");
      //     break;
      // }
      throw Failure("unexpected_error");
    }
  }
}

class Failure {
  // Use something like "int code;" if you want to translate error messages
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}
