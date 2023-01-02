import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app/db-operations/db.opening.details.dart';
import 'package:app/db-operations/db.profile.details.dart';
import 'package:app/db-operations/db.user.dart';
import 'package:app/models/profile.details.dart';
import 'package:app/modules/auth/models/user.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/modules/closing/models.dart/paymentReconciliation.dart';
import 'package:app/modules/opening/models/opening.details.dart';
import 'package:app/services/closing.service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

class ClosingProvider extends ChangeNotifier {
  List<PaymentReconciliation> paymentReconciliations = [];
  bool _loading = false;
  ClosingService _closingService = ClosingService();

  bool get loading => _loading;

  void setLoadingValue(bool loadingValue) async {
    this._loading = loadingValue;
    notifyListeners();
  }

  bool _submit = false;
  bool get submit => _submit;

  void setSubmitValue({bool disableSubmit}) {
    print("Hello ? ");
    if (disableSubmit != null && disableSubmit == true)
      _submit = false;
    else {
      print("Hello ?? ");
      bool canSubmit = true;
      for (PaymentReconciliation paymentReconciliation
          in paymentReconciliations) {
        if (paymentReconciliation.closingAmount == null) canSubmit = false;
      }
      print("Hello ??? ");
      _submit = canSubmit;
      notifyListeners();
    }
    print("Hello ???? ");
  }

  Future saveClosing(ClosingData closingData) async {
    log("saveClosing called");
    if (closingData.posTransactions.length > 0) {
      // Map posTransactionList =

      //     List<PosTransaction> posTransactionList =
      //   (response.data['message']['pos_transactions'] as List)
      //       .map((e) => PosTransaction.fromServer(e))
      //       .toList();

      setLoadingValue(true);
      // pageLoading = true;
      // setState(() {});
      OpeningDetails openingDetails =
          await DBOpeningDetails().getOpeningDetails();
      ProfileDetails profileDetails =
          await DBProfileDetails().getProfileDetails();
      User user = await DBUser().getUser();
      Map<String, dynamic> map = {
        "docstatus": 0,
        "period_start_date": openingDetails.periodStartDate,
        "period_end_date": DateTime.now().toString(),
        "posting_date": DateTime.now().toString(),
        "pos_opening_entry": openingDetails.name,
        "company": profileDetails.company,
        "pos_profile": profileDetails.name,
        "user": user.username,
        "pos_transactions":
            closingData.posTransactionstoMap(closingData.posTransactions),
        "payment_reconciliation": closingData
            .paymentReconciliationstoMap(closingData.paymentReconciliations),
        "taxes": closingData.taxes,
        "grand_total": closingData.grandTotal,
        "net_total": closingData.netTotal,
        "total_quantity": closingData.totalQuantity,
      };

      try {
        OpeningDetails openingDetails =
            await DBOpeningDetails().getOpeningDetails();
        if (openingDetails.closingEntryName == null) {
          dynamic data = await _closingService.saveClosingApi(map);
          if (data['name'] != null) {
            await DBOpeningDetails()
                .updateClosingEntryName(openingDetails.name, data['name']);
            await postClosing(data['name'], map: map);
          }
        } else {
          await postClosing(openingDetails.closingEntryName);
        }
      } on DioError catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        setLoadingValue(false);
        print(e.response.statusCode);
        print(e.response.data['_error_message']);
        if (e.error is SocketException || e.error is TimeoutException) {
          print('check your internet connection');
        }
        // this.pageLoading = false;
        // setState(() {});
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
          //         pageLoading = false;
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
        setLoadingValue(false);
        print(e);
        // this.pageLoading = false;
        // setState(() {});
        // toast('Error occured', Colors.red);
      }
    }
  }

  Future postClosing(String name, {Map map}) async {
    print("postClosing name => $name ");
    map['docstatus'] = 1;
    try {
      dynamic data = await _closingService.postClosing(map, name);
      if (data['name'] != null) {
        // await signout(context);
        // this.pageLoading = false;
        // setState(() {});
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
      // this.pageLoading = false;
      // setState(() {});
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
        //         pageLoading = false;
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
        //         pageLoading = false;
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
      // this.pageLoading = false;
      // setState(() {});
      // toast('Error occured', Colors.red);
    }
  }

  Future signout(context) async {
    // HeaderProvider headerProvider =
    //     Provider.of<HeaderProvider>(context, listen: false);

    // await headerProvider.signout(context);
  }
}
