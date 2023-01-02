import 'package:app/modules/return/return.invoice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturnInvoiceHeaderRow extends StatefulWidget {
  const ReturnInvoiceHeaderRow({Key key}) : super(key: key);

  @override
  _ReturnInvoiceHeaderRowState createState() => _ReturnInvoiceHeaderRowState();
}

class _ReturnInvoiceHeaderRowState extends State<ReturnInvoiceHeaderRow> {
  TextStyle textStyle() {
    return TextStyle(fontSize: 18);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      color: Colors.black12,
      child: Row(
        children: [
          Expanded(
            child: Center(
                child: Text(
              "Item",
              style: textStyle(),
            )),
          ),
          Expanded(
            child: Center(child: Text("Qty", style: textStyle())),
          ),
          Row(
            children: [
              Image.asset(
                'assets/return-box.png',
                color: Colors.black,
                scale: 1.2,
              ),
              SizedBox(
                width: 60,
              ),
              Container(width: 20, child: checkBox()),
            ],
          ),
          Expanded(
            child: Center(child: Text("Price", style: textStyle())),
          ),
        ],
      ),
    );
  }

  Widget checkBox() {
    return Container(
      width: 32,
      child: CheckboxListTile(
        title: Text(""),
        value: context.read<ReturnInvoiceProvider>().returnAllItems,
        onChanged: (state) {
          context.read<ReturnInvoiceProvider>().returnAllItemsState(state);
        },
        controlAffinity:
            ListTileControlAffinity.leading, //  <-- leading Checkbox
      ),
    );
  }
}
