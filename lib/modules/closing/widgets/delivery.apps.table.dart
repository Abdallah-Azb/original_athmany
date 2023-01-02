import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/db-operations/db.delivery.application.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/delivery.application.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nil/nil.dart';

class DeliveryAppsTable extends StatefulWidget {
  final String baseUrl;
  const DeliveryAppsTable(this.baseUrl);

  @override
  _DeliveryAppsTableState createState() => _DeliveryAppsTableState();
}

class _DeliveryAppsTableState extends State<DeliveryAppsTable> {
  DBDeliveryApplication _dbDeliveryApplication = DBDeliveryApplication();
  List<DeliveryApplication> dbDeliveryApps = [];
  // Future deliveryAppsFuture;
  String hideTotalAmount;
  Future<List<DeliveryApplication>> getDeliveryAppsData() async {
    this.dbDeliveryApps = await _dbDeliveryApplication.getAll();
    print("dbDeliveryApps.isEmpty???? ====== ${dbDeliveryApps.isEmpty}");
    if(dbDeliveryApps.isNotEmpty)
    for (DeliveryApplication deliveryApplication in this.dbDeliveryApps) {
      print("Hey from looping!");
      List<Invoice> invoices = await DBInvoiceRefactor()
          .getInvoicesOfDeliveryApp(deliveryApplication.customer);
      double totalOfInvoices = 0;
      for (Invoice invoice in invoices) {
        totalOfInvoices += invoice.total;
      }
      this
          .dbDeliveryApps
          .firstWhere((e) => e.customer == deliveryApplication.customer)
          .totalOfInvoices = totalOfInvoices;
    }
    return this.dbDeliveryApps;
  }

  hideTotalAmountF() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    this.hideTotalAmount = _prefs.getString('hide_total_amount');
  }

  @override
  void initState() {
    super.initState();
    hideTotalAmountF();
    print("hello init delivery ?");
    // this.deliveryAppsFuture = _dbDeliveryApplication.getAll();
    print("hello init delivery2?");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DeliveryApplication>>(
      future: this.getDeliveryAppsData(),
      builder: (BuildContext context,
          AsyncSnapshot<List<DeliveryApplication>> snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (snapshot.hasData) {
          return Container(
            child: table(hideTotalAmount),
          );
        }
        return const Nil();
      },
    );
  }

  Widget table(String hideTotalAmount) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Table(
          columnWidths: typeMobile == TYPEMOBILE.TABLET
              ? {
                  0: FlexColumnWidth(0.2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                }
              : {
                  0: FlexColumnWidth(0.3),
                  1: FlexColumnWidth(0.7),
                  2: FlexColumnWidth(0.7),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(0.7),
                },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                headerCell(Localization.of(context).tr('no')),
                headerCell(Localization.of(context).tr('delivery_app')),
                headerCell(Localization.of(context).tr('amount')),
                headerCell(Localization.of(context).tr('closing_amount')),
                headerCell(Localization.of(context).tr('different')),
              ],
            ),
            for (int i = 0; i < this.dbDeliveryApps.length; i++)
              TableRow(
                children: <Widget>[
                  cell((i + 1).toString()),
                  modeOfPaymentCell(this.dbDeliveryApps[i]),
                  //
                  hideTotalAmount == '1'
                      ? cell('xxx')
                      : cell(this
                          .dbDeliveryApps[i]
                          .totalOfInvoices
                          .toStringAsFixed(2)),
                  //
                  hideTotalAmount == '1'
                      ? cell('xxx')
                      : cell(this
                          .dbDeliveryApps[i]
                          .totalOfInvoices
                          .toStringAsFixed(2)),
                  differentCell(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget headerCell(String title) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        alignment: Alignment.center,
        height: typeMobile == TYPEMOBILE.TABLET ? 55 : 50,
        color: blueGrayColor,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: typeMobile == TYPEMOBILE.TABLET ? 18 : 12,
          ),
        ),
      ),
    );
  }

  // merge check
  Widget headerCellMobile(String title) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        alignment: Alignment.center,
        height: 50,
        color: blueGrayColor,
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget cell(String title) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        alignment: Alignment.center,
        height: 55,
        color: isDarkMode == false ? Colors.white : darkContainerColor,
        child: Text(
          title,
          style: TextStyle(
              fontSize: typeMobile == TYPEMOBILE.TABLET ? 18 : 12,
              color: isDarkMode == false ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget modeOfPaymentCell(DeliveryApplication deliveryApplication) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        alignment: Alignment.center,
        height: 55,
        color: isDarkMode == false ? Colors.white : darkContainerColor,
        // child: Text(deliveryApplication.icon != null ? deliveryApplication.icon : 'adfadsf'),
        // child: Text('adf'),
        child:
            deliveryApplication.icon != '' && deliveryApplication.icon != null
                ? Image.network(
                    widget.baseUrl + deliveryApplication.icon,
                    scale: 2,
                  )
                : Text(deliveryApplication.customer),
      ),
    );
  }

  Widget differentCell() {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        color: isDarkMode == false ? Colors.white : darkContainerColor,
        alignment: Alignment.center,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: themeColor.withOpacity(0.2),
            ),
            alignment: Alignment.center,
            width: double.infinity,
            height: 55,
            child: Text("0.00",
                style: TextStyle(
                    fontSize: typeMobile == TYPEMOBILE.TABLET ? 18 : 14))),
      ),
    );
  }
}
