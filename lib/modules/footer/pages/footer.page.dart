import 'dart:async';

import 'package:app/core/enums/enums.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.accessory.dart';
import 'package:app/db-operations/db.delivery.application.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/models.dart';
import 'package:app/models/profile.details.dart';
import 'package:app/modules/accessories/models/accessory.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/pages/home/widgets/order_type_dropdown.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/services/print-service/print.service.dart';
import 'package:app/widget/provider/theme_provider.dart';
// import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
// import 'package:flutter_sunmi_printer_t2/flutter_sunmi_printer_t2.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../kitchen_config.dart';
import '../../../res.dart';
import '../../closing/models.dart/closing_report.dart';
import '../../closing/repositories/repositories.dart';
import '../footer.dart';
import 'package:nil/nil.dart';
import '../../../core/extensions/time_extension.dart';

class Fotter extends StatefulWidget {
  final ProfileDetails posProfileDetails;
  final Function clearInvoice;
  final Function resetItemGroup;

  Fotter({
    this.posProfileDetails,
    this.clearInvoice,
    this.resetItemGroup,
  });

  @override
  _FotterState createState() => _FotterState();
}

class _FotterState extends State<Fotter> {
  bool isThereKitchenDevice;
  bool isTherePrintersDevice;
  bool isConnected;
  List<Accessory> printers;
  PrintService printService;
  String applyDiscountOn;
  // merge variables
  List<DeliveryApplication> deliveryApplicationList = [];
  String baseUrl;
  String _status = 'New';
  PermissionStatus _permissionGranted;
  Location location = new Location();
  Timer checkNotSyncedInvoicesTimer;

  bool isPayForDiscountableInvoiceDisabled = true;

  List<Accessory> data = [];
  _getDevices() async {
    List<Accessory> _data = await DBAccessory().getAllAccessories();
    _data.forEach((element) {
      if (element.deviceType == DeviceType.MONITOR &&
          element.deviceFor == DeviceFor.KITCHEN) {
        data.add(element);
      }
    });
    setState(() {});
  }

  _checkInvoiceId(String id) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
  }

  _getApplyDiscountOn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    applyDiscountOn = sharedPreferences.getString('apply_discount_on');
  }

  List<Map<String, dynamic>> _data = [];
  addDataToList(List<Item> data) {
    _data.clear();
    for (int i = 0; i < data.length; i++) {
      _data.add({
        "item_code": data[i].itemCode.toString(),
        "item_name": data[i].itemName.toString(),
        "is_sup": data[i].isSup == null ? 0 : 1,
        "is_custom": 1,
        "description": data[i].descriptionSection.toString(),
        "qty": data[i].qty,
        "stock_uom": data[i].stockUom.toString(),
      });
    }
  }

  Future getDeliveryApplications() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    baseUrl = await sharedPreferences.get('base_url');
    deliveryApplicationList = await DBDeliveryApplication().getAll();
    setState(() {});
  }

  bool hasConnection;

  StreamSubscription<ConnectivityResult> _streamSubscription;

  Future<void> _internetConnectionStream() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    _toggleIsConnected(connectivityResult);
    _streamSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      _toggleIsConnected(result);
    });
  }

  void _toggleIsConnected(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      setState(() {
        isConnected = true;
      });
    } else {
      setState(() {
        isConnected = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    // checkNotSyncedInvoicesTimer = Timer.periodic(
    //     Duration(seconds: 3), (Timer t) => _internetConnectionStream());
    _internetConnectionStream();
    _getDevices();
    _getApplyDiscountOn();
    super.initState();
    getDeliveryApplications();
    // To ensure if there is a kitchen device
    Future.delayed(Duration.zero, () async {
      await context.read<InvoiceProvider>().checkIfThereIsKitchenDevices();
      this.isThereKitchenDevice =
          context.read<InvoiceProvider>().isThereKitchenDevice;
      this.isTherePrintersDevice =
          context.read<InvoiceProvider>().isTherePrintersDevice;
      print('is There Printer Device? ${isTherePrintersDevice}');
    });
  }

  // development

  @override
  Widget build(BuildContext context) {
    InvoiceProvider invoiceProvider = Provider.of<InvoiceProvider>(context);
    Invoice invoice = context.read<InvoiceProvider>().currentInvoice;
    print("invoice.discountAmount :::  ${invoice.discountAmount}");
    bool isPayAndSaveDisabled =
        invoiceProvider.currentInvoice.itemsList.length > 0 &&
            invoiceProvider.currentInvoice.docStatus != DOCSTATUS.PAID;
    bool isPayDisabled = invoiceProvider.currentInvoice.itemsList.length > 0 &&
        invoiceProvider.currentInvoice.docStatus != DOCSTATUS.PAID;
    if (invoice.discountAmount != null) {
      isConnected == true
          ? isPayForDiscountableInvoiceDisabled = true
          : isPayForDiscountableInvoiceDisabled = false;
      print(' ☎️☎️ isConnected? :::: ${isConnected}');
    } else {
      isPayForDiscountableInvoiceDisabled = true;
      print("isPayForDiscountableInvoiceDisabled is TRUE");
    }
    // bool isPrintKitchenDisabled =
    //     invoiceProvider.currentInvoice.itemsList.length > 0 &&
    //         invoiceProvider.currentInvoice.id != null &&
    //         isThereKitchenDevice == true;
    bool isPrintDisabled =
        invoiceProvider.currentInvoice.itemsList.length > 0 &&
            invoiceProvider.currentInvoice.id != null;

    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    // isTherePrintersDevice == true;

    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            height: 84,
            width: double.infinity,
            color: isDarkMode == false ? mainBlueColor : Color(0xff1F1F1F),
            child: Row(
              children: [
                CustomerAndTables(
                    totalOfTables: widget.posProfileDetails.totalOfTables),
                Expanded(child: const SizedBox.shrink()),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      OrderTypeDropdown(),
                      SizedBox(width: 10.0),
                      FooterBtn(
                        color: Colors.green,
                        path: 'assets/footer/discount.svg',
                        // title: Localization.of(context).tr('new_order'),
                        onTap: !isPayAndSaveDisabled
                            ? null
                            : () async {
                                await invoiceProvider.discount(
                                    context, isDarkMode, applyDiscountOn);
                              },
                        isLoading: false,
                      ),
                      FooterBtn(
                        color: Colors.indigo,
                        path: 'assets/footer/printer.svg',
                        onTap: !isPrintDisabled
                            ? null
                            : () async {
                                print(" now will print to cashier printers");
                                await invoiceProvider.printInvoice(context);
                                print(" now will print to kitchen monitors");
                                await invoiceProvider.SendDataToKitchen(
                                    invoiceProvider.currentInvoice, context);
                              },
                        isLoading: invoiceProvider.printLoading,
                      ),
                      FooterBtn(
                        color: themeColor,
                        path: 'assets/footer/new.svg',
                        // title: Localization.of(context).tr('new_order'),
                        onTap: () async {
                          await invoiceProvider.handleNewOrder(context);
                        },
                        isLoading: false,
                      ),
                      FooterBtn(
                        color: blueColor,
                        path: 'assets/footer/save.svg',
                        // title: Localization.of(context).tr('save'),
                        onTap: !isPayAndSaveDisabled
                            ? null
                            : () async {
                                await invoiceProvider.save(context);
                              },
                        isLoading: invoiceProvider.isSavingInProgress,
                      ),
                      isPayForDiscountableInvoiceDisabled
                          ? FooterBtn(
                              color: Colors.indigo,
                              path: 'assets/footer/pay.svg',
                              // title: Localization.of(context).tr('pay'),
                              onTap: !isPayAndSaveDisabled
                                  ? null
                                  : () async {
                                      print("footer :::: ${applyDiscountOn}");
                                      await invoiceProvider.pay(
                                          context, isDarkMode, applyDiscountOn);
                                    },
                              isLoading: false,
                            )
                          : FooterBtn(
                              color: Colors.indigo,
                              path: 'assets/footer/pay.svg',
                              // title: Localization.of(context).tr('pay'),
                              onTap: null,
                              isLoading: false,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          )
        // ==== Mobile ====
        : Container(
            width: double.infinity,
            color: isDarkMode == false ? mainBlueColor : appBarColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // === Save Invoice ===
                FooterBtn(
                  color: blueColor,
                  path: Res.saveSvg,
                  onTap: !isPayAndSaveDisabled
                      ? null
                      : () async {
                          await invoiceProvider.save(context);
                        },
                  isLoading: invoiceProvider.isSavingInProgress,
                ),
                FooterBtn(
                  color: Colors.indigo,
                  path: 'assets/footer/pay.svg',
                  onTap: !isPayAndSaveDisabled
                      ? null
                      : () async {
                          await invoiceProvider.pay(
                              context, isDarkMode, applyDiscountOn);
                        },
                  isLoading: false,
                ),
                CustomerAndTables(
                    totalOfTables: widget.posProfileDetails.totalOfTables),
                FooterBtn(
                  color: Colors.indigo,
                  path: 'assets/footer/printer.svg',
                  onTap: !isPrintDisabled
                      ? null
                      : () async {
                          // _print(invoiceProvider.currentInvoice.itemsList);

                          _checkInvoiceId(
                              invoiceProvider.currentInvoice.id.toString());
                          await invoiceProvider.printInvoice(context);
                          addDataToList(
                              invoiceProvider.currentInvoice.itemsList);

                          data.forEach((element) {
                            kitchenConfig(ip: element.ip, data: {
                              "customer":
                                  "${invoiceProvider.currentInvoice.customer ?? 'Customer'}",
                              "invoiceId": "${invoiceProvider.currentInvoice.id}" ?? "5",
                              "table_number":
                                  "${invoiceProvider.currentInvoice.tableNo.toString() ?? '0'}",
                              "pos_opening": "POS-OPE-2021-00608",
                              "casher":
                                  "${invoiceProvider.currentInvoice.name ?? "Casher"}",
                              "order_status": "dinein",
                              "status": _status,
                              "time": DateTime.now().toString(),
                              "order_number":
                                  invoiceProvider.currentInvoice.id.toString(),
                              "items": _data
                            }).then((_value) {});
                          });
                        },
                  isLoading: invoiceProvider.printLoading,
                ),
                FooterBtn(
                  color: themeColor,
                  path: 'assets/footer/new.svg',
                  // title: Localization.of(context).tr('new_order'),
                  onTap: () async {
                    await invoiceProvider.handleNewOrder(context);
                  },
                  isLoading: false,
                ),

                deliveryApplicationList.length > 0
                    ? Container(
                        margin: EdgeInsets.only(left: 3, right: 3),
                        alignment: Alignment.center,
                        width: (MediaQuery.of(context).size.width / 6) - 6,
                        height: 40,
                        child: OrderTypeDropdown())
                    : SizedBox(
                        height: 0,
                        width: 0,
                      ),
              ],
            ),
          );
  }

  // void _print(List<Item> data) async {
  //   SunmiPrinter.hr();
  //   SunmiPrinter.text(
  //     'Customer Copy',
  //     styles: SunmiStyles(align: SunmiAlign.center),
  //   );
  //   SunmiPrinter.hr();
  //
  //   SunmiPrinter.row(
  //     cols: [
  //       SunmiCol(text: 'name', width: 4),
  //       SunmiCol(text: 'qty', width: 4, align: SunmiAlign.center),
  //       SunmiCol(text: 'total', width: 4, align: SunmiAlign.right),
  //     ],
  //   );
  //
  //   for (int i = 0; i < data.length; i++) {
  //     print(data[i].itemName);
  //     return SunmiPrinter.row(cols: [
  //       SunmiCol(text: data[i].itemName, width: 4),
  //       SunmiCol(text: data[i].qty.toString(), width: 4),
  //       SunmiCol(text: data[i].costCenter, width: 4),
  //     ]);
  //   }
  //
  //   SunmiPrinter.emptyLines(2);
  // }
}
