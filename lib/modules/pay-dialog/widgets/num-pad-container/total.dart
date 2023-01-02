import 'package:app/localization/localization.dart';
import 'package:app/modules/pay-dialog/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../pay.dialog.provider.dart';

import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:nil/nil.dart';

class Total extends StatelessWidget {
  final double totalAfterDiscount;
  final int isReturn;
  const Total({Key key, this.totalAfterDiscount, this.isReturn})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    PayDialogProvider payDialogProvider = context.read<PayDialogProvider>();
    double paidTotal = 0;
    for (PaymentMethodRefactor paymentMethod
        in context.watch<PayDialogProvider>().paymentMethods) {
      paidTotal += double.parse(paymentMethod.payment.amountStr);
    }

    double change = paidTotal - payDialogProvider.total < 0
        ? 0.00
        : paidTotal - payDialogProvider.total;

    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            width: 260,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        Localization.of(context).tr('total'),
                        style: TextStyle(fontSize: 26),
                      ),
                    ),
                    Text(
                      payDialogProvider.total.toStringAsFixed(2),
                      style: TextStyle(fontSize: 26),
                    ),
                  ],
                ),
                this.isReturn == 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              Localization.of(context).tr('change'),
                              style: TextStyle(fontSize: 26),
                            ),
                          ),
                          Text(
                            change.toStringAsFixed(2),
                            style: TextStyle(fontSize: 26),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )
        // ==== Mobile ====
        : Container(
            width: MediaQuery.of(context).size.width / 1.5,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        Localization.of(context).tr('total'),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Text(
                      payDialogProvider.total.toStringAsFixed(2),
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        Localization.of(context).tr('change'),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Text(
                      change.toStringAsFixed(2),
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
