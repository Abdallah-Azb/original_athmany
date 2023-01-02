import 'package:app/core/enums/enums.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/menuItems/menu.item.dart';
import 'package:app/providers/providers.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerAndTables extends StatefulWidget {
  final int totalOfTables;

  const CustomerAndTables({
    Key key,
    @required this.totalOfTables,
  }) : super(key: key);

  @override
  State<CustomerAndTables> createState() => _CustomerAndTablesState();
}

class _CustomerAndTablesState extends State<CustomerAndTables> {
  @override
  Widget build(BuildContext context) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    DeliveryApplicationProvider deliveryApplicationProvider =
        Provider.of(context);

    bool isCustomerAndTableDisabled =
        deliveryApplicationProvider.selectedDeliveryApplication != null ||
            invoice.currentInvoice.docStatus == DOCSTATUS.PAID;

    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;

    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                // totalOfTables > 0
                //     ? FooterBtn(
                //         color: themeColor,
                //         title: invoice.currentInvoice.tableNo == null
                //             ? Localization.of(context).tr('tables')
                //             : invoice.currentInvoice.tableNo.toString(),
                //         onTap:
                //             deliveryApplicationProvider.selectedDeliveryApplication ==
                //                     null
                //                 ? invoice.currentInvoice.docStatus != DOCSTATUS.PAID
                //                     ? () {
                //                         context.read<HomeProvider>().setMainIndex(7);
                //                       }
                //                     : () {}
                //                 : null,
                //         isLoading: false,
                //         isTablesButton: true,
                //       )
                //     : Container(),
                InkWell(
                  onTap: () {
                    context.read<HomeProvider>().setMainIndex(4);
                    // if (invoice.currentInvoice.docStatus != DOCSTATUS.PAID) {
                    //   if (deliveryApplicationProvider.selectedDeliveryApplication ==
                    //       null) {
                    //     context.read<HomeProvider>().setMainIndex(4);
                    //   }
                    // }
                  },
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        height: 33,
                        width: 33,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCustomerAndTableDisabled
                                ? Colors.grey
                                : invoice.currentInvoice.itemsList.length == 0
                                    ? themeColor
                                    : getButtonColor('Customer', themeColor)),
                        child: Image.asset('assets/side-menu/user.png'),
                      ),
                      Text(
                        // invoice.currentInvoice.customer,
                        invoice.currentInvoice.customerRefactor.customerName,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        :
        // === Mobile ===
        Container(
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    context.read<HomeProvider>().setMainIndex(4);
                  },
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 2, right: 2),
                        alignment: Alignment.center,
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.yellow),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
