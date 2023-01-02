import 'package:app/modules/return/models/return.model.dart';
import 'package:app/modules/return/return.invoice.dart';
import 'package:app/modules/return/widgets/widgets.dart';
import 'package:flutter/material.dart';

class NumPadContainer extends StatefulWidget {
  final ReturnItem returnItem;
  const NumPadContainer({Key key, this.returnItem}) : super(key: key);

  @override
  _NumPadContainerState createState() => _NumPadContainerState();
}

class _NumPadContainerState extends State<NumPadContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 580,
        width: 380,
        padding: EdgeInsets.only(bottom: 26),
        color: Colors.black12,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                returnItem(),
              ],
            )),
            SizedBox(height: 10),
            ReturnInvoiceUpdateQtyDialogNumPad()
          ],
        ));
  }

  Widget returnItem() {
    return Container(
      width: 260,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.returnItem.itemName,
                  style: TextStyle(fontSize: 26),
                ),
              ),
              // Text(
              //   context
              //       .read<ReturnUpdateDialogProvider>()
              //       .total
              //       .toStringAsFixed(2),
              //   style: TextStyle(fontSize: 26),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
