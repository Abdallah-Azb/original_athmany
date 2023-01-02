import 'dart:io';

import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:app/services/invoice.service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../widget/widget/loading_animation_widget.dart';
import 'num.pad.dart';
import '../../core/extensions/widget_extension.dart';
class PayDialog extends StatefulWidget {
  final Function updatePayDialogOpendValue;
  PayDialog({
    Key key,
    this.updatePayDialogOpendValue,
  }) : super(key: key);

  @override
  PayDialogState createState() => PayDialogState();
}

// get payment methods
class PayDialogState extends State<PayDialog> {
  double total;
  String baseUrl;
  String localPath;

  List<Payment> payments = [];
  int selectedPaymentMethod;
  bool isPaymentInProcess = false;

  // get payment methods
  Future paymentMethodsFuture;
  Future<List<PaymentMethod>> getPaymentMethods() async {
    await getBaseUrl();
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);

    // taxes details
    List<SalesTaxesDetails> salestaxesDetails =
        await DBSalesTaxesDetails().getSalesTaxeDetails();
    this.total = InvoiceRepositoryRefactor()
        .calculateInvoice(invoice.currentInvoice.itemsList, salestaxesDetails)
        .total;
    return DBPaymentMethod().getPaymentMethods();
  }

  Future getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.localPath = await CacheItemImageService().localPath;
    this.baseUrl = prefs.getString('base_url');
  }

  @override
  void initState() {
    this.paymentMethodsFuture = getPaymentMethods();
    super.initState();
  }

  void setAmount(String newAmount) {
    double otherPaymentCount = 0;
    Payment selectedPayment = this.payments[selectedPaymentMethod];

    this.payments.forEach((element) {
      if (element != selectedPayment) {
        otherPaymentCount += element.amount;
      }
    });

    double newAmountInDouble = double.parse(newAmount);

    if (selectedPaymentMethod != null) {
      if (newAmountInDouble + otherPaymentCount <= total) {
        this.payments[selectedPaymentMethod].amountStr = newAmount;
        this.payments[selectedPaymentMethod].amount = newAmountInDouble;
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaymentMethod>>(
        future: paymentMethodsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Container();
          if (snapshot.hasData) {
            if (this.payments.length == 0) {
              for (int i = 0; i < snapshot.data.length; i++) {
                // if (snapshot.data[i].defaultPaymentMode == 1) {
                //   this.selectedPaymentMethod = i;
                //   print(i);
                // }
                Payment payment = Payment(
                  defaultPaymentMode: snapshot.data[i].defaultPaymentMode,
                  modeOfPayment: snapshot.data[i].modeOfPayment,
                  icon: snapshot.data[i].icon,
                  type: snapshot.data[i].type,
                  account: snapshot.data[i].account,
                  amount: 0,
                  baseAmount: 0,
                  amountStr: "0",
                );
                this.payments.add(payment);
              }
            }
            return page();
          }
          return Center(
            child: LoadingAnimation(
              typeOfAnimation: "horizontalRotatingDots",
              color: themeColor,
              size: 70,
            ),
          );
        });
  }

  // page
  Widget page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [dialogCalculatorContainer(), dialoginputContainer()],
        ),
        // submit
        submit()
      ],
    );
  }

/////////////////////////////////////////
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  ///  // dialog input container
  Widget dialoginputContainer() {
    InvoiceProvider invoiceProvider = context.read<InvoiceProvider>();
    double totalPaid = 0.0;
    this.payments.forEach((p) {
      totalPaid += p.amount;
    });

    return Container(
      padding: EdgeInsets.only(left: 40, right: 40, top: 10),
      width: 493,
      height: 580,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
        topRight: Radius.circular(20),
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(top: 40),
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 80,
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      border: Border.all(color: themeColor, width: 2),
                    ),
                    child: Text(
                      totalPaid.toStringAsFixed(2),
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ))),
          paymentsTable(),
          SizedBox(
            height: 23,
          ),
          invoiceProvider.currentInvoice.customerRefactor
                      .allowDefermentOfPayment ==
                  1
              ? InkWell(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    alignment: Alignment.center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: orangeColor,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(Localization.of(context).tr('credit_pay'),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ),
                  onTap: () {
                    print('credit pay');
                  },
                )
              : Container()
        ],
      ),
    );
  }

  // input container
  Widget inputContainer() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      width: 390,
      height: 54,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black38, width: 2),
          borderRadius: BorderRadius.circular(10)),
      child: Text(
        amount == ""
            ? this
                .payments
                .firstWhere((e) => e.defaultPaymentMode == 1)
                .amount
                .toString()
            : amount,
        // amount,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  // payments table
  Widget paymentsTable() {
    return Column(
      children: [
        for (int i = 0; i < this.payments.length; i++)
          Container(
            margin: EdgeInsets.all(4),
            child: InkWell(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: this.selectedPaymentMethod == i
                          ? Colors.white
                          : Color(0xffEBEBEB),
                      borderRadius: BorderRadius.circular(20),
                      border: this.selectedPaymentMethod == i
                          ? Border.all(color: themeColor, width: 2)
                          : Border.all(color: Colors.transparent, width: 2),
                    ),
                    width: 80, height: 50,
                    child: this.payments[i].icon == null
                        ? FittedBox(
                            child: Text(
                              this.payments[i].modeOfPayment,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )

                        // ? Text(this.payments[i].modeOfPayment)
                        // : Text('asdf'),
                        : Image.file(
                            File(
                                '${this.localPath}/${this.payments[i].modeOfPayment.replaceAll(new RegExp(r"\s+\b|\b\s"), "")}.png'),
                            scale: 10,
                          ),
                    // : Image.network("$baseUrl/${this.payments[i].icon}"),
                    // : Image.asset(paymentMethos[i].icon, height: 22),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(left: 5, right: 5),
                      height: 50,
                      decoration: BoxDecoration(
                        border: this.selectedPaymentMethod == i
                            ? Border.all(color: themeColor, width: 2)
                            : Border.all(color: Colors.transparent, width: 2),
                        color: this.selectedPaymentMethod == i
                            ? Colors.white
                            : Color(0xffEBEBEB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        this.payments[i].amount.toStringAsFixed(2),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
              onTap: () {
                double paid = 0;
                this.payments.forEach((p) {
                  paid += p.amount;
                });
                double amountToReachTotal = this.total - paid;
                if (amountToReachTotal != 0) {
                  this.payments[i].amount =
                      amountToReachTotal + this.payments[i].amount;
                }

                this.selectedPaymentMethod = i;
                this.payments[selectedPaymentMethod].amountStr = "0";
                setState(() {});
              },
            ),
          )
      ],
    );
  }

//////////////////////////////////////////
  ///
  ///
  ///
  ///
  ///
  ///
  ///
  // dialog calculator container
  Widget dialogCalculatorContainer() {
    return Container(
      padding: EdgeInsets.only(top: 124, left: 38, right: 38),
      width: 420,
      height: 580,
      color: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // total
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 143,
                child: Text(
                  'Total',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 20,
                child: Text(
                  ':',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                this.total.toStringAsFixed(2),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // paid
          Row(
            children: [
              // Container(
              //   width: 143,
              //   child: Text(
              //     'Paid',
              //     style: TextStyle(fontSize: 24),
              //   ),
              // ),
              // Container(
              //   width: 20,
              //   child: Text(
              //     ':',
              //     style: TextStyle(fontSize: 24),
              //   ),
              // ),
              // Text(
              //   totalPaid.toString(),
              //   style: TextStyle(fontSize: 24),
              // ),
            ],
          ),
          // change

          NumPad(
            initialAmount: selectedPaymentMethod == null
                ? "0"
                : this.payments[selectedPaymentMethod].amountStr,
            getAmount: (String amount) {
              setAmount(amount);
            },
          )
        ],
      ),
    );
  }

  String amount = "";

  //////////////////////////////
  ///
  ///
  /// submit
  // complete order button
  Widget submit() {
    InvoiceProvider invoiceProvider = Provider.of<InvoiceProvider>(context);
    return InkWell(
      child: submitContainer(),
      onTap: disabled() || isPaymentInProcess
          ? null
          : () async {
              try {
                setState(() {
                  isPaymentInProcess = true;
                });
                print("sF");
                InvoiceProvider invoice =
                    Provider.of<InvoiceProvider>(context, listen: false);

                // await InvoiceRepositoryRefactor()
                //     .payInvoice(invoice.currentInvoice, payments);

                toast(Localization.of(context).tr('data_saved'), blueColor);
                await Future.delayed(const Duration(milliseconds: 500), () {
                  toast(Localization.of(context).tr('data_synced_with_server'),
                      themeColor);
                });
                Navigator.pop(context, true);
                invoiceProvider.printInvoice(context);
              } on DioError catch (_) {
                Navigator.pop(context, true);
                toast(Localization.of(context).tr('data_saved'), blueColor);
                await Future.delayed(const Duration(milliseconds: 500), () {
                  toast(
                      Localization.of(context)
                          .tr('check_your_internet_connection'),
                      Colors.grey);
                });
              } catch (e, stackTrace) {
                await Sentry.captureException(
                  e,
                  stackTrace: stackTrace,
                );
                print(e);
                setState(() {
                  isPaymentInProcess = false;
                });
                await toast(Localization.of(context).tr('error'), Colors.red);
              }

              // setState(() {
              //   isPaymentInProcess = true;
              // });
              // Invoice invoice = Provider.of<Invoice>(context, listen: false);
              // await InvoiceService.saveInvoice(invoice,
              //     pay: true, payments: payments);
              // Navigator.pop(context, true);

              // // bool result = await InvoiceService()
              // //     .saveInvoicePaymentsToSqliteAndCompletePayment(
              // //         context, payments, invoice.id);
              // if (invoice.tableNo != null) {
              //   await DBInvoice.releaseTable(invoice.tableNo);
              // }
              // // Navigator.pop(context, result);
            },
    );
  }

  bool disabled() {
    bool disabled = true;
    double totalPaid = 0.0;
    this.payments.forEach((p) {
      totalPaid += p.amount;
    });
    if (totalPaid >= total) disabled = false;
    return disabled;
  }

  // submit container
  Widget submitContainer() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
          color: disabled() ? Colors.grey : themeColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )),
      alignment: Alignment.center,
      width: double.infinity,
      child: isPaymentInProcess
          ? SizedBox(
              width: 40,
              height: 40,
              child: LoadingAnimation(
                typeOfAnimation: "staggeredDotsWave",
                color: themeColor,
                size: 100,
              ),
            )
          : Text(
              Localization.of(context).tr('submit_pay_dialog_button'),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ).paddingAllNormal(),
    );
  }
}
