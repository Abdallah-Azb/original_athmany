import 'dart:convert';
import 'dart:developer';

import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/payment.method.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/models/profile.details.dart';
import 'package:app/modules/auth/models/models.dart';
import 'package:app/modules/closing/models.dart/closing_report.dart';
import 'package:app/modules/closing/models.dart/models.dart';
import 'package:app/modules/closing/models.dart/stock_items.dart';
import 'package:app/modules/opening/models/opening.details.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../core/utils/toas.dart';
import 'services.dart';
import '../../../core/extensions/time_extension.dart';

class ClosingService {
  DBUser _dbUser = DBUser();
  DBProfileDetails _dbProfileDetails = DBProfileDetails();
  DBOpeningDetails _dbOpeningDetails = DBOpeningDetails();

  // get closing data
  // Todo pass closingName
  Future<ClosingReport> getStockItemsByClosingName(String closingName) async {
    print("⛔️⛔⛔️⛔⛔️⛔ close : $closingName ⛔️⛔⛔️⛔⛔️⛔");
    // new API for stock of closing :
    final url =
        '/api/method/business_layer.utils.pos.pos_report.pos_close_report';
    final request = {"pos_closing_entry": "$closingName"};

    try {
      final response = await ApiService().dio.post(url, data: request);
      print("res statusCode ======= ${response.statusCode}");

      if (response.statusCode != 200) {
        toast('${response.data}', Colors.red);
        return null;
      }
      print("⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔");
      print(response.data['message'].toString());
      print("⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔⛔️⛔");
      return closingReportFromJson(jsonEncode(response.data['message']));
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print("e.response ::: ${e.response}");
      throw e;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('error');
      print(e);
      throw e;
    }
  }

  Future<dynamic> getStockItems() async {
    final User user = await _dbUser.getUser();
    final ProfileDetails posProfile =
        await _dbProfileDetails.getProfileDetails();
    final OpeningDetails openingDetails =
        await _dbOpeningDetails.getOpeningDetails();
    String openingDate = openingDetails.periodStartDate.substring(0, 10);
    String TodayDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    print('opening date : -$openingDate- dateNow: $TodayDate');
    final request = {
      'doctype': 'POS Invoice',
      'fields':
          '["`tabPOS Invoice Item`.`item_name` as item_name","`tabPOS Invoice Item`.`item_code` as item_code","sum(`tabPOS Invoice Item`.`qty`) as qty","sum(`tabPOS Invoice Item`.`amount`) as base_total"]',
      'filters':
          '[["POS Invoice","creation","Between",["${openingDate}","${TodayDate}"]],["POS Invoice","pos_profile","=","${posProfile.name}"],["POS Invoice","owner","=","${user.userId}"],["POS Invoice","company","=","${posProfile.company}"],["POS Invoice","offline_invoice","like","%${openingDetails.name}%"]]',
      'view': 'Report',
      'start': '0',
      'page_length': '5000',
      'with_comment_count': 'false',
      'group_by': '`tabPOS Invoice Item`.`item_name`'
    };

    StockItemModel stockItemModel = StockItemModel();

    try {
      final response = await ApiService()
          .dio
          .post('/api/method/frappe.desk.reportview.get', data: request);
      if (response.statusCode == 200) {
        print('res ======== ${response.data['message']}');

        if (response.data['message'] == []) {
          return stockItemModel.stockItems = [];
        }
        List<dynamic> stockItemsListCheck =
            new List<dynamic>.from(response.data['message']['values']);

        if (stockItemsListCheck.isNotEmpty) {
          var r = response.data['message']['values'];
          List<dynamic> stockItemsList = new List<dynamic>.from(r);
          print('r');
          stockItemModel.stockItems = r;
        } else {
          print("its empty");
        }
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print("e.response ::: ${e.response}");
      throw e;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('error');
      print(e);
      throw e;
    }
    print(stockItemModel.stockItems);
    return stockItemModel.stockItems;
  }

  Future<ClosingData> getClosingData() async {
    getStockItems();
    final User user = await _dbUser.getUser();
    final ProfileDetails posProfile =
        await _dbProfileDetails.getProfileDetails();
    final OpeningDetails openingDetails =
        await _dbOpeningDetails.getOpeningDetails();
    final request = {
      'pos_opening_entry': openingDetails.name,
      'start': openingDetails.periodStartDate,
      'end': DateTime.now().toString().modifyFirstHour(),
      'pos_profile': posProfile.name,
      'user': user.userId
    };
    print('request info ============ ${openingDetails.name}');
    print('request info ============ ${openingDetails.periodStartDate}');
    print('request info ============ ${DateTime.now().toString()}');
    print('request info ============ ${posProfile.name}');
    print('request info ============ ${user.userId}');
    print('request info ============ -${request}-');
    ClosingData closingData = ClosingData();

    try {
      final response = await ApiService().dio.post(
          '/api/method/business_layer.utils.pos.pos_closing_entry.get_pos_invoices',
          data: request);
      print('response.statusCode ${response.statusCode}');
      if (response.statusCode == 200) {
        print('posTransactionList');
        // print(posTransactionList);
        List<PaymentReconciliation> initialedPaymentReconciliations =
            await initialPaymentReconciliation();
        List<PaymentReconciliation> updatedPaymentReconciliations =
            updatePaymentReconciliation(
                initialedpaymentReconciliations:
                    initialedPaymentReconciliations,
                jsonPaymentReconciliations:
                    response.data['message']['payment_reconciliation'] as List);
        List<PosTransaction> posTransactionList =
            (response.data['message']['pos_transactions'] as List)
                .map((e) => PosTransaction.fromServer(e))
                .toList();
        print("=============== check posTransactionList ");
        closingData.posTransactions = posTransactionList;
        closingData.paymentReconciliations = updatedPaymentReconciliations;
        closingData.taxes = response.data['message']['taxes'];
        closingData.grandTotal = response.data['message']['grand_total'];
        closingData.netTotal = response.data['message']['net_total'];
        closingData.totalQuantity = response.data['message']['total_quantity'];
        closingData.stockItems = await getStockItems();
        print('${closingData.grandTotal} ========== grand total');
      } else {
        print("WHAT ????!!!");
        print(response.data);
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print("e.response ${e.response}");
      throw e;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('error');
      print(e);
    }
    return closingData;
  }

  Future<List<PaymentReconciliation>> initialPaymentReconciliation() async {
    List<PaymentReconciliation> paymentReconciliations = [];
    List<PaymentMethod> paymentMethods =
        await DBPaymentMethod().getPaymentMethods();
    for (PaymentMethod p in paymentMethods) {
      PaymentReconciliation paymentReconciliation = PaymentReconciliation();
      paymentReconciliation.modeOfPayment = p.modeOfPayment;
      paymentReconciliation.icon = p.icon;
      paymentReconciliation.openingAmount = 0.0;
      paymentReconciliation.expectedAmount = 0.0;
      paymentReconciliations.add(paymentReconciliation);
    }
    return paymentReconciliations;
  }

  List<PaymentReconciliation> updatePaymentReconciliation(
      {List<PaymentReconciliation> initialedpaymentReconciliations,
      List<dynamic> jsonPaymentReconciliations}) {
    List<PaymentReconciliation> paymentReconciliations =
        initialedpaymentReconciliations;
    for (dynamic jsonPayRec in jsonPaymentReconciliations) {
      paymentReconciliations
          .firstWhere((e) => e.modeOfPayment == jsonPayRec['mode_of_payment'])
          .openingAmount = jsonPayRec['opening_amount'];
      paymentReconciliations
          .firstWhere((e) => e.modeOfPayment == jsonPayRec['mode_of_payment'])
          .expectedAmount = jsonPayRec['expected_amount'];
    }
    return paymentReconciliations;
  }

  ////////////////////////////////////
  ///
  ///
  ///
  ///
  ///
  // POS closing entry
  Future<dynamic> saveClosingApi(dynamic closingData) async {
    print("saveClosingApi");
    final request = closingData;
    print("closingData :::: +> $closingData");
    dynamic data;
    try {
      ApiService().dio.options.headers = {'Accept': 'application/json'};
      var response = await ApiService()
          .dio
          .post('/api/resource/POS Closing Entry', data: request);
      print("☎️☎️☎️☎️☎️saveClosingApi statusCode == ${response.statusCode}");
      print("☎️☎️☎️☎️☎️saveClosingApi data == ${response.data['data']}");
      if (response.statusCode == 200) {
        data = response.data['data'];
      } else {
        print(response.statusCode);
      }
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
    return data;
  }

  // POS post closing
  Future<dynamic> postClosing(dynamic closingData, name) async {
    final request = closingData;
    // print(JsonEncoder.withIndent('  ').convert(request));
    // print(JsonEncoder.withIndent('  ').convert(request['payment_reconciliation']));
    // print(JsonEncoder.withIndent('  ').convert(request['taxes']));
    print("service postClosing called");
    print("service postClosing closingData from params :: :${closingData}");
    dynamic data;
    try {
      ApiService().dio.options.headers = {'Accept': 'application/json'};
      print("before dio put");
      var response = await ApiService()
          .dio
          .put('/api/resource/POS Closing Entry/$name', data: request);
      print(
          "☎️☎️☎️☎️ ️service postClosing res.statuscode :: ${response.statusCode}");
      print("☎️☎️☎️☎️  service postClosing data == ${response.data['data']}");
      if (response.statusCode == 200) {
        data = response.data['data'];
      } else {
        log("error ☎️☎️☎️☎️ error");
        print(response.data);
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.response.data);
      throw e;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
      throw e;
    }
    return data;
  }
}
