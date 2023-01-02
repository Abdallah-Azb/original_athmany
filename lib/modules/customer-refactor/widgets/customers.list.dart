import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/customer-refactor/models/customer_bills.dart';
import 'package:app/modules/customer-refactor/models/models.dart';
import 'package:app/modules/customer-refactor/repositories/customerRepository.dart';
import 'package:app/modules/customer-refactor/widgets/ExpandableCard.dart';
import 'package:app/modules/customer/customer.dart';
import 'package:app/modules/invoice/provider/invoice.provider.dart';
import 'package:app/providers/home.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomersList extends StatefulWidget {
  final List<Customer> customers;
  CustomersList(this.customers);
  @override
  _CustomersListState createState() => _CustomersListState();
}

class _CustomersListState extends State<CustomersList> {
  var expanded = false;

  @override
  void initState() {
    super.initState();
  }

  // Widget build(BuildContext context) {
  //   return Container(width: double.infinity, child: table());
  // }

  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        child: ListView.builder(
          itemBuilder: (ctx, i) => DetailableCard(widget.customers[i], i),
          itemCount: widget.customers.length,
        ),
      ),
    );
  }

  Widget table() {
    return Container(
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
          dataRowColor: MaterialStateProperty.all(Colors.white),
          columns: dataColumns(),
          rows: dataRows(),
        ),
      ),
    );
  }

  List<DataColumn> dataColumns() {
    List<DataColumn> dataColumns = [
      dataColumn(Localization.of(context).tr('no')),
      dataColumn(Localization.of(context).tr('customer_name')),
      dataColumn(Localization.of(context).tr('customer_phone')),
      dataColumn(Localization.of(context).tr('email')),
      dataColumn(Localization.of(context).tr('allowDefermentOfPayment')),
      dataColumn(''),
      dataColumn(''),
    ];
    return dataColumns;
  }

  List<DataRow> dataRows() {
    List<DataRow> dataRows = [
      for (int i = 0; i < this.widget.customers.length; i++)
        DataRow(
          onSelectChanged: (bool selected) {
            if (selected) onInvoiceSlected(this.widget.customers[i]);
          },
          cells: <DataCell>[
            dataCell((i + 1).toString()),
            dataCell(this.widget.customers[i].customerName),
            dataCell(this.widget.customers[i].defaultMobile),
            dataCell(this.widget.customers[i].defaultEmail),
            allowCreditDataCell(
                this.widget.customers[i].allowDefermentOfPayment),
            edit(this.widget.customers[i]),
            customerLastBills(this.widget.customers[i]),
          ],
        ),
    ];
    return dataRows;
  }

  void onInvoiceSlected(Customer customer) async {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    invoice.currentInvoice.customerRefactor = customer;
    Provider.of<HomeProvider>(context, listen: false).setMainIndex(0);
  }

  DataColumn dataColumn(String headerTitle) {
    return DataColumn(
      label: Text(
        headerTitle,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  DataCell dataCell(String data) {
    return DataCell(Text(data ?? ''));
  }

  DataCell edit(Customer customer) {
    return DataCell(IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        context.read<CustomersProvider>().setEditCustomer(customer);
        context.read<HomeProvider>().setMainIndex(5);
      },
    ));
  }

  DataCell customerLastBills(Customer customer) {
    return DataCell(IconButton(
      icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
      onPressed: () {
        expanded = !expanded;
        setState(() {});
      },
    ));
  }

  DataCell allowCreditDataCell(int allowCredit) {
    return DataCell(allowCredit == 1 ? Text('allowed') : Text('not allowed'));
  }
}

// Widget expansionDetails() {
//   return Container(
//     child: ExpansionPanelList(
//       animationDuration: Duration(seconds: 2),
//       elevation: 3,
//       expandedHeaderPadding: EdgeInsets.all(8),
//       children: [
//         ExpansionPanel(
//           headerBuilder: (context, isOpen) {
//             return InkWell(
//               onTap: () {},
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(Localization.of(context).tr('no')),
//                       Text(Localization.of(context).tr('customer_name')),
//                       Text(Localization.of(context).tr('customer_phone')),
//                       Text(Localization.of(context).tr('email')),
//                       Text(Localization.of(context)
//                           .tr('allowDefermentOfPayment')),
//                       Text(''),
//                       Text(''),
//                     ],
//                   ),
//                   for (int i = 0; i < this.widget.customers.length; i++)
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Text('${i + 1}'),
//                         Text(
//                           '${widget.customers[i].name}',
//                           textAlign: TextAlign.center,
//                         ),
//                         Text('${widget.customers[i].defaultMobile}'),
//                         Text('${widget.customers[i].defaultEmail}'),
//                         Text(
//                             '${widget.customers[i].allowDefermentOfPayment}'),
//                         Text(''),
//                         Text(''),
//                       ],
//                     ),
//                 ],
//               ),
//             );
//           },
//           body: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(Localization.of(context).tr('no')),
//               Text(Localization.of(context).tr('customer_name')),
//               Text(Localization.of(context).tr('customer_phone')),
//               Text(Localization.of(context).tr('email')),
//               Text(Localization.of(context).tr('allowDefermentOfPayment')),
//               Text(''),
//               Text(''),
//             ],
//           ),
//           isExpanded: _isOpen,
//         )
//       ],
//       expansionCallback: (panelIndex, isExpanded) {
//         _isOpen = !_isOpen;
//         setState(() {});
//       },
//     ),
//   );
// }
