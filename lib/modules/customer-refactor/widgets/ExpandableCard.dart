//import 'package:easy_localization/easy_localization.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/customer-refactor/models/customer_bills.dart';
import 'package:app/modules/customer-refactor/models/models.dart';
import 'package:app/modules/customer-refactor/repositories/customerRepository.dart';
import 'package:app/modules/customer/customer.dart';
import 'package:app/modules/invoice/provider/invoice.provider.dart';
import 'package:app/providers/home.provider.dart';
import 'package:provider/provider.dart';

import '../../../widget/widget/loading_animation_widget.dart';
import '../../../core/extensions/widget_extension.dart';
class DetailableCard extends StatefulWidget {
  final Customer customer;
  final int index;
  DetailableCard(this.customer, this.index);
  @override
  _DetailableCardState createState() => _DetailableCardState();
}

class _DetailableCardState extends State<DetailableCard> {
  var _expand = false;
  var _isLoading = false;
  CustomerRepository _customerRepository = CustomerRepository();
  Future<List<CustomerBill>> bills;

  // Future<CustomerBill> customerBillsData() async {
  //   return _customerRepository.getCustomerBills(widget.customer.customerName);
  // }

  void onInvoiceSlected(Customer customer) async {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    invoice.currentInvoice.customerRefactor = customer;
    Provider.of<HomeProvider>(context, listen: false).setMainIndex(0);
  }

  void loadingData() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    print(widget.customer.defaultMobile ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Column(
            children: [
              CardHeader(context),
              RowData(context),
            ],
          ),
          if (_expand)
            Container(
              height: 250,
              width: double.infinity,
              child: FutureBuilder<List<CustomerBill>>(
                future: _customerRepository
                    .getCustomerBills(widget.customer.customerName),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    Center(
                      child: Text(snapshot.error.toString()),
                    );
                  return snapshot.hasData
                      ? Bills(bills: snapshot.data)
                      : Center(
                          child: LoadingAnimation(
                            typeOfAnimation: "staggeredDotsWave",
                            color: themeColor,
                            size: 100,
                          ),
                        );
                },
              ),
            ).paddingHorizontallyAndVertical(25, 10),
        ],
      ),
    );
  }

  InkWell RowData(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? InkWell(
            onTap: () {
              onInvoiceSlected(widget.customer);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowDataItem('${widget.index + 1}'),
                RowDataItem('${widget.customer.name}'),
                RowDataItem('${widget.customer.defaultMobile}'),
                RowDataItem('${widget.customer.defaultEmail}'),
                RowDataItem('${widget.customer.allowDefermentOfPayment}'),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      context
                          .read<CustomersProvider>()
                          .setEditCustomer(widget.customer);
                      context.read<HomeProvider>().setMainIndex(5);
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon:
                        Icon(_expand ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      print(widget.customer.customerName);
                      _isLoading = true;
                      setState(() {});
                      _isLoading = false;
                      _expand = !_expand;
                      setState(() {});
                    },
                  ),
                )
              ],
            ).paddingHorizontally(20),
          )
        :
        // === Mobile ===
        InkWell(
            onTap: () {
              onInvoiceSlected(widget.customer);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowDataItem('${widget.index + 1}', size: 12.0),
                RowDataItem('${widget.customer.name}', size: 12.0),
                RowDataItem('${widget.customer.defaultMobile}', size: 12.0),
                RowDataItem('${widget.customer.defaultEmail}', size: 12.0),
                RowDataItem('${widget.customer.allowDefermentOfPayment}',
                    size: 12.0),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      context
                          .read<CustomersProvider>()
                          .setEditCustomer(widget.customer);
                      context.read<HomeProvider>().setMainIndex(5);
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon:
                        Icon(_expand ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      print(widget.customer.customerName);
                      _isLoading = true;
                      setState(() {});
                      _isLoading = false;
                      _expand = !_expand;
                      setState(() {});
                    },
                  ),
                )
              ],
            ).paddingHorizontally(20),
          );
  }

  Container CardHeader(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;

    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
              color: blueGrayColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderItem(context, "no"),
                HeaderItem(context, "customer_name"),
                HeaderItem(context, "customer_phone"),
                HeaderItem(context, "email"),
                HeaderItem(context, "allowDefermentOfPayment"),
                Expanded(
                  flex: 1,
                  child: Text(''),
                ),
                Expanded(
                  flex: 1,
                  child: Text(''),
                )
              ],
            ).paddingHorizontallyAndVertical(20, 5),//
    )
        :
        // === Mobile ====
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              color: blueGrayColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderItem(context, "no", size: 12.0),
                HeaderItem(context, "customer_name", size: 12.0),
                HeaderItem(context, "customer_phone", size: 12.0),
                HeaderItem(context, "email", size: 12.0),
                HeaderItem(context, "allowDefermentOfPayment", size: 12.0),
                Expanded(
                  flex: 1,
                  child: Text(''),
                ),
                Expanded(
                  flex: 1,
                  child: Text(''),
                )
              ],
            ).paddingHorizontallyAndVertical(20, 5),
          );
  }

  Expanded RowDataItem(String title, {size = 18.0}) {
    return Expanded(
      flex: 1,
      child: Text(
        title,
        style: TextStyle(fontSize: 18),
      ).paddingAllNormal(),
    );
  }

  Expanded HeaderItem(BuildContext context, String title, {size = 18.0}) {
    return Expanded(
      flex: 1,
      child: Text(
        Localization.of(context).tr('$title'),
        style: TextStyle(
          color: Colors.white,
          fontStyle: FontStyle.italic,
          fontSize: 18,
        ),
      ),
    );
  }
}

class Bills extends StatelessWidget {
  List<CustomerBill> bills;

  Bills({this.bills});

  TextStyle billsItemsStyle = TextStyle(fontSize: 18);
  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return bills.isEmpty
        ? NoDataFound()
        : ListView.builder(
            itemCount: bills == null ? 0 : bills.length,
            itemBuilder: (context, i) {
              return typeMobile == TYPEMOBILE.TABLET
                  ? Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          BillNameAndPostingDateTime(i, context),
                          BillGrandTotalAndStatus(i, context),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(
                        height: 2,
                        thickness: 2,
                      ),
                    ],
                  ).paddingHorizontallyAndVertical(25, 10)
                  // ===== Mobile ====
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          BillNameAndPostingDateTime(i, context),
                          BillGrandTotalAndStatus(i, context),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(
                        height: 2,
                        thickness: 2,
                      ),
                    ],
                  ).paddingHorizontallyAndVertical(8, 5);
            }).paddingHorizontallyAndVertical(20, 15);
  }

  Column BillGrandTotalAndStatus(int i, context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${bills[i].grand_total}   ر.س",
          style: typeMobile == TYPEMOBILE.TABLET
              ? billsItemsStyle
              : TextStyle(fontSize: 13),
        ),
        Row(
          children: [
            CircleShape(),
            SizedBox(
              width: 10,
            ),
            Text(
              "${bills[i].status}",
              style: typeMobile == TYPEMOBILE.TABLET
                  ? billsItemsStyle
                  : TextStyle(fontSize: 13),
            ),
          ],
        )
      ],
    );
  }

  Column BillNameAndPostingDateTime(int i, context) {
    // String time = bills[i].posting_date + " " + bills[i].posting_time;
    // DateTime dateTime = DateTime.parse(time);
    // String timeString = DateFormat("hh:mm a").format(dateTime);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${bills[i].name}",
            style: TextStyle(
              color: Color(0xff62aa88),
              fontSize: typeMobile == TYPEMOBILE.TABLET ? 18 : 13.0,
            )),
        Text(
          "${bills[i].posting_date} ,  ${bills[i].posting_time.substring(0, 5) ?? ""}",
          style: typeMobile == TYPEMOBILE.TABLET
              ? billsItemsStyle
              : TextStyle(fontSize: 13),
        )
      ],
    );
  }

  Container CircleShape() {
    return Container(
      height: 24,
      width: 24,
      decoration:
          BoxDecoration(color: Color(0xff96d865), shape: BoxShape.circle),
    );
  }

  Center NoDataFound() {
    return Center(
      child: Text(
        "لا يوجد فواتير سابقة",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }
}
