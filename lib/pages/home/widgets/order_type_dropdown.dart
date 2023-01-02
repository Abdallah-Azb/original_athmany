import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/menuItems/menu.item.dart';
import 'package:app/providers/providers.dart';
import 'package:flutter/material.dart';
import "package:app/db-operations/db.delivery.application.dart";
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nil/nil.dart';
import 'package:app/core/extensions/widget_extension.dart';

class OrderTypeDropdown extends StatefulWidget {
  const OrderTypeDropdown({
    Key key,
  }) : super(key: key);

  @override
  _OrderTypeDropdownState createState() => _OrderTypeDropdownState();
}

class _OrderTypeDropdownState extends State<OrderTypeDropdown> {
  List<DeliveryApplication> deliveryApplicationList = [];
  List<DeliveryApplication> devices = [];
  String baseUrl;
  @override
  void initState() {
    super.initState();
    getDeliveryApplications();
  }

  Future getDeliveryApplications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    baseUrl = await sharedPreferences.get('base_url');
    deliveryApplicationList = await DBDeliveryApplication().getAll();
    setState(() {});
  }

  bool enableDeliveryApplication(InvoiceProvider invoice) {
    bool enabled = false;
    if (invoice.currentInvoice.itemsList.length == 0 &&
        invoice.currentInvoice.tableNo == null &&
        invoice.currentInvoice.id == null) enabled = true;
    return enabled;
  }

  @override
  Widget build(BuildContext context) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: true);
    HomeProvider homeProvider =
        Provider.of<HomeProvider>(context, listen: false);
    return deliveryApplicationList.length > 0
        ? PopupMenuButton(
            enabled: enableDeliveryApplication(invoice),
            // enabled: invoice.items.length == 0 ? true : false,
            initialValue: "none",
            offset:
                Offset(0, -(deliveryApplicationList.length * 30).toDouble()),
            elevation: 0.0,
            child: _PopupMenu(),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            onSelected: (value) {
              context
                  .read<DeliveryApplicationProvider>()
                  .setSelectedDeliveryApplication(value);

              invoice.setSelectedDeliveryApplication(value);

              invoice.setCustomer(
                  invoice.currentInvoice.selectedDeliveryApplication.customer,
                  newDeliveryApplication: true);
              homeProvider.setMainIndex(0);
            },
            itemBuilder: generatePopupList,
          ).paddingAll(1)
        : const SizedBox.shrink();
  }

  List<PopupMenuEntry<Object>> generatePopupList(BuildContext context) {
    var items = <PopupMenuEntry<Object>>[];
    var entries = deliveryApplicationList.asMap().entries;

    for (var e in entries) {
      if (e.key != 0 && e.key != entries.length) {
        items.add(PopupMenuDivider(height: 1.0));
      }
      items.add(buildPopupMenuItem(context, e.value.customer, e.value));
    }

    return items;
  }

  PopupMenuItem<Object> buildPopupMenuItem(
      BuildContext context, String title, DeliveryApplication value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _Icon(icon: '$baseUrl${value.icon}', prefixIcon: value.customer[0]),
          SizedBox(width: 10.0),
          Text(title, style: Theme.of(context).textTheme.headline6),
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final String icon;
  final String prefixIcon;
  const _Icon({Key key, this.icon, @required this.prefixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return icon != null && !icon.contains('null')
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              icon,
              width: 40,
            ),
          )
        : Container(
            // width: 40,
            // height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: themeColor,
            ),
            child: Text("$prefixIcon", style: TextStyle(color: Colors.white))
                .paddingHorizontally(8),
          );
  }
}

class _PopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    InvoiceProvider invoice = Provider.of<InvoiceProvider>(context);
    DeliveryApplicationProvider deliveryApplicationProvider =
        Provider.of<DeliveryApplicationProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(left: 3, right: 3),
          alignment: Alignment.center,
          width: 180,
          height: 55,
          decoration: BoxDecoration(
              color: invoice.currentInvoice.itemsList.length != 0 ||
                      invoice.currentInvoice.tableNo != null
                  ? Colors.grey
                  : orangeColor,
              // color: invoice.items.length > 0 ? color : Colors.grey,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // _selectedOrder != null
              //     ? _Icon(
              //         icon: _selectedOrder?.icon,
              //         prefixIcon: _selectedOrder?.customer[0])
              //     : SizedBox.shrink(),
              deliveryApplicationProvider
                          .selectedDeliveryApplication?.customer ==
                      null
                  ? SvgPicture.asset("assets/footer/deliverysvg.svg",
                      color: Colors.white)

                  // ? Image.asset(
                  //     'assets/footer/deliverypng@3x.png',
                  //     color: Colors.white,
                  //     height: 40,
                  //   )
                  : Text(
                      deliveryApplicationProvider
                              .selectedDeliveryApplication?.customer ??
                          Localization.of(context).tr('delivery_application'),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }
}
