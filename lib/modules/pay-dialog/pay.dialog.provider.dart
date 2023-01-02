import 'package:app/db-operations/db.sales.taxes.details.dart';
import 'package:app/models/sales.taxes.details.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:flutter/material.dart';
import 'models/models.dart';
import 'package:provider/provider.dart';

class PayDialogProvider extends ChangeNotifier {
  double total;
  double _paidTotal = 0;
  double get paidTotal => _paidTotal;

  setPaidTotal(double paidTotal) {
    _paidTotal = paidTotal;
    // for (PaymentMethodRefactor paymentMethod in paymentMethods) {
    //   _paidTotal += double.parse(paymentMethod.payment.amountStr);
    // }
  }

  List<PaymentMethodRefactor> _paymentMethods = [];
  List<PaymentMethodRefactor> get paymentMethods => _paymentMethods;

  int _activePaymentMethod;
  int get activePaymentMethod => _activePaymentMethod;

  setActivePaymentMethod(int index, int isReturn) {
    this._activePaymentMethod = index;
    print("paidTotal :: ${paidTotal} ,,,, total ::  ${total}");

    // for return payDialog
    if (isReturn == 1) {
      this._paymentMethods[index].payment.amountStr =
          (total - getTotalOfInactivePaymentMethods()).toString();
    }
    if (paidTotal < total) {
      this._paymentMethods[index].payment.amountStr =
          (total - getTotalOfInactivePaymentMethods()).toString();
    }
    notifyListeners();
  }

  Future<double> getIinvoiceTotal(context) async {
    InvoiceProvider invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    List<SalesTaxesDetails> salestaxesDetails =
        await DBSalesTaxesDetails().getSalesTaxeDetails();
    InvoiceTotal invoiceTotal = InvoiceRepositoryRefactor().calculateInvoice(
        invoiceProvider.currentInvoice.itemsList, salestaxesDetails);
    return invoiceTotal.totalWithVat;
  }

  PayDialogProvider(
      {List<PaymentMethodRefactor> paymentMethods,
      double invoiceTotal,
      double totalAfterDiscount}) {
    print("pau pay pay ::::::: :${totalAfterDiscount}");
    this.total = invoiceTotal;
    this._paymentMethods = paymentMethods;
    this._paymentMethods.forEach((e) {
      e.payment = PaymentRefactor();
    });
  }

  bool _clearAmount = true;
  bool get clearAmount => _clearAmount;

  setClearAmount(bool state) {
    _clearAmount = state;
    notifyListeners();
  }

  String _amount;
  String get amount => _amount;

  void setAmount(String newAmount) {
    if (paymentMethods[activePaymentMethod].defaultPaymentMode == 1) {
      _amount = newAmount;
      updatePaymentAmount();
    } else if ((getTotalOfInactivePaymentMethods() + double.parse(newAmount)) <=
        total) {
      _amount = newAmount;
      updatePaymentAmount();
    }
    notifyListeners();
  }

  double getTotalOfInactivePaymentMethods() {
    List<PaymentRefactor> payments =
        paymentMethods.map((e) => e.payment).toList();
    payments.removeAt(activePaymentMethod);
    double totalPaidOfInactivePaymentMethods = 0;
    for (PaymentRefactor payment in payments) {
      totalPaidOfInactivePaymentMethods += double.parse(payment.amountStr);
    }
    return totalPaidOfInactivePaymentMethods;
  }

  updatePaymentAmount() {
    this.paymentMethods[activePaymentMethod].payment.amountStr = amount;
  }
}
