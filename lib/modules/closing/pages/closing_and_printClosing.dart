import 'package:app/core/utils/const.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/modules/closing/models.dart/pos.transactions.dart';
import 'package:app/modules/closing/provider/closing.provider.dart';
import 'package:app/modules/closing/repositories/repositories.dart';
import 'package:flutter/material.dart';
import '../../../core/extensions/widget_extension.dart';
class PrintClosingAndClsoing extends StatefulWidget {
  final List<PosTransaction> posTransaction;
  final double grandTotal;
  final double netTotal;
  final StockItemModel stockItem;
  PrintClosingAndClsoing(
      this.posTransaction, this.grandTotal, this.netTotal, this.stockItem);
  @override
  _PrintClosingAndClsoingState createState() => _PrintClosingAndClsoingState();
}

class _PrintClosingAndClsoingState extends State<PrintClosingAndClsoing> {
  ClosingRepository _closingRepository = ClosingRepository();
  Future closingDataFuture;
  ClosingProvider closingProvider;
  Future<ClosingData> closingData() async {
    return _closingRepository.getClosingData();
  }

  @override
  void initState() {
    super.initState();
    this.closingDataFuture = closingData();
    // context.read<ClosingProvider>().setSubmitValue(disableSubmit: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PrintClsoing(() {
                // PrintClosingInvoice();
                print("1");
              }, 'التقرير ١'),
              PrintClsoing(() {
                // PrintClosingStock();
                print("2");
              }, 'التقرير ٢'),
            ],
          ),
        ),
      ),
    );
  }

  TextButton PrintClsoing(Function func, String buttonName) {
    return TextButton(
        onPressed: func,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            )),
            backgroundColor: MaterialStateProperty.all(themeColor)),
        child: Text(
          "$buttonName",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ).paddingAllNormal())
        .paddingAll(20);
  }

  // PrintClosingInvoice() async {
  //   await ClosingRepository()
  //       .printInvoice(context, widget.posTransaction, widget.grandTotal);
  // }
  //
  // PrintClosingStock() async {
  //   await ClosingRepository().printStock(context, widget.stockItem.stockItems,
  //       widget.grandTotal, widget.netTotal);
  // }
}
