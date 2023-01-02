import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/modules/closing/models.dart/paymentReconciliation.dart';
import 'package:app/modules/closing/provider/closing.provider.dart';
import 'package:app/modules/closing/repositories/repositories.dart';
import 'package:app/modules/closing/widgets/print_closing.dart';
import 'package:app/modules/closing/widgets/widgets.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nil/nil.dart';
import '../../../widget/widget/loading_animation_widget.dart';
import '../../../core/extensions/widget_extension.dart';

class ClosingPage extends StatefulWidget {
  const ClosingPage({Key key}) : super(key: key);

  @override
  _ClosingPageState createState() => _ClosingPageState();
}

class _ClosingPageState extends State<ClosingPage> {
  String baseUrl;
  ClosingRepository _closingRepository = ClosingRepository();
  Future closingDataFuture;
  List<PaymentReconciliation> payments;
  Future stockDataFuture;
  StockItemModel StockItemFuture;
  Future<ClosingData> closingData() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    this.baseUrl = _prefs.getString('base_url');
    return _closingRepository.getClosingData();
  }

  @override
  void initState() {
    super.initState();
    this.closingDataFuture = closingData();
    // this.stockDataFuture = stockData();
    context.read<ClosingProvider>().setSubmitValue(disableSubmit: true);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    var size = MediaQuery.of(context).size;
    return LoadingOverlay(
      progressIndicator: LoadingAnimation(
        typeOfAnimation: "staggeredDotsWave",
        color: themeColor,
        size: 100,
      ),
      isLoading: context.watch<ClosingProvider>().loading,
      child: Scaffold(
        backgroundColor: isDarkMode == false ? greyColor : Color(0xff1F1F1F),
        body: FutureBuilder<ClosingData>(
          future: closingDataFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              print("ClosingData FutureBuilder error == : ${snapshot.error}");
              return const Nil();
            }
            if (snapshot.hasData) {
              ClosingData closingData = snapshot.data;
              return typeMobile == TYPEMOBILE.TABLET
                  ? Column(
                    children: [
                      ClosingTitle(),
                      Expanded(
                        child: ListView(
                          children: [
                            // Text(
                            //   '${closingData.netTotal}',
                            //   style: TextStyle(color: Colors.red),
                            // ),
                            PaymentReconciliationTable(
                                closingData.paymentReconciliations),
                            SizedBox(height: 20),
                            PosTransactionsTable(
                                closingData.posTransactions, this.baseUrl),
                            SizedBox(height: 20),
                            DeliveryAppsTable(this.baseUrl),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                      Submit(closingData)
                    ],
                  ).paddingAll(20)
                  : Column(
                    children: [
                      ClosingTitle(),
                      SizedBox(height: 4),
                      Expanded(
                        child: ListView(
                          children: [
                            // Text(
                            //   '${closingData.netTotal}',
                            //   style: TextStyle(color: Colors.red),
                            // ),
                            PaymentReconciliationTable(
                                closingData.paymentReconciliations),
                            SizedBox(height: 8),
                            PosTransactionsTable(
                                closingData.posTransactions, this.baseUrl),
                            SizedBox(height: 8),
                            DeliveryAppsTable(this.baseUrl),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Submit(closingData)
                    ],
                  ).paddingAll(6);
            }
            return Center(
              child: LoadingAnimation(
                typeOfAnimation: "staggeredDotsWave",
                color: themeColor,
                size: 100,
              ),
            );
          },
        ),
      ),
    );
  }
}
