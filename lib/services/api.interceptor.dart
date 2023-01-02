import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/services/invoice.refactor.service.dart';
import 'package:app/services/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../main.dart';

class ApiInterceptor extends InterceptorsWrapper {
  Session _session = Session();
  InvoiceRefactorService _invoiceRefactorService = InvoiceRefactorService();
  DBInvoiceRefactor _dbInvoiceRefactor = DBInvoiceRefactor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['accept'] = 'application/json';
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    BuildContext context = MyAppState.navigatorKey.currentContext;

    // print('err.requestOptions.runtimeType ::::::::- ${err.requestOptions.data}');
    Invoice invoice;
    log("======= err.response ${err.response.statusCode}");
    if (err.response?.statusCode == 417) {
      print("❌❌❌❌❌❌❌❌❌");
      print(err.response.data);
      print("❌❌❌❌❌❌❌❌❌");
      Map serverMessage;
      if (err.response.data['_server_messages'] != null) {
        print("❌❌❌❌❌❌❌❌❌ _server_messages not empty ❌❌❌❌❌❌❌❌❌");
        List<dynamic> _serverMessagesList =
            json.decode(err.response.data['_server_messages']) ?? [];
        serverMessage = json.decode(_serverMessagesList[0]);
      } else {
        print("❌❌❌❌❌❌❌❌❌ _server_messages is empty ❌❌❌❌❌❌❌❌❌");
        Map customMessage = {
          'message': 'Something Goes Wrong , Please reach out to Admin'
        };
        serverMessage = customMessage;
      }
      // handling duplicate
      if ((serverMessage['message'].contains('unique') ||
              serverMessage['message'].contains('فريدًا')) &&
          err.requestOptions.uri.toString().contains('POS%20Invoice')) {
        invoice = Invoice.fromJson(jsonDecode(err.requestOptions.data));
        log(invoice.offlineInvoice);
        log(":::::::::: OK :::::::::::");
        String name =
            await _invoiceRefactorService.duplicateName(invoice.offlineInvoice);
        log(name);
        await _dbInvoiceRefactor.updateInvoiceNameFromServer1(
            invoice.offlineInvoice, name);
        await _dbInvoiceRefactor.DublicateIsSynced(invoice.offlineInvoice, 1);
      }

      await showAlertMessage(context,
          title: serverMessage['title'] ?? '',
          message: serverMessage['message']);
    }

    if (err.error is SocketException || err.error is TimeoutException)
      toast(Localization.of(context).tr('check_your_internet_connection'),
          Colors.red);

    if (err.response?.statusCode == 403) {
      if (err?.response?.data != null &&
          err?.response?.data['session_expired'] != null) {
        if (err?.response?.data['session_expired'] == 1) {
          NavigatorState navigatorState = MyAppState.navigatorKey.currentState;

          await _session.clear();
          print(
              " ⛔️⛔️================= dropAllTables will called in ApiInterceptor ================= ⛔️⛔️");
          await DBService().dropAllTables(db);

          if (navigatorState != null) {
            navigatorState.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => route == null);
          }
        }
      } else
        print("err.response.data");
      showAlertMessage(context,
          message: Localization.of(context).tr('user_permissions'));
    }

    print(JsonEncoder.withIndent('  ').convert(err.response?.data));
    print(err.toString());

    return handler.next(err);
  }

  // Future showAlertMessage(context, {String message}) {
  //   return showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (dialogContext) {
  //       return ConfirmDialog(
  //         showCancelBtn: false,
  //         icon: Image.asset('assets/icons/warning.png'),
  //         onConfirm: () async {
  //           Navigator.pop(dialogContext);
  //         },
  //         bodyText: message == null
  //             ? Localization.of(context).tr('user_permissions')
  //             : message,
  //       );
  //     },
  //   );
  // }

  Future showAlertMessage(context, {String title = "", String message}) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  children: [
                    SizedBox(height: 24.0),
                    SizedBox(
                      height: 50,
                      child: Image.asset('assets/icons/warning.png'),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            html(title, context),
                            html(message, context),
                          ],
                        )),
                    SizedBox(height: 32.0),
                    Row(
                      children: [
                        _confirmBtn(context),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget html(html, context) {
    return Html(
      // bandar Fix
      data: html ?? "",
      customTextAlign: (node) => TextAlign.center,
      customTextStyle: (node, baseStyle) => TextStyle(
          locale: Localizations.localeOf(context),
          color: Colors.red,
          fontSize: 20,
          fontWeight: FontWeight.normal,
          height: 2,
          decoration: TextDecoration.none),
    );
  }

  Expanded _confirmBtn(context) {
    return Expanded(
      child: Container(
        color: themeColor,
        child: TextButton(
            child:
                Text(Localization.of(context).tr('yes'), style: btnTextStyle),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
    );
  }

  TextStyle btnTextStyle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
}
