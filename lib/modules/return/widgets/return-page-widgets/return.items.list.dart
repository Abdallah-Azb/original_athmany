import 'package:app/modules/return/models/return.model.dart';
import 'package:app/modules/return/pages/return.invoice.update.qty.dialog.dart';
import 'package:app/modules/return/provider/return.invioce.proivder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReturnItemsList extends StatefulWidget {
  final Function setStateReturnInvoicePage;

  const ReturnItemsList({Key key, this.setStateReturnInvoicePage})
      : super(key: key);
  @override
  _ReturnItemsListState createState() => _ReturnItemsListState();
}

class _ReturnItemsListState extends State<ReturnItemsList> {
  ReturnInvoiceProvider returnInvoiceProvider;

  @override
  void initState() {
    super.initState();
    this.returnInvoiceProvider = context.read<ReturnInvoiceProvider>();
  }

  TextStyle textStyle() {
    return TextStyle(fontSize: 18);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: Scrollbar(
        child: ListView.builder(
            itemCount: returnInvoiceProvider.returnItems.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  child: Row(
                    children: [
                      itemName(index),
                      itemQty(index),
                      Row(
                        children: [
                          returnQty(returnInvoiceProvider.returnItems[index]),
                          checkBox(index),
                        ],
                      ),
                      itemTotalPrice(index),
                    ],
                  ),
                  onTap: () {
                    returnQtyDialog(context,
                        returnInvoiceProvider.returnItems[index], index);
                  },
                ),
              );
            }),
      ),
    );
  }

  Widget returnQty(ReturnItem returnItem) {
    return Container(
      width: 100,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: returnItem.returnQty > 0 &&
                        returnItem.returnQty < returnItem.qty * -1
                    ? Colors.yellow
                    : Colors.white,
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Text(
              returnItem.returnQty.toString(),
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  returnQtyDialog(context, ReturnItem returnItem, int index) async {
    ReturnItem returnItem = returnInvoiceProvider.returnItems[index];
    int returnQty = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            width: 913,
            height: 655,
            child: ReturnInvoiceUpdateQtyDialog(
              returnItem: returnItem,
              returnQty: returnItem.returnQty,
            ),
          ),
        );
      },
    );
    if (returnQty != null) {
      returnItem.returnQty = returnQty;
      setState(() {});
      if (returnItem.returnQty > 0) returnItem.returnAll = true;
      if (returnItem.returnQty == 0) returnItem.returnAll = false;
      // if (returnItem.returnQty == returnItem.qty * -1)
      //   returnItem.returnAll = true;
      // if (returnItem.returnQty < returnItem.qty * -1)
      //   returnItem.returnAll = false;
      setState(() {
        widget.setStateReturnInvoicePage();
        print(returnQty);
      });
    }
  }

  Widget itemName(index) {
    return Expanded(
      child: Center(
          child: Text(returnInvoiceProvider.returnItems[index].itemName,
              style: textStyle())),
    );
  }

  Widget itemQty(index) {
    return Expanded(
      child: Center(
          child: Text(
              (returnInvoiceProvider.returnItems[index].qty * -1).toString(),
              style: textStyle())),
    );
  }

  Widget itemTotalPrice(index) {
    return Expanded(
      child: Center(
          child: Text(
              getItemPrice(returnInvoiceProvider.returnItems[index])
                  .toStringAsFixed(2),
              style: textStyle())),
    );
  }

  double getItemPrice(ReturnItem returnItem) {
    double optionsTotal = 0;
    for (ReturnItemOption returnItemOption
        in returnItem.returnItemOptions.where((e) => e.optionWith == 1)) {
      optionsTotal += returnItemOption.priceListRate * returnItem.returnQty;
    }
    return (returnItem.rate * returnItem.returnQty) + optionsTotal;
  }

  // double getItemPrice(ReturnItem returnItem) {
  //   double optionsTotal = 0;
  //   for (ReturnItemOption returnItemOption
  //       in returnItem.returnItemOptions.where((e) => e.optionWith == 1)) {
  //     optionsTotal += returnItemOption.priceListRate *
  //         ((returnItem.qty * -1) - returnItem.returnQty);
  //   }
  //   return returnItem.rate * ((returnItem.qty * -1) - returnItem.returnQty) +
  //       optionsTotal;
  // }

  Widget checkBox(int index) {
    ReturnInvoiceProvider returnInvoiceProvider =
        context.read<ReturnInvoiceProvider>();
    return Container(
      alignment: Alignment.center,
      width: 26,
      child: CheckboxListTile(
        title: Text(""),
        value: returnInvoiceProvider.returnItems[index].returnAll,
        onChanged: (state) {
          returnInvoiceProvider.returnItems[index].returnAll = state;
          if (state)
            returnInvoiceProvider.returnItems[index].returnQty =
                returnInvoiceProvider.returnItems[index].qty * -1;

          if (!state) returnInvoiceProvider.returnItems[index].returnQty = 0;

          setState(() {});

          if (returnInvoiceProvider.returnItems
                  .where((element) => element.returnAll)
                  .length ==
              returnInvoiceProvider.returnItems.length) {
            returnInvoiceProvider.updateReturnAllItemsState(true);
          } else {
            returnInvoiceProvider.updateReturnAllItemsState(false);
          }
        },
        controlAffinity:
            ListTileControlAffinity.leading, //  <-- leading Checkbox
      ),
    );
  }
}
