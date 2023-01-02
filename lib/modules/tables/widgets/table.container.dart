import 'package:app/core/enums/type_mobile.dart';

import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/db-operations/db.tables.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/providers/providers.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../res.dart';
import '../tables.dart';

class TableContainer extends StatefulWidget {
  const TableContainer({
    Key key,
    @required this.table,
  }) : super(key: key);

  final TableModel table;

  @override
  _TableContainerState createState() => _TableContainerState();
}

class _TableContainerState extends State<TableContainer> {
  @override
  Widget build(BuildContext context) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    TablesProvider tablesProvider = Provider.of<TablesProvider>(context);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return InkWell(
      child: typeMobile == TYPEMOBILE.TABLET
          ? Container(
              decoration: boxDecoration(widget.table,
                  tablesProvider.selectedTableNo == widget.table.no),
              margin: EdgeInsets.only(bottom: 20),
              height: 80,
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset('assets/table.png'),
                  tableNumber(widget.table)
                ],
              ),
            )
          // ==== Mobile ====
          : Container(
              decoration: boxDecoration(widget.table,
                  tablesProvider.selectedTableNo == widget.table.no),
              margin: EdgeInsets.only(bottom: 15),
              height: 70,
              width: 110,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    Res.table,
                  ),
                  tableNumber(widget.table)
                ],
              ),
            ),
      onTap: () async {
        InvoiceProvider invoiceProvider =
            Provider.of<InvoiceProvider>(context, listen: false);
        if (widget.table.reserved != 1) {
          if (invoice.currentInvoice.id != null &&
              tablesProvider.selectedTableNo != widget.table.no &&
              tablesProvider.selectedTableNo != null &&
              invoice.currentInvoice.postingDate != null) {
            confirmChangeTable(widget.table, tablesProvider.selectedTableNo);
          } else if (invoice.currentInvoice.id != null &&
              tablesProvider.selectedTableNo != widget.table.no &&
              tablesProvider.selectedTableNo == null) {
            invoice.currentInvoice.tableNo = widget.table.no;
            tablesProvider.setSelectedTableNo(widget.table.no);
            context.read<HomeProvider>().setMainIndex(0);
          } else {
            invoice.currentInvoice.tableNo = widget.table.no;
            tablesProvider.setSelectedTableNo(widget.table.no);
            context.read<HomeProvider>().setMainIndex(0);
          }
        } else if (widget.table.reserved == 1 &&
            invoice.currentInvoice != null &&
            tablesProvider.selectedTableNo != null &&
            tablesProvider.selectedTableNo != widget.table.no &&
            invoiceProvider.invoiceUpdated == true) {
          final bool accept =
              await invoiceProvider.changeActivatedInvoiceConfirmDialog(
                  context, invoiceProvider.currentInvoice.id);
          if (accept == true) {
            setActiveInvoice(invoiceProvider, null, tablesProvider, context);
          }
          print('what');
        } else if (widget.table.reserved == 1) {
          TablesProvider tablesProvider =
              Provider.of<TablesProvider>(context, listen: false);

          if (invoiceProvider.newId != null &&
              invoiceProvider.currentInvoice.id == null &&
              invoiceProvider.currentInvoice.itemsList.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => ConfirmDialog(
                bodyText: Localization.of(context).tr('add_items_to_table'),
                onConfirm: () async {
                  await setActiveInvoice(
                      invoiceProvider,
                      invoiceProvider.currentInvoice.itemsList,
                      tablesProvider,
                      context);
                  Navigator.pop(context);
                },
                onCancel: () async {
                  await setActiveInvoice(
                      invoiceProvider, null, tablesProvider, context);
                  Navigator.pop(context);
                },
              ),
            );
          } else if (widget.table.no != tablesProvider.selectedTableNo) {
            await setActiveInvoice(
                invoiceProvider, null, tablesProvider, context);
          }
        }
      },
    );
  }

  Future<void> setActiveInvoice(InvoiceProvider i, List<Item> extraItems,
      TablesProvider tablesProvider, BuildContext context) async {
    i.clearInvoice();

    Invoice invoice =
        await DBInvoiceRefactor().getCompleteInvoice(tableNo: widget.table.no);
    setState(() {});

    await i.changeActiveInvoice(context, invoice.id, extraItems: extraItems);
    if (invoice.selectedDeliveryApplication != null) {
      i.currentInvoice.selectedDeliveryApplication =
          await DBDeliveryApplication.getByName(
              invoice.selectedDeliveryApplication.customer);
    }
    i.currentInvoice.id = invoice.id;
    i.currentInvoice.name = invoice.name;
    i.currentInvoice.customer = invoice.customer;
    i.currentInvoice.tableNo = invoice.tableNo;
    tablesProvider.selectedTableNo = invoice.tableNo;
    i.setNewId(invoice.id);
    i.currentInvoice.postingDate = invoice.postingDate;
    i.currentInvoice.docStatus = invoice.docStatus;
    i.currentInvoice.id = invoice.id;
    context.read<HomeProvider>().setMainIndex(0);
  }

  Widget tableNumber(TableModel table) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Container(
      alignment: Alignment.center,
      width: 34,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: Text(
        table.no.toString(),
        style: TextStyle(
            color: darkGreyColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  confirmChangeTable(TableModel table, int oldTableNo) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    TablesProvider tablesProvider =
        Provider.of<TablesProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          icon: Image.asset('assets/table-replace.png'),
          iconHeight: 40,
          bodyText: Localization.of(context).tr('on_change_table_button'),
          onConfirm: () async {
            await DBDineInTables()
                .changeTableNo(invoice.currentInvoice.id, table.no, oldTableNo);

            invoice.currentInvoice.tableNo = table.no;
            tablesProvider.setSelectedTableNo(table.no);
            Navigator.pop(context);
            context.read<HomeProvider>().setMainIndex(0);
          },
        );
      },
    );
  }

  BoxDecoration boxDecoration(TableModel table, bool selected) {
    return BoxDecoration(
      border: selected
          ? Border.all(color: Colors.orange, width: 3)
          : Border.all(color: Colors.transparent, width: 3),
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.centerRight,
        colors: [
          table.reserved == 1 ? darkGreyColor : Color(0xff2EB4C1),
          table.reserved == 1 ? darkGreyColor : themeColor,
        ],
      ),
      borderRadius: BorderRadius.all(Radius.circular(50)),
    );
  }
}
