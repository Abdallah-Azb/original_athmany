import 'package:app/core/enums/enums.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/core/utils/toas.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/models/models.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/pay-dialog/models/payment.method.dart';
import 'package:app/modules/pay-dialog/pay.dialog.provider.dart';
import 'package:app/modules/return/provider/return.invioce.proivder.dart';
import 'package:app/providers/home.provider.dart';
import 'package:app/res.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../invoice/models/coupon.dart';

class Submit extends StatefulWidget {
  final String applyDiscountOn;
  final double discountAmount;
  final int isReturn;
  final double percentageDiscount;
  final double totalAfterDiscount;
  final List<PaymentMethodRefactor> payments;
  const Submit(
      {Key key,
      this.applyDiscountOn,
      this.discountAmount,
      this.percentageDiscount,
      this.totalAfterDiscount,
      this.isReturn,
      this.payments})
      : super(key: key);
  // const PayDialogRefactor({Key key, this.invoiceTotal,this.applyDiscountOn}) : super(key: key);

  @override
  _SubmitState createState() => _SubmitState();
}

class _SubmitState extends State<Submit> {
  bool _submited = false;
  bool _isButttonDisable = false;

  @override
  void initState() {
    super.initState();
    // _isButttonDisable = false;
  }

  @override
  Widget build(BuildContext context) {
    double paidTotal = 0;
    for (PaymentMethodRefactor paymentMethod
        in context.watch<PayDialogProvider>().paymentMethods) {
      paidTotal += double.parse(paymentMethod.payment.amountStr);
    }
    return Container(
      height: 70,
      width: double.infinity,
      color: paidTotal >= context.read<PayDialogProvider>().total
          ? themeColor
          : Colors.black38,
      child: widget.isReturn == 1
          ? Consumer<ReturnInvoiceProvider>(
              builder: (context, returnInvoice, child) {
                return TextButton(
                  child: Text(
                    Localization.of(context).tr('submit_pay_dialog_button'),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: _isButttonDisable
                      ? null
                      : () async {
                          setState(() {
                            _isButttonDisable = true;
                          });
                          submit(paidTotal, '', widget.applyDiscountOn,
                              totalAfterDisc: widget.totalAfterDiscount,
                              isReturn: widget.isReturn);
                        },
                );
              },
            )
          : TextButton(
              onPressed: _isButttonDisable
                  ? null
                  : () async {
                      setState(() {
                        _isButttonDisable = true;
                      });
                      print(
                          "Pay Dialog has clicks and _isButttonDisable = ${_isButttonDisable} }");
                      print(
                          "Pay Dialog has clicks and _isButttonDisable = ${widget.isReturn} }");
                      submit(paidTotal, '', widget.applyDiscountOn,
                          totalAfterDisc: widget.totalAfterDiscount,
                          isReturn: widget.isReturn);
                    },
              child: Text(
                Localization.of(context).tr('submit_pay_dialog_button'),
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
    );
  }

  saveInvoiceRefactor(
      Invoice invoice, List<PaymentMethodRefactor> payments) async {
    InvoiceProvider invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);

    int invoiceId = invoice.isReturn == 1
        ? await InvoiceRepositoryRefactor()
            .saveReturnRepo(invoice, payments, context)
        : await InvoiceRepositoryRefactor()
            .saveInvoiceRefactor(invoice, payments);
    Navigator.pop(context, invoiceId);
    toast(Localization.of(context).tr('data_saved'), blueColor);
  }

  submit(double paidTotal, String printFor, String applyDiscountOn,
      {double totalAfterDisc, int isReturn}) async {
    print(
        "Pay submit :::::: ${paidTotal >= context.read<PayDialogProvider>().total}");
    if (paidTotal >= context.read<PayDialogProvider>().total) {
      try {
        print('isReturn ::: ${isReturn}');
        // Invoice invoice = context.read<ReturnInvoiceProvider>().currentInvoice;
        Invoice invoice = context.read<InvoiceProvider>().currentInvoice;
        print(
            ' invoice.customerRefactor ::::::::::::: ${invoice.customerRefactor}');
        invoice..docStatus = DOCSTATUS.PAID;
        invoice..printFor = printFor;
        invoice..applyDiscountOnInvoice = applyDiscountOn;
        print("${invoice.total}");

        List<PaymentMethodRefactor> payments = invoice.isReturn == 1
            ?
            // if the invoice type returned !
            context
                .read<PayDialogProvider>()
                .paymentMethods
                .where((e) => double.parse(e.payment.amountStr) < 0.0)
                .toList()
            : context
                .read<PayDialogProvider>()
                .paymentMethods
                .where((e) => double.parse(e.payment.amountStr) > 0.0)
                .toList();
        print('paymeeents ::::: ${payments}');
        InvoiceRepositoryRefactor _invoiceRepositoryRefactor =
            InvoiceRepositoryRefactor();
        print('invoice.coupon_code :: ${invoice.coupon_code}');
        if (invoice.coupon_code != null) {
          Coupon coupon =
              await _invoiceRepositoryRefactor.checkCoupon(invoice.coupon_code);
          if (coupon.name != null) {
            saveInvoiceRefactor(invoice, payments);
          } else {
            toast(Localization.of(context).tr('data_saved'), Colors.red);
          }
        } else {
          print(payments.length);
          saveInvoiceRefactor(invoice, payments);
        }
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        print('pay error ::::::: ${e}');
        toast(Localization.of(context).tr('error ::::: ${e}'), Colors.red);
      }
    }
    // if (!_submited) {
    //   _submited = true;
    //   setState(() {});
    //   if (paidTotal >= context.read<PayDialogProvider>().total) {
    //     try {
    //       Invoice invoice = context.read<InvoiceProvider>().currentInvoice;
    //       invoice..docStatus = DOCSTATUS.PAID;
    //       List<PaymentMethodRefactor> payments = context
    //           .read<PayDialogProvider>()
    //           .paymentMethods
    //           .where((e) => double.parse(e.payment.amountStr) > 0.0)
    //           .toList();
    //       int invoiceId = await InvoiceRepositoryRefactor()
    //           .saveInvoiceRefactor(invoice, payments);
    //       Navigator.pop(context, invoiceId);
    //       toast(Localization.of(context).tr('data_saved'), blueColor);
    //     } catch (e) {
    //       toast(Localization.of(context).tr('error'), Colors.red);
    //     }
    //   }
    // }
  }
}
