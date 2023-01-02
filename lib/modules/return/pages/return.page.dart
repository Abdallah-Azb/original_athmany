import 'package:app/db-operations/db.payment.method.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/invoice/models/invoice.dart';
import 'package:app/modules/pay-dialog/models/payment.method.dart';
import 'package:app/modules/return/models/return.model.dart';
import 'package:app/res.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:app/services/services.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/const.dart';
import '../../../widget/widget/loading_animation_widget.dart';
import '../../invoice/provider/invoice.provider.dart';
import '../return.invoice.dart';

class ReturnPage extends StatefulWidget {
  Invoice invoice;
  ReturnPage({this.invoice});
  @override
  _ReturnPageState createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  Future returnInvoiceFuture;
  Future paymentMethodsFuture;
  String applyDiscountOn;
  DBPaymentMethod _dbPaymentMethod = DBPaymentMethod();
  String localPath;
  List<PaymentMethodRefactor> payments;
  TextStyle textStyle() {
    return TextStyle(fontSize: 18);
  }

  _getApplyDiscountOn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    applyDiscountOn = sharedPreferences.getString('apply_discount_on');
  }

  Future<List<PaymentMethodRefactor>> _getPaymentsMethods() async {
    this.localPath = await CacheItemImageService().localPath;
    payments = await _dbPaymentMethod.getPaymentMethodsRefactor(isReturn: 1);
    return payments;
  }

  @override
  void initState() {
    super.initState();
    _getApplyDiscountOn();
    _getPaymentsMethods();
    this.returnInvoiceFuture =
        ReturnService().getReturnInvoice(widget.invoice.name);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      progressIndicator: LoadingAnimation(
        typeOfAnimation: "staggeredDotsWave",
        color: themeColor,
        size: 100,
      ),
      isLoading: context.watch<InvoiceProvider>().isReturnLoading,
      child: ChangeNotifierProvider<ReturnInvoiceProvider>(
        create: (context) => ReturnInvoiceProvider(),
        child: Consumer<ReturnInvoiceProvider>(
          builder: (context, model, child) => Scaffold(
            appBar: AppBar(
              title: Text("فاتورة مرتجع"),
            ),
            body: FutureBuilder<ReturnInvoice>(
              future: returnInvoiceFuture,
              builder: (BuildContext context,
                  AsyncSnapshot<ReturnInvoice> snapshot) {
                if (snapshot.hasData) {
                  context
                      .read<ReturnInvoiceProvider>()
                      .initialReturnInvoice(context, snapshot.data.returnItems);
                  return Column(
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          ReturnInvoiceName(snapshot.data.name),
                          ReturnInvoiceHeaderRow(),
                          ReturnItemsList(
                              setStateReturnInvoicePage: updateStte),
                        ],
                      )),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          children: [
                            ReturnInvoiceFotter(
                                salestaxesDetails:
                                    snapshot.data.salestaxesDetails),
                            SafeArea(
                                child: payments.isEmpty
                                    ? Container(
                                        width: double.infinity,
                                        child: TextButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black38)),
                                          onPressed: () {  },
                                          child: Text(
                                            Localization.of(context)
                                                .tr('return_submit_disable'),
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      )
                                    : ReturnSubmit(
                                        data: snapshot.data,
                                        context: context,
                                        invoice: widget.invoice,
                                        applyDiscountOn: applyDiscountOn)),
                          ],
                        ),
                      )
                    ],
                  );
                }
                return Center(
                    child: LoadingAnimation(
                  typeOfAnimation: "staggeredDotsWave",
                  color: themeColor,
                  size: 100,
                ));
              },
            ),
          ),
        ),
      ),
    );
  }

  updateStte() {
    setState(() {});
  }
}
