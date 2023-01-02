import 'package:app/core/utils/utils.dart';
import 'package:app/modules/customer-refactor/models/models.dart';
import 'package:app/modules/customer/customer.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/widget/provider/theme_provider.dart';

import '../../../widget/widget/loading_animation_widget.dart';
import '../../../core/extensions/widget_extension.dart';
class Customers extends StatelessWidget {
  const Customers({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CustomersProvider>(
      create: (_) => CustomersProvider(),
      child: CustomersPage(),
    );
  }
}

class CustomersPage extends StatefulWidget {
  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  @override
  Widget build(BuildContext context) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);

    CustomersProvider customersProvider =
        Provider.of<CustomersProvider>(context);

    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      padding: EdgeInsets.only(top: 30, left: 30, right: 30),
      color: isDarkMode == false ? greyColor : darkBackGroundColor,
      child: FutureBuilder<List<Customer>>(
        future: customersProvider.getCustomers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Container();
          }
          if (snapshot.hasData) {
            print("-============ ok ==========");
            for (int i = 0; i < snapshot.data.length; i++) {
              if (snapshot.data[i].customerName ==
                  invoice.currentInvoice.customer) {
                customersProvider.selectedCustomerId = i;
              }
            }
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [table(snapshot)],
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
            ),
          );
        },
      ),
    );
  }

  // table
  Widget table(dynamic snapshot) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Table(
        border: TableBorder(
            verticalInside: BorderSide(
                color: Colors.grey, width: 1, style: BorderStyle.solid),
            horizontalInside: BorderSide(
                color: Colors.grey, width: 1, style: BorderStyle.solid)),
        columnWidths: {
          0: FlexColumnWidth(0.2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        children: <TableRow>[
          TableRow(children: [
            headerCell('No.'),
            headerCell('Name'),
            headerCell('Phone'),
          ]),
          for (int i = 0; i < snapshot.data.length; i++)
            TableRow(children: [
              cell(i, (i + 1).toString()),
              cell(i, snapshot.data[i].customerName, name: true),
              cell(i, '')
            ])
        ],
      ),
    );
  }

  // table header cell
  Widget headerCell(String title) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ).paddingVertical(4),
    );
  }

  // table header cell
  Widget cell(int index, String text, {bool name = false}) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);

    CustomersProvider customersProvider =
        Provider.of<CustomersProvider>(context);
    return TableCell(
      child: InkWell(
        child: Container(
            padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8),
            color: index == customersProvider.selectedCustomerId
                ? themeColor.withOpacity(0.6)
                : Colors.white,
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: TextStyle(fontSize: 18, color: Colors.black),
            )),
        onTap: () {
          customersProvider.setSelectedCustomerId(index);
          if (name == true) {
            invoice.currentInvoice.customer = text;
            invoice.setCustomer(text);
          }

          context.read<HomeProvider>().setMainIndex(0);
        },
      ),
    );
  }

  // search
  Widget search() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey,
            ),
            Text(
              'Search',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ).paddingHorizontallyAndVertical(20, 8),
      ),
    );
  }

  // add new customer
  Widget newCustomerButton() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'New Customer',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          SizedBox(
            width: 4,
          ),
          Icon(
            Icons.add,
            color: Colors.white,
          )
        ],
      ).paddingHorizontallyAndVertical(20, 8),
    );
  }
}
