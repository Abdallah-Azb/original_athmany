import 'package:app/modules/return/models/return.model.dart';
import 'package:app/modules/return/return.invoice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturnInvoiceUpdateQtyDialog extends StatefulWidget {
  final ReturnItem returnItem;
  final int returnQty;
  const ReturnInvoiceUpdateQtyDialog({Key key, this.returnItem, this.returnQty})
      : super(key: key);
  @override
  _ReturnInvoiceUpdateQtyDialogState createState() =>
      _ReturnInvoiceUpdateQtyDialogState();
}

class _ReturnInvoiceUpdateQtyDialogState
    extends State<ReturnInvoiceUpdateQtyDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReturnUpdateDialogProvider>(
      create: (context) => ReturnUpdateDialogProvider(widget.returnQty,
          itemQty: widget.returnItem.qty * -1),
      child: Consumer<ReturnUpdateDialogProvider>(
          builder: (context, model, child) => ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                              child: NumPadContainer(
                            returnItem: widget.returnItem,
                          )),
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Qty(
                                itemQty: widget.returnItem.qty,
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                    Submit()
                  ],
                ),
              )),
    );
  }
}
