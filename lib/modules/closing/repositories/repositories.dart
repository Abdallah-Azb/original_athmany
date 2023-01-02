import 'dart:async';
import 'dart:io';

import 'package:app/core/utils/toas.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/profile.details.dart';
import 'package:app/modules/auth/models/user.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/modules/closing/models.dart/paymentReconciliation.dart';
import 'package:app/modules/closing/models.dart/pos.transactions.dart';
import 'package:app/modules/closing/provider/provider.dart';
import 'package:app/modules/header/provider/header.provider.dart';
import 'package:app/modules/opening/models/opening.details.dart';
import 'package:app/services/closing.service.dart';
import 'package:app/services/print-service/print.service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../core/extensions/time_extension.dart';
import '../models.dart/closing_report.dart';

class ClosingRepository {
  ClosingService _closingService = ClosingService();

  Future<ClosingData> getClosingData() async {
    return await _closingService.getClosingData();
  }

  Future<ClosingReport> getClosingStock(String clsoingName) async {
    return await _closingService.getStockItemsByClosingName(clsoingName);
  }

  // Future<StockItemModel> getStockData() async {
  //   return await _closingService.getStockItems();
  // }

  // Future<void> printInvoice(
  //     context,
  //     List<PosTransaction> posTransaction,
  //     List<dynamic> stockItem,
  //     double grandTotal,
  //     double netTotal,
  //     List<PaymentReconciliation> payments) async {
  //   // if (!printLoading) {
  //   try {
  //     // setPrinLoading(true);
  //     // if (closingData == null) invoiceId = currentInvoice.id;
  //     await PrintService().printClosing(
  //         posTransaction, stockItem, grandTotal, netTotal, payments);
  //     // setPrinLoading(false);
  //   } catch (e, stackTrace) {
  //     await Sentry.captureException(
  //       e,
  //       stackTrace: stackTrace,
  //     );
  //     // setPrinLoading(false);
  //     print(e);
  //   }
  //   // }
  // }

  Future<void> printStock(context, ProfileDetails posProfileDetails,
      OpeningDetails openingDetails, User user, ClosingData closingData) async {
    // if (!printLoading) {
    print("printStock func in repo === ${closingData.stockItems.length}");
    try {
      // setPrinLoading(true);
      // if (closingData == null) invoiceId = currentInvoice.id;
      await PrintService()
          .printStock(closingData, posProfileDetails, openingDetails, user);
      // setPrinLoading(false);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      // setPrinLoading(false);
      print(e);
    }
    // }
  }

  Future<String> saveClosing(context, ClosingData closingData) async {
    ClosingProvider closingProvider =
        Provider.of<ClosingProvider>(context, listen: false);
    String closingName;
    if (closingData.posTransactions.length > 0) {
      closingProvider.setLoadingValue(true);
      OpeningDetails openingDetails =
          await DBOpeningDetails().getOpeningDetails();
      ProfileDetails profileDetails =
          await DBProfileDetails().getProfileDetails();
      User user = await DBUser().getUser();
      print("⏱⏱⏱⏱⏱⏱ saveClosing ⏱⏱⏱⏱⏱⏱");
      print(DateTime.now().toString().modifyFirstHour());
      Map<String, dynamic> map = {
        "docstatus": 0,
        "period_start_date": openingDetails.periodStartDate,
        "period_end_date": DateTime.now().toString().modifyFirstHour(),
        "posting_date": DateTime.now().toString().modifyFirstHour(),
        "pos_opening_entry": openingDetails.name,
        "company": profileDetails.company,
        "pos_profile": profileDetails.name,
        "user": user.userId,
        "pos_transactions":
            closingData.posTransactionstoMap(closingData.posTransactions),
        "payment_reconciliation": closingData
            .paymentReconciliationstoMap(closingData.paymentReconciliations),
        "taxes": closingData.taxes,
        "grand_total": closingData.grandTotal,
        "net_total": closingData.netTotal,
        "total_quantity": closingData.totalQuantity,
      };

      print(map['docstatus']);
      print('printing map');
      print(
          "openingDetails.closingEntryName ::: ${openingDetails.closingEntryName}");

      try {
        OpeningDetails openingDetails =
            await DBOpeningDetails().getOpeningDetails();
        if (openingDetails.closingEntryName == null) {
          dynamic data = await _closingService.saveClosingApi(map);
          if (data['name'] != null) {
            await DBOpeningDetails()
                .updateClosingEntryName(openingDetails.name, data['name']);
            closingName = await postClosing(context, data['name'], map: map);
          }
        } else {
          closingName = await postClosing(
              context, openingDetails.closingEntryName,
              map: map);
        }
        print('printing map 2 ');
      } on DioError catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        print(e.response.statusCode);
        print(e.response.data['_error_message']);
        if (e.error is SocketException || e.error is TimeoutException) {
          print('check your internet connection');
        }
        closingProvider.setLoadingValue(false);
        if (e.response.statusCode == 403) {
          // showDialog(
          //   barrierDismissible: false,
          //   context: context,
          //   builder: (BuildContext context) {
          //     return ConfirmDialog(
          //       showCancelBtn: false,
          //       bodyText: e.response.data['_error_message'],
          //       opengingWarningDialog: false,
          //       onConfirm: () async {
          //         Navigator.pop(context);
          //         closingProvider.setLoadingValue(false);
          //       },
          //     );
          //   },
          // );
        }
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        print(e);
        closingProvider.setLoadingValue(false);
        toast('Error occured', Colors.red);
      }
    }
    return closingName;
  }

  Future<String> postClosing(context, String name,
      {Map<String, dynamic> map}) async {
    print("repos postClosing called");
    ClosingProvider closingProvider =
        Provider.of<ClosingProvider>(context, listen: false);
    String closingName;
    map['docstatus'] = 1;
    try {
      dynamic data = await _closingService.postClosing(map, name);
      print("repos postClosing data ${data['name']}");
      if (data['name'] != null) {
        closingName = data['name'];
        closingProvider.setLoadingValue(false);
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.response.statusCode);
      print(e.response.data['_error_message']);
      print(e.response.data['exc_type']);
      if (e.error is SocketException || e.error is TimeoutException) {
        print('check your internet connection');
      }
      closingProvider.setLoadingValue(false);
      if (e.response.statusCode == 403) {
        // showDialog(
        //   barrierDismissible: false,
        //   context: context,
        //   builder: (BuildContext context) {
        //     return ConfirmDialog(
        //       showCancelBtn: false,
        //       bodyText: e.response.data['_error_message'],
        //       opengingWarningDialog: false,
        //       onConfirm: () async {
        //         Navigator.pop(context);
        //         closingProvider.setLoadingValue(false);
        //         setState(() {});
        //       },
        //     );
        //   },
        // );
      }
      if (e.response.statusCode == 417) {
        // print(json.decode(e.response.data['_server_messages']));
        String errorMessage = e.response.data['_server_messages'];
        bool isValuationRate = errorMessage.contains(
            new RegExp(r'Valuation Rate for the Item', caseSensitive: false));

        // showDialog(
        //   barrierDismissible: false,
        //   context: context,
        //   builder: (BuildContext context) {
        //     return ConfirmDialog(
        //       showCancelBtn: false,
        //       bodyText: isValuationRate
        //           ? '- Valuation Rate for the Item is missing, \n- Mention Valuation Rate in the Item master.'
        //           // ? e.response.data['_server_messages']
        //           : e.response.data['exc_type'],
        //       opengingWarningDialog: false,
        //       onConfirm: () async {
        //         Navigator.pop(context);
        //         closingProvider.setLoadingValue(false);
        //         setState(() {});
        //       },
        //     );
        //   },
        // );
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
      closingProvider.setLoadingValue(false);
      toast('Error occured', Colors.red);
    }
    return closingName;
  }

  Future signout(context) async {
    HeaderProvider headerProvider =
        Provider.of<HeaderProvider>(context, listen: false);

    await headerProvider.signout(context);
  }
}
