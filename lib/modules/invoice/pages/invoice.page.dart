import 'package:app/core/enums/type_mobile.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/widgets/side.invoice.details.dart';
import 'package:app/modules/invoice/widgets/side.invoice.fotter.dart';
import 'package:app/modules/invoice/widgets/side.invoice.header.dart';
import 'package:app/modules/invoice/widgets/side.invoice.top.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../invoice.dart';

class SideInvoice extends StatelessWidget {
  final List<SalesTaxesDetails> salestaxesDetails;
  SideInvoice({this.salestaxesDetails});

  @override
  Widget build(BuildContext context) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Container(
      width: typeMobile == TYPEMOBILE.TABLET
          ? 350
          : MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Column(
        children: [
          SideInvoiceTop(),
          SideInvoiceHeader(),
          SideInvoiceDetails(key: invoice.sideInvoice),
          SideInvoiceFotter(salestaxesDetails: this.salestaxesDetails)
        ],
      ),
    );
  }
}
