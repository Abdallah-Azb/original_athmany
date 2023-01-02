import 'package:app/core/utils/const.dart';
import 'package:app/modules/return/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Qty extends StatefulWidget {
  final int itemQty;
  const Qty({Key key, this.itemQty}) : super(key: key);
  @override
  _QtyState createState() => _QtyState();
}

class _QtyState extends State<Qty> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ReturnUpdateDialogProvider returnUpdateDialogProvider =
        context.read<ReturnUpdateDialogProvider>();
    return Container(
      width: 493,
      height: 50,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          increaseQtyBtn(),
          Container(
            width: 120,
            alignment: Alignment.center,
            child: FittedBox(
              child: Text(
                returnUpdateDialogProvider.amount,
                maxLines: 1,
                style: TextStyle(fontSize: 90, fontWeight: FontWeight.bold),
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
    ReturnUpdateDialogProvider returnUpdateDialogProvider =
        context.read<ReturnUpdateDialogProvider>();
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          int qty = int.parse(returnUpdateDialogProvider.amount);
          qty += 1;
          returnUpdateDialogProvider.setAmount(qty.toString());
          // this.amount = qty.toString();
          setState(() {});
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xffeaeaea))),
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
    ReturnUpdateDialogProvider returnUpdateDialogProvider =
        context.read<ReturnUpdateDialogProvider>();
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          int qty = int.parse(returnUpdateDialogProvider.amount);
          qty -= 1;
          if (qty >= 0) returnUpdateDialogProvider.setAmount(qty.toString());
          // if (qty > 0) this.amount = qty.toString();
          setState(() {});
        },
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xffeaeaea))),
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
