import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/pay-dialog/pay.dialog.provider.dart';
import 'package:app/modules/pay-dialog/widgets/submit.dart';
import 'package:app/modules/pay-dialog/widgets/widgets.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/toas.dart';
import '../../localization/localization.dart';
import '../../widget/provider/theme_provider.dart';
import '../pay-dialog/models/payment.method.dart';

class DiscountDialog extends StatefulWidget {
  final double invoiceTotal;
  final String applyDiscountOn;
  final double discountAmount;
  final double totalAfterDiscount;
  const DiscountDialog(
      {Key key,
      this.invoiceTotal,
      this.applyDiscountOn,
      this.discountAmount,
      this.totalAfterDiscount})
      : super(key: key);

  @override
  _DiscountDialogState createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  String applyDiscountOn;
  TextEditingController couponController = TextEditingController();
  String couponCode;
  _apply_discount_on() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    applyDiscountOn = sharedPreferences.getString('apply_discount_on');
  }

  @override
  void initState() {
    _apply_discount_on();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    Invoice invoice = context.read<InvoiceProvider>().currentInvoice;
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 4.5,
            decoration: DiscountFieldAndButtonDecoration(
                // Color(0xff1F1F1F),darkContainerColor
                isDarkMode ? darkContainerColor : Colors.grey.shade300),
            child: TextFormField(
              controller: couponController,
              decoration: InputDecoration(
                labelText: 'Discount Code',
                contentPadding: EdgeInsets.all(10.0),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
// Check if it valid
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 4.5,
                decoration: DiscountFieldAndButtonDecoration(themeColor),
                child: TextButton(
                    onPressed: () async {
                      couponCode = couponController.text;
                      setState(() {});
                      check();
                    },
                    child: Text(
                      'Save',
                      // Localization.of(context).tr('submit_pay_dialog_button'),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    )),
              ),
              invoice.coupon_code != null
                  ? Container(
                      width: 150,
                      child: TextButton(
                          onPressed: () async {
                            couponCode = null;
                            setState(() {});
                            ClearDiscount();
                          },
                          child: Text(
                            'Clear Discount',
                            // Localization.of(context).tr('submit_pay_dialog_button'),
                            style: TextStyle(color: Colors.red, fontSize: 20),
                          )),
                    )
                  : Container()
            ],
          ),
          // Submit(applyDiscountOn : widget.applyDiscountOn,discountAmount: widget.discountAmount,)
        ],
      ),
    );
  }

  BoxDecoration DiscountFieldAndButtonDecoration(Color color) {
    return BoxDecoration(color: color, borderRadius: BorderRadius.circular(10));
  }

  ClearDiscount() {
    InvoiceProvider invoiceProvider = context.read<InvoiceProvider>();
    invoiceProvider.ClearDiscount();
    Navigator.pop(context, true);
    toast('Discount has been cleared', Colors.green);
  }

  check() async {
    print(applyDiscountOn);
    print(couponCode);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('couponCode', couponController.text.trim());

    Invoice invoice = context.read<InvoiceProvider>().currentInvoice;
    InvoiceProvider invoiceProvider = context.read<InvoiceProvider>();
    double grandTotal = await invoiceProvider.getInvoiceGrandTotal(context);
    double netTotal = await invoiceProvider.getInvoiceNetTotal(context);
    if (applyDiscountOn == 'Grand Total')
      invoiceProvider.applyDiscount(context, couponController.text, grandTotal);
    if (applyDiscountOn == 'Net Total')
      invoiceProvider.applyDiscount(context, couponController.text, netTotal);
  }
}
