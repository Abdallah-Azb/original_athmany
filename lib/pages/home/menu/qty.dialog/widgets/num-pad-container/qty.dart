import 'package:app/widget/provider/theme_provider.dart';

import '../../../../../../core/enums/type_mobile.dart';
import '../../../../../../core/utils/const.dart';
import '../../../../../../providers/type_mobile_provider.dart';
import 'package:app/pages/home/menu/qty.dialog/qty.dialog.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Qty extends StatefulWidget {
  @override
  _QtyState createState() => _QtyState();
}

class _QtyState extends State<Qty> {
  @override
  Widget build(BuildContext context) {
    QtyDialogProvider qtyDialogProvider = context.watch<QtyDialogProvider>();
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Container(
      width: typeMobile == TYPEMOBILE.TABLET ? 493 : 450,
      height: 50,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          increaseQtyBtn(),
          Container(
            width: typeMobile == TYPEMOBILE.TABLET ? 120 : 60,
            alignment: Alignment.center,
            child: FittedBox(
              child: Text(
                qtyDialogProvider.amount,
                maxLines: 1,
                style: TextStyle(
                    fontSize: typeMobile == TYPEMOBILE.TABLET ? 250 : 90,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          decreaseQtyBtn()
        ],
      ),
    );
  }

  // increase item qty button
  Widget increaseQtyBtn() {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    QtyDialogProvider qtyDialogProvider = context.read<QtyDialogProvider>();
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          int qty = int.parse(qtyDialogProvider.amount);
          qty += 1;
          qtyDialogProvider.setAmount(qty.toString());
          // this.amount = qty.toString();
          setState(() {});
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isDarkMode ? Colors.transparent : Colors.white,
          ),
        ),
        child: Text(
          '+',
          style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w100,
              height: 1.14,
              color: themeColor),
        ),
      ),
    );
  }

  // decrease item qty button
  Widget decreaseQtyBtn() {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    QtyDialogProvider qtyDialogProvider = context.read<QtyDialogProvider>();
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          int qty = int.parse(qtyDialogProvider.amount);
          qty -= 1;
          if (qty > 0) qtyDialogProvider.setAmount(qty.toString());
          // if (qty > 0) this.amount = qty.toString();
          setState(() {});
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            isDarkMode ? Colors.transparent : Colors.white,
          ),
        ),
        child: Text(
          '-',
          style: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.w100,
              height: 1.4,
              color: Colors.orange),
        ),
      ),
    );
  }
}
