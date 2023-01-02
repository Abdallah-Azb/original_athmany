import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/models/coupon.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/providers/home.provider.dart';
import 'package:app/services/api.service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../db-operations/db.invoice.refactor.dart';
import 'auth.service.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceRefactorService {
  String _path = '/api/resource/POS Invoice';
  DBInvoiceRefactor _dbInvoiceRefactor = DBInvoiceRefactor();

  // Future<Response> sendInvoiceToServer(Invoice invoice) async {
  //   try {
  //     if (invoice.name == null)
  //       return await ApiService().dio.post(_path, data: invoice.toJson());
  //     else
  //       return await ApiService().dio.put(
  //             '/api/resource/POS Invoice/${invoice.name}',
  //             data: invoice.toJson(),
  //           );
  //   } on DioError catch (e) {
  //     if (e.error is SocketException)
  //       throw Failure("check_your_internet_connection");
  //     if (e.error is TimeoutException) throw Failure("time_out");
  //     switch (e.response?.statusCode) {
  //       case 404:
  //         throw Failure("incorrect_data");
  //         break;
  //     }
  //   }
  //   throw Failure("unexpected_error");
  // }

  Future<File> invoiceFile(invoiceId) async {
    String invoicesPath = await getInvoicesDirectoryPath();
    return File('$invoicesPath/$invoiceId.json');
  }

  Future<File> writeInvoice(Map json) async {
    final file = await invoiceFile(json['offline_invoice']);
    return file.writeAsString("$json");
  }

  Future<String> sendInvoiceToServer(Invoice invoice,
      {BuildContext context}) async {
    String name;
    Response response;
    if (invoice.isReturn == 1) {
      response = await ApiService().dio.post(
            _path,
            data: JsonEncoder.withIndent('  ').convert(invoice.toJson()),
          );
    } else {
      if (invoice.name == null) {
        log(" ============ invoice json object ============");
        log(invoice.toJson().toString());
        response = await ApiService().dio.post(
              _path,
              data: JsonEncoder.withIndent('  ').convert(invoice.toJson()),
            );
      } else {
        response = await ApiService().dio.put(
              '/api/resource/POS Invoice/${invoice.name}',
              data: invoice.toJson(),
            );
      }
    }
    if (response.statusCode == 200) {
      name = response.data['data']['name'];
      print("SUCCSESS SUNC!!!!!!!!! -----------");
      print(invoice.paidTotal);
      print(invoice.total);
      print(invoice.isReturn);
      await deleteInvoiceFile(invoice.toJson());
    }
    return name;
  }

  Future<String> duplicateName(String offlineInvoice) async {
    print("STATUS CODE :::: 417 , offlineInvoice :::::: ${offlineInvoice}");
    final request = {
      "offline_invoice": "${offlineInvoice}",
    };
    try {
      final response = await ApiService().dio.post(
          '/api/method/business_layer.utils.pos.pos_invoice.get_invoice_name',
          data: request);
      final name = response.data['message'];
      return name;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
  }

  Future<String> getInvoicesDirectoryPath() async {
    //Get this App Document Directory
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/invoices/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  Future<int> deleteInvoiceFile(Map json) async {
    try {
      final file = await invoiceFile(json['offline_invoice']);
      await file.delete();
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }

  Future<String> editSavedInvoice(Invoice invoice) async {
    String name;
    Response response = await ApiService().dio.put(
          '/api/resource/POS Invoice/${invoice.name}',
          data: invoice.toJson(),
        );

    if (response.statusCode == 200) {
      name = response.data['data']['name'];
    }
    return name;
  }

  Future deleteInvoice(String name) async {
    Response response =
        await ApiService().dio.delete('/api/resource/POS Invoice/$name');

    if (response.statusCode == 202) {
      return response.data['message'];
    }
  }

  Future<Coupon> checkCouponService(String couponCode) async {
    Coupon coupon = Coupon();
    Response response = await ApiService().dio.get(
          '/api/method/business_layer.utils.pos.coupon_code.apply_coupon_code?applied_code=${couponCode}',
        );

    if (response.statusCode == 200) {
      coupon.name = response.data['message']['name'];
      coupon.rateOrDiscount = response.data['message']['rate_or_discount'];
      coupon.discountPercentage =
          response.data['message']['discount_percentage'];
      coupon.discountAmount = response.data['message']['discount_amount'];
      coupon.maxAmt = response.data['message']['max_amt'];
    }
    return coupon;
  }
}
