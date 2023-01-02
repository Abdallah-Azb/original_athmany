import 'package:app/core/enums/doc.status.dart';
import 'package:app/core/utils/toas.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.customer.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/db-operations/db.sales.taxes.details.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/sales.taxes.details.dart';
import 'package:app/modules/invoice/models/invoice.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/pay-dialog/pay.dialog.refactor.dart';
import 'package:app/modules/return/models/return.model.dart';
import 'package:flutter/material.dart';

import 'dart:async';

import 'package:app/modules/menuItems/menu.item.dart';
import 'package:app/modules/tables/tables.dart';

import 'package:app/providers/providers.dart';

import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ReturnInvoiceProvider extends ChangeNotifier {
  List<ReturnItem> _returnItems = [];
  List<ReturnItem> get returnItems => _returnItems;
  double returnTotal;
  Invoice currentInvoice = Invoice.empty();
  InvoiceRepositoryRefactor _invoiceRepositoryRefactor =
      InvoiceRepositoryRefactor();

  InvoiceTotal invoice_Total;

  int _newId;
  // final GlobalKey<MenuState> menuState = GlobalKey<MenuState>();

  initialReturnInvoice(context, List<ReturnItem> returnItems) async {
    this._returnItems = returnItems;
  }

  bool _returnAllItems = false;
  bool get returnAllItems => _returnAllItems;

  void returnAllItemsState(bool state) {
    _returnAllItems = state;
    if (state) {
      this
          ._returnItems
          .map((e) => {e.returnQty = e.qty * -1, e.returnAll = true})
          .toList();
    }
    if (!state)
      this
          ._returnItems
          .map((e) => {e.returnQty = 0, e.returnAll = false})
          .toList();

    notifyListeners();
  }

  void setInvoice(Invoice invoice) {
    print("::::::::: SETINVOICE :::::::::");
    print(returnTotal);
    currentInvoice.total = invoice.total * -1;
    currentInvoice.paidTotal = invoice.total * -1;
    currentInvoice.returnAgainst = invoice.name;
    currentInvoice.additionalDiscountPercentage =
        invoice.additionalDiscountPercentage;
    currentInvoice.postingDate = invoice.postingDate;
    currentInvoice.discountAmount = invoice.discountAmount;
    currentInvoice.coupon_code = invoice.coupon_code;
    currentInvoice.itemsList = invoice.itemsList;
    print(currentInvoice.itemsList);
    currentInvoice.tableNo = invoice.tableNo;
    currentInvoice.isReturn = 1;
    currentInvoice.customer = invoice.customer;
    currentInvoice.tableNo = invoice.tableNo;
    currentInvoice.isReturn = 1;
    currentInvoice.customer = invoice.customer;
    notifyListeners();
  }

  void setCustomer(String newCustomer, {bool newDeliveryApplication = false}) {
    currentInvoice.customer = newCustomer;

    if (!newDeliveryApplication) {
      currentInvoice.selectedDeliveryApplication = null;
    }
    notifyListeners();
  }

  Future<void> saveReturn(context) async {
    try {
      // print(currentInvoice.isReturn);
      int invoiceId = await _invoiceRepositoryRefactor.saveReturnRepo(
          currentInvoice, null, context);

      print('SaveReturn :::: ${invoiceId}');
      // // clear everything
      // await resetAll(context);

      // notify user about status of action
      toast(Localization.of(context).tr('data_saved'), blueColor);
      sendInvoice(context, invoiceId);
    } catch (e) {}
  }

  Future<void> sendInvoice(context, int invoiceId) async {
    try {
      var now = DateTime.now();
      print('now :${_newId}');
      Invoice invoice =
          await DBInvoiceRefactor().getCompleteInvoice(id: invoiceId);
      // convert invoiceDateTime string to DateTime Format to be able to get tge difference between now and invoiceTime
      // DateTime tempDate = new DateFormat("yyyy-MM-dd HH:mm:ss").parse(invoice.postingDate);
      // var dif = now.difference(tempDate).inMinutes;
      // print("dif dif dif dif dif dif dif dif   >>>>>>>>>>>>>> :::::;;;;;;;;;;;;;;;;;;;; ${dif}");
      // print("dpostingDate  postingDate postingDate  >>>>>>>>>>>>>> :::::;;;;;;;;;;;;;;;;;;;; ${tempDate}");
      // if (invoice.postingDate)
      await InvoiceRepositoryRefactor().sendInvoice(invoice);
      toast(Localization.of(context).tr('data_synced_with_server'), themeColor);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      toast(Localization.of(context).tr('check_your_internet_connection'),
          Colors.orange);
    }
  }

  Future<void> pay(context, bool isDarkMode, String applyDiscountOn) async {
    print(
        "pay current invoice length :::::: ${currentInvoice.itemsList.length}");
    int invoiceId;
    print("${currentInvoice.isReturn} ========= ::::::::");
    invoiceId = await openPayDialog(context, isDarkMode,
        applyDiscountOn: applyDiscountOn);
    // }
    if (invoiceId != null) {
      // await resetAll(context);
      var now = DateTime.now();
      print("PAY PAY PAY PAY PAY PAY PAY PAY     ${now}   ");
      // printInvoice(context, invoiceId: invoiceId);
      await Future.delayed(Duration(milliseconds: 600), () {
        sendInvoice(context, invoiceId);
      });
    }
  }

  Future<double> getIinvoiceTotal(context) async {
    ReturnInvoiceProvider returnInvoiceProvider =
        Provider.of<ReturnInvoiceProvider>(context, listen: false);
    List<SalesTaxesDetails> salestaxesDetails =
        await DBSalesTaxesDetails().getSalesTaxeDetails();
    print('currentInvoice.itemsList.length :::::::: ');
    print('${currentInvoice.itemsList.length}');
    InvoiceTotal invoiceTotal = InvoiceRepositoryRefactor().calculateInvoice(
        returnInvoiceProvider.currentInvoice.itemsList, salestaxesDetails);
    invoice_Total = invoiceTotal;
    notifyListeners();
    print('invoiceTotal.totalWithVat :::: ${invoiceTotal.totalWithVat}');
    return invoiceTotal.totalWithVat;
  }

  openPayDialog(context, bool isDarkMode,
      {String applyDiscountOn, double discountPercentage}) async {
    double invoiceTotal = await getIinvoiceTotal(context);
    if (currentInvoice.discountAmount != null)
      invoiceTotal = invoiceTotal - currentInvoice.discountAmount;
    print(
        "============================ ${invoice_Total} ============================");
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            width: 913,
            height: 655,
            color: isDarkMode == false ? Colors.transparent : Color(0xff1F1F1F),
            // child: PayDialog(updatePayDialogOpendValue: null),
            child: PayDialogRefactor(
                invoiceTotal: invoiceTotal,
                applyDiscountOn: applyDiscountOn,
                isReturn: 1
                // discountAmount: discountAmount,
                ),
          ),
        );
      },
    );
  }

  // Future<void> resetAll(BuildContext context, {bool logout = false}) async {
  //   MenuItemProvider menuItemProvider =
  //       Provider.of<MenuItemProvider>(context, listen: false);
  //   HomeProvider homeProvider =
  //       Provider.of<HomeProvider>(context, listen: false);
  //   DeliveryApplicationProvider deliveryApplicationProvider =
  //       Provider.of<DeliveryApplicationProvider>(context, listen: false);
  //   TablesProvider _tablesProvider =
  //       Provider.of<TablesProvider>(context, listen: false);
  //   await clearInvoice();
  //   menuItemProvider.resetItemGroup();
  //   _tablesProvider.clearTable();
  //   if (!logout) homeProvider.setMainIndex(0);
  //   if (menuState.currentState != null && !logout) {
  //     menuState.currentState.updateSelectedIndex(0);
  //   }
  //   deliveryApplicationProvider.clearDeliveryApplication();
  // }

  // clear invoice
  Future<void> clearInvoice() async {
    int newId = await InvoiceRepositoryRefactor().getNewInvoiceId();

    print("currentInvoice.total :::::::::::::::: ${currentInvoice.total}");

    currentInvoice = Invoice.empty();
    print(
        "currentInvoice.discountAmount :::::::::::::::: ${currentInvoice.discountAmount}"); // totalAfterDiscoun
    // currentInvoice..customer = posProfileDetails.customer;
    currentInvoice..customerRefactor = await DBCustomer().getDefaultCutomer();

    setNewId(newId);
  }

  void setNewId(int newId) {
    this._newId = newId;
    notifyListeners();
  }

  void updateReturnTotal(double total) {
    returnTotal = total;
    notifyListeners();
  }

  void updateReturnAllItemsState(state) {
    _returnAllItems = state;
    notifyListeners();
  }

  String _amount = "1";
  String get amount => _amount;

  void setAmount(String newAmount) {
    _amount = newAmount;
    notifyListeners();
  }

  bool _clearAmount = true;
  bool get clearAmount => _clearAmount;

  setClearAmount(bool state) {
    _clearAmount = state;
    notifyListeners();
  }
}
