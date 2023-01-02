import 'package:app/models/models.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/widgets/side.invoice.details.dart';
import 'package:app/modules/invoice/widgets/side.invoice.fotter.dart';
import 'package:app/modules/invoice/widgets/side.invoice.header.dart';
import 'package:app/modules/invoice/widgets/side.invoice.top.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideInvoice extends StatelessWidget {
  final List<SalesTaxesDetails> salestaxesDetails;

  SideInvoice({this.salestaxesDetails});

  @override
  Widget build(BuildContext context) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);

    return Container(
      width: 350,
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
