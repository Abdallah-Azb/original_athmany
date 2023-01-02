import 'package:app/core/enums/doc.status.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/invoice/provider/invoice.provider.dart';
import 'package:app/modules/pay-dialog/models/payment.method.dart';
import 'package:app/modules/pay-dialog/widgets/widgets.dart';
import 'package:app/widget/widget/empty_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';

import '../../pay.dialog.provider.dart';

class PaymentMethodsList extends StatefulWidget {
  final String localPath;
  final int isReturn;
  final List<PaymentMethodRefactor> paymentMethods;
  const PaymentMethodsList(
      {this.localPath, this.paymentMethods, this.isReturn});

  @override
  _PaymentMethodsListState createState() => _PaymentMethodsListState();
}

class _PaymentMethodsListState extends State<PaymentMethodsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    InvoiceProvider invoiceProvider = context.read<InvoiceProvider>();
    return typeMobile == TYPEMOBILE.TABLET
        ? Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: widget.paymentMethods.isEmpty
                  ? EmptyList(
                      message: "Return methods are empty",
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          for (int i = 0;
                              this.widget.paymentMethods.length > i;
                              i++)
                            paymentMethodRow(i, isReturn: widget.isReturn),
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
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                        Localization.of(context)
                                            .tr('credit_pay'),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  onTap: () async {
                                    int invoiceId;
                                    invoiceId = await invoiceProvider
                                        .confirmCreditPayDialog(context);
                                    if (invoiceId != null) {
                                      Navigator.pop(context);
                                      await invoiceProvider.resetAll(context);
                                      invoiceProvider.printInvoice(context,
                                          invoiceId: invoiceId);
                                      await Future.delayed(
                                          Duration(milliseconds: 600), () {
                                        invoiceProvider.sendInvoice(
                                            context, invoiceId);
                                      });
                                    }
                                  },
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                    ),
            ),
          )
        // === Mobile ===
        : Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; this.widget.paymentMethods.length > i; i++)
                    paymentMethodRow(i, isReturn: widget.isReturn)
                ],
              ),
            ),
          );
  }

  Widget paymentMethodRow(int i, {int isReturn}) {
    return InkWell(
      child: Row(children: [
        PaymentMethodIcon(
          localPath: widget.localPath,
          icon: widget.paymentMethods[i].modeOfPayment,
        ),
        SizedBox(width: 12),
        Expanded(child: PaymentMethodInput(i))
      ]),
      onTap: () {
        context.read<PayDialogProvider>().setActivePaymentMethod(i, isReturn);
        context.read<PayDialogProvider>().setClearAmount(true);
      },
    );
  }
}
