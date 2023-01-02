import 'dart:async';
import 'dart:io';

import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/auth/pages/otp.dart';
import 'package:app/modules/auth/provider/provider.dart';
import 'package:app/modules/auth/repositories/auth.repository.refactor.dart';
import 'package:app/services/api.service.dart';
import 'package:app/services/auth.service.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Submit extends StatefulWidget {
  @override
  _SubmitState createState() => _SubmitState();
}

class _SubmitState extends State<Submit> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    LoginProvider loginProvider = context.watch<LoginProvider>();
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
            color: ['', null].contains(loginProvider.accountNumber) ||
                    ['', null].contains(loginProvider.userName) ||
                    ['', null].contains(loginProvider.password)
                ? isDarkMode
                    ? Colors.white12
                    : Colors.black38
                : themeColor,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        alignment: Alignment.center,
        width: double.infinity,
        height: 56,
        child: Text(
          Localization.of(context).tr('login'),
          style: TextStyle(color: Colors.white, fontFamily: 'CairoBold'),
        ),
      ),
      onTap: () async {
        print(DateTime.now().hour);
        if (loginProvider.accountNumber == '' ||
            loginProvider.userName == '' ||
            loginProvider.password == '') {
          return;
        }
        loginProvider.setLoadingValue(true);
        submit();
      },
    );
  }

  submit() async {
    LoginProvider loginProvider = context.read<LoginProvider>();
    loginProvider.setLoadingValue(true);
    try {
      if (await validateOTP(loginProvider.userName, loginProvider.password,
              loginProvider.accountNumber) ==
          true) {
        loginProvider.setLoadingValue(true);
        navigatorToOtp(
            dataOTP, loginProvider.userName, loginProvider.accountNumber);
      } else {
        await AuthRepositoryRefactor().login(loginProvider.accountNumber,
            loginProvider.userName, loginProvider.password);

        Navigator.pushNamedAndRemoveUntil(
            context, '/opening-list', (route) => false);
      }
    } on Failure catch (f) {
      toast(Localization.of(context).tr(f.toString()), Colors.red);
    } finally {
      loginProvider.setLoadingValue(false);
    }
  }

  submitOtp() async {
    LoginProvider loginProvider = context.read<LoginProvider>();
    try {
      // await AuthRepositoryRefactor().login(loginProvider.accountNumber,
      //     loginProvider.userName, loginProvider.password);

      navigatorToOtp(
          dataOTP, loginProvider.userName, loginProvider.accountNumber);
    } on Failure catch (f) {
      toast(Localization.of(context).tr(f.toString()), Colors.red);
    } finally {
      loginProvider.setLoadingValue(false);
    }
  }

  navigatorToOtp(data, username, accountName) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(
            dataOTP: data,
            username: username,
            accountNumber: accountName,
          ),
        ));
  }

  Future<SharedPreferences> _prefs() async =>
      await SharedPreferences.getInstance();

  Future<void> _setApiBaseUrl() async {
    SharedPreferences prefs = await _prefs();
    String baseUrl = prefs.getString('base_url');
    await ApiService().setApiBaseUrl(baseUrl);
  }

  Future _saveApiBaseUrl(String baseUrl) async {
    SharedPreferences prefs = await _prefs();
    prefs.setString('base_url', baseUrl);
    await _setApiBaseUrl();
  }

  // ======================================
  AuthService _authService = AuthService();
  var dataOTP;
  Future<bool> validateOTP(
      String username, String password, accountNumber) async {
    String baseUrl = await _authService.getApiBaseUrl(accountNumber);
    await _saveApiBaseUrl(baseUrl);
    String api = "/api/method/login";
    Map<String, dynamic> request = {
      "usr": username,
      "pwd": password,
    };
    try {
      final response = await ApiService().dio.post(api, data: request);
      if (response.data['verification'] != null) {
        setState(() {
          dataOTP = response.data;
        });
        return true;
      } else {
        return false;
      }
    } on DioError catch (e) {
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
}
