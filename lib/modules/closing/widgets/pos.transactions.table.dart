import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/db-operations/db.delivery.application.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/closing/models.dart/models.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../res.dart';
import '../../../widget/widget/loading_animation_widget.dart';

class PosTransactionsTable extends StatefulWidget {
  final List<PosTransaction> posTransactions;
  final String baseUrl;
  PosTransactionsTable(this.posTransactions, this.baseUrl);

  @override
  _PosTransactionsTableState createState() => _PosTransactionsTableState();
}

class _PosTransactionsTableState extends State<PosTransactionsTable> {
  String baseUrl;
  List<PosTransaction> posTransactions;
  Future deliveryApplicationsFuture;
  DBDeliveryApplication _dbDeliveryApplication = DBDeliveryApplication();
  List<DeliveryApplication> deliveryApplications = [];

  Future<List<DeliveryApplication>> getDeliveryApplications() {
    return _dbDeliveryApplication.getAll();
  }

  @override
  void initState() {
    super.initState();
    this.posTransactions = widget.posTransactions.reversed.toList();
    this.deliveryApplicationsFuture = getDeliveryApplications();
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;

    return FutureBuilder<List<DeliveryApplication>>(
      future: deliveryApplicationsFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }
        if (snapshot.hasData) {
          this.deliveryApplications = snapshot.data;
          // merge check , why container ?
          return typeMobile == TYPEMOBILE.TABLET
              ? table()
              : Container(child: table());
        }
        return Center(
          child: LoadingAnimation(
            typeOfAnimation: "staggeredDotsWave",
            color: themeColor,
            size: 100,
          ),
        );
      },
    );
  }

  Widget table() {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: DataTable(
                showCheckboxColumn: false,
                headingTextStyle: TextStyle(color: Colors.white),
                headingRowColor: MaterialStateProperty.all(blueGrayColor),
                dataRowColor: MaterialStateProperty.all(
                  isDarkMode == false ? Colors.white : darkContainerColor,
                ),
                columns: dataColumns(),
                rows: dataRows(),
              ),
            ),
          )
        :
        // === Mobile ====
        Container(
            decoration: BoxDecoration(
              // color: Colors.white,
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Table(
                border: TableBorder(
                    horizontalInside:
                        BorderSide(color: Colors.grey, width: 0.5),
                    verticalInside:
                        BorderSide(color: Colors.grey, width: 0.25)),
                columnWidths: {
                  0: FlexColumnWidth(0.3),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(0.6),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  TableRow(
                    children: <Widget>[
                      headerCellMobile(Localization.of(context).tr('no')),
                      headerCellMobile(Localization.of(context).tr('invoice')),
                      headerCellMobile(Localization.of(context).tr('customer')),
                      headerCellMobile(Localization.of(context).tr('date')),
                      headerCellMobile(Localization.of(context).tr('amount')),
                    ],
                  ),
                  for (int i = 0; i < this.posTransactions.length; i++)
                    TableRow(
                      children: <Widget>[
                        cellDataMobile((i + 1).toString()),
                        cellDataMobile(this.posTransactions[i].posInvoice,
                            onTap: () {
                          onInvoiceSlected(this.posTransactions[i]);
                        }),

                        // cellDataCustomerMobile(this.posTransactions[i].customer),
                        cellDataMobile(this.posTransactions[i].customer),
                        cellDataMobile(this.posTransactions[i].postingDate),
                        cellDataMobile(this
                            .posTransactions[i]
                            .grandTotal
                            .toStringAsFixed(2)),
                      ],
                    ),
                ],
              ),
            ),
          );
  }

  List<DataColumn> dataColumns() {
    List<DataColumn> dataColumns = [
      dataColumn(Localization.of(context).tr('no')),
      dataColumn(Localization.of(context).tr('invoice')),
      dataColumn(Localization.of(context).tr('customer')),
      dataColumn(Localization.of(context).tr('date')),
      dataColumn(Localization.of(context).tr('amount')),
    ];
    return dataColumns;
  }

  List<DataRow> dataRows() {
    List<DataRow> dataRows = [
      for (int i = 0; i < this.posTransactions.length; i++)
        DataRow(
          onSelectChanged: (bool selected) {
            if (selected) onInvoiceSlected(this.posTransactions[i]);
          },
          cells: <DataCell>[
            dataCell((i + 1).toString()),
            dataCell(this.posTransactions[i].posInvoice),
            customerDataCell(this.posTransactions[i].customer),
            dataCell(this.posTransactions[i].postingDate),
            dataCell(this.posTransactions[i].grandTotal.toStringAsFixed(2)),
          ],
        ),
    ];
    return dataRows;
  }

  void onInvoiceSlected(PosTransaction posTransaction) async {
    InvoiceProvider invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    print(posTransaction.posInvoice);
    await invoiceProvider.clearInvoice();
    await invoiceProvider.setActiveInvoieFromClosing(posTransaction.posInvoice);
    Provider.of<HomeProvider>(context, listen: false).setMainIndex(0);
  }

  DataColumn dataColumn(String headerTitle) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return DataColumn(
      label: Text(
        headerTitle,
        style: typeMobile == TYPEMOBILE.TABLET
            ? TextStyle(fontStyle: FontStyle.italic)
            : TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
      ),
    );
  }

  Widget headerCellMobile(String headerTitle) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Container(
        alignment: Alignment.center,
        height: 50,
        color: blueGrayColor,
        child: Text(
          headerTitle,
          style: TextStyle(
              fontStyle: FontStyle.italic, fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  DataCell dataCell(String data) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return DataCell(Text(
      data,
      style: typeMobile == TYPEMOBILE.TABLET
          ? TextStyle(
              color: isDarkMode == false ? Colors.black : Colors.white,
            )
          // == Mobile ===
          : TextStyle(
              color: isDarkMode == false ? Colors.black : Colors.white,
              fontSize: 13),
    ));
  }

  DataCell customerDataCell(String customer) {
    DeliveryApplication deliveryApplication = this
        .deliveryApplications
        .firstWhere((e) => e.customer == customer, orElse: () => null);

    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return DataCell(deliveryApplication == null
        ? Row(
            children: [
              Image.asset(
                Res.user,
                color: isDarkMode == false ? Colors.black : Colors.white,
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                customer,
                style: typeMobile == TYPEMOBILE.TABLET
                    ? TextStyle()
                    : TextStyle(
                        fontSize: 13,
                      ),
              ),
            ],
          )
        : deliveryApplication.icon != '' && deliveryApplication.icon != null
            ? Row(
                children: [
                  Image.network(
                    widget.baseUrl + deliveryApplication.icon,
                    scale: 2,
                  ),
                  SizedBox(
                    width: typeMobile == TYPEMOBILE.TABLET ? 20 : 5,
                  ),
                  Text(deliveryApplication.customer)
                ],
              )
            : Text(deliveryApplication.customer));
  }

  Widget cellDataMobile(String data, {onTap}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: InkWell(
        onTap: onTap ?? () {},
        child: Container(
          alignment: Alignment.center,
          height: 50,
          color: isDarkMode == true ? darkContainerColor : Colors.white,
          child: Text(
            data,
            style: TextStyle(
                color: isDarkMode == false ? Colors.black : Colors.white,
                fontSize: 12),
            maxLines: 2,
          ),
        ),
      ),
    );
  }
}
