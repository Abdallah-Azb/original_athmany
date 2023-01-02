import 'dart:async';
import 'package:app/core/enums/enums.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/localization/localization.dart';
import 'package:app/main.dart';
import 'package:app/models/delivery.application.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/menuItems/menu.item.dart';
import 'package:app/modules/searchInvioceList/search.invoice.list.dart';
import 'package:app/modules/tables/provider/tables.provider.dart';
import 'package:app/providers/providers.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/widget/empty_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:nil/nil.dart';
import '../../db-operations/db.operations.dart';
import '../../widget/widget/loading_animation_widget.dart';
import '../../core/extensions/widget_extension.dart';
class InvoicesList extends StatefulWidget {
  final Function clearInvoice;

  InvoicesList({Key key, this.clearInvoice}) : super(key: key);

  @override
  InvoicesListState createState() => InvoicesListState();
}

class InvoicesListState extends State<InvoicesList> {
  String baseUrl;
  DBDeliveryApplication _dbDeliveryApplication = DBDeliveryApplication();
  List<DeliveryApplication> deliveryApplications = [];
  bool isLoading = false;
  int activeHeaderButton = 0;
  String hideTotalAmount;
  List<Invoice> activeInvoices = [];
  List<Invoice> allInvoices = [];
  List<Invoice> paidInvoices = [];
  List<Invoice> savedInvoices = [];

  double invoicesTotal = 0;
  double paidInvoicesTotal = 0;
  double savedInvoicesTotal = 0;

  @override
  void initState() {
    super.initState();
    getInvoices();
    hideTotalAmountF();
  }

  hideTotalAmountF() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    this.hideTotalAmount = _prefs.getString('hide_total_amount');
  }

  Future getInvoices() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    this.baseUrl = _prefs.getString('base_url');
    this.deliveryApplications = await _dbDeliveryApplication.getAll();
    isLoading = true;
    setState(() {});
    final data = await DBInvoiceRefactor().getAllInvoices();
    allInvoices = data;
    activeInvoices = data;
    data.forEach((i) {
      this.invoicesTotal += i.total;
      if (i.docStatus == DOCSTATUS.SAVED) {
        this.savedInvoices.add(i);
        this.savedInvoicesTotal += i.total;
      }
      if (i.docStatus == DOCSTATUS.PAID) {
        this.paidInvoices.add(i);
        this.paidInvoicesTotal += i.total;
      }
    });
    isLoading = false;
    setState(() {});
  }

  void resetData() {
    paidInvoices = [];
    savedInvoices = [];

    invoicesTotal = 0;
    paidInvoicesTotal = 0;
    savedInvoicesTotal = 0;
  }

  void updateActiveHeaderButton(int newIndex) {
    setState(() {
      activeHeaderButton = newIndex;
    });
  }

  Future<void> setSearchResult(List<Invoice> invoices) async {
    activeHeaderButton = 3;
    activeInvoices = invoices;
    setState(() {});
  }

  void resetDefault() async {
    activeHeaderButton = 0;
    activeInvoices = allInvoices;
    await clearSelectedInvoice();
    if (mounted) setState(() {});
  }

  clearSelectedInvoice() async {
    InvoiceProvider _invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    selectedInvoice = null;
    if (_invoiceProvider.currentInvoice.id != null) {
      await _invoiceProvider.clearInvoice();
    }
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    if (!isLoading)
      return Container(
        color: isDarkMode == false ? greyColor : Color(0xff1F1F1F),
        child: Column(
          children: [
            header(),
            typeMobile == TYPEMOBILE.TABLET
                ? SizedBox(height: 8.0)
                : SizedBox(height: 0.0),
            typeMobile == TYPEMOBILE.TABLET
                ? SizedBox(height: 8.0)
                : SizedBox(height: 4.0),
            SearchAutoComplete(
              searchResultCallback: (List<Invoice> invoices) async {
                await setSearchResult(invoices);
                await clearSelectedInvoice();
              },
              resetDefault: resetDefault,
            ),
            invoicesContainer(),
          ],
        ).paddingAll(typeMobile == TYPEMOBILE.TABLET ? 10 :5 )
      );

    return Center(
      child: LoadingAnimation(
        typeOfAnimation: "staggeredDotsWave",
        color: themeColor,
        size: 100,
      ),
    );
  }

  // header
  header() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          headerButton(0, Localization.of(context).tr('all'), this.allInvoices,
              this.invoicesTotal, 'assets/invoices-list.png'),
          headerButton(1, Localization.of(context).tr('paid'),
              this.paidInvoices, this.paidInvoicesTotal, 'assets/paid.png'),
          headerButton(2, Localization.of(context).tr('saved'),
              this.savedInvoices, this.savedInvoicesTotal, 'assets/saved.png'),
        ],
      ),
    );
  }

  // header button
  Widget headerButton(int index, String title, List<Invoice> invoicesList,
      double total, String iconPath) {
    bool active = index == activeHeaderButton;
    InvoiceProvider _invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);

    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return typeMobile == TYPEMOBILE.TABLET
        ? Expanded(
            child: TextButton(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: isDarkMode == false ? Colors.white : searchColorDark,
                    border: Border.all(
                      width: 4,
                      color: active
                          ? themeColor
                          : isDarkMode == false
                              ? Colors.white
                              : searchColorDark,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(1, 5),
                        color: Colors.black12,
                        spreadRadius: 3,
                        blurRadius: 4,
                      )
                    ]),
                child: Row(
                  children: [
                    Flexible(flex: 2, child: Image.asset(iconPath)),
                    SizedBox(width: 16.0),
                    Flexible(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      '$title:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: isDarkMode == false
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '${invoicesList.length}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: isDarkMode == false
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 3,
                                color: isDarkMode == false
                                    ? Colors.black
                                    : Colors.white,
                                height: 1,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      Localization.of(context).tr('total') +
                                          ':',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: isDarkMode == false
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Flexible(
                                    child: FittedBox(
                                      child: Text(
                                        // hide total or not depend on API
                                        hideTotalAmount == '1'
                                            ? 'xxx'
                                            : '${total.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: isDarkMode == false
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ).paddingHorizontallyAndVertical(10, 5),
              ),
              onPressed: () async {
                context
                    .read<SearchAutoCompleteProvider>()
                    .setSearchSuggestion("");
                context.read<SearchAutoCompleteProvider>().clearFocus(context);
                selectedInvoice = null;
                activeHeaderButton = index;
                if (_invoiceProvider.currentInvoice.id != null) {
                  await _invoiceProvider.clearInvoice();
                }
                switch (index) {
                  case 1:
                    this.activeInvoices = this.paidInvoices;
                    setState(() {});
                    break;
                  case 2:
                    this.activeInvoices = this.savedInvoices;
                    setState(() {});
                    break;
                  case 0:
                    this.activeInvoices = this.allInvoices;
                    setState(() {});
                    break;
                  default:
                }
              },
            ),
          )
        // === Mobile ====
        : Expanded(
            child: TextButton(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDarkMode == false ? Colors.white : searchColorDark,
                  border: Border.all(
                    width: 2,
                    color: active ? themeColor : Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(1, 5),
                      color: Colors.black12,
                      spreadRadius: 3,
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Flexible(flex: 2, child: Image.asset(iconPath)),
                    // SizedBox(width: 8.0),
                    Flexible(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      '$title:',
                                      style: TextStyle(
                                        fontSize: 12, // 16
                                        color: isDarkMode == false
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${invoicesList.length}',
                                    style: TextStyle(
                                      fontSize: 12.5, // 18
                                      color: isDarkMode == false
                                          ? Colors.black
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                thickness: 1.5,
                                color: isDarkMode == false
                                    ? Colors.black12
                                    : Colors.white,
                                height: 1,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Text(
                                      Localization.of(context).tr('total') +
                                          ':',
                                      style: TextStyle(
                                        fontSize: 12, // 16
                                        color: isDarkMode == false
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: FittedBox(
                                      child: Text(
                                        // hide total or not depend on API
                                        hideTotalAmount == '1'
                                            ? 'xxx'
                                            : '${total.toStringAsFixed(2)}',
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 12.5, // 18
                                          color: isDarkMode == false
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ).paddingHorizontallyAndVertical(4, 2),
              ),
              onPressed: () async {
                context
                    .read<SearchAutoCompleteProvider>()
                    .setSearchSuggestion("");
                context.read<SearchAutoCompleteProvider>().clearFocus(context);
                selectedInvoice = null;
                activeHeaderButton = index;
                if (_invoiceProvider.currentInvoice.id != null) {
                  await _invoiceProvider.clearInvoice();
                }
                switch (index) {
                  case 1:
                    this.activeInvoices = this.paidInvoices;
                    setState(() {});
                    break;
                  case 2:
                    this.activeInvoices = this.savedInvoices;
                    setState(() {});
                    break;
                  case 0:
                    this.activeInvoices = this.allInvoices;
                    setState(() {});
                    break;
                  default:
                }
              },
            ),
          );
  }

  Widget invoicesContainer() {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    if (this.activeInvoices.length == 0) {
      return Expanded(child: const EmptyList());
    }
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: typeMobile == TYPEMOBILE.TABLET ? 14 : 4),
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        child: Container(
          alignment: Alignment.topCenter,
          // color: Colors.white,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: this.activeInvoices.length,
            itemBuilder: (BuildContext context, int index) {
              return invoice(activeInvoices[index], index);
            },
          ),
        ),
      ),
    );
  }

  int selectedInvoice;

  // get invoice content color
  Color getInvoiceContentColor(int index) {
    if (selectedInvoice == index)
      return Colors.black;
    else
      return Colors.black;
  }

  Widget invoice(Invoice invoice, int index) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    // return Container();
    return InkWell(
      child: Container(
        height: typeMobile == TYPEMOBILE.TABLET ? 145 : 100,
        margin: EdgeInsets.all(10),
        decoration: boxDecoration(index),
        child: Row(
          children: [
            invoieDetails(invoice, index),
            // selectedInvoice == index && invoice.docStatus == DOCSTATUS.SAVED
            selectedInvoice == index ? actionButtons(invoice) : const SizedBox.shrink(),
          ],
        ),
      ),
      onTap: () async {
        print('💸💸 invoice coupon_code 💸💸 ::: ${invoice.coupon_code}');
        invoiceTap(invoice, index);
      },
      onLongPress: () async {
        if (invoice.docStatus == DOCSTATUS.SAVED) {
          invoiceLongTap(invoice);
        }
      },
    );
  }

  // box decoration
  BoxDecoration boxDecoration(int index) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    Color color() {
      Color color = isDarkMode == false ? Colors.white : Colors.black54;
      return color;
    }

    return BoxDecoration(
      boxShadow: [
        BoxShadow(
            offset: Offset(2, 4),
            color: selectedInvoice == index ? themeColor : Colors.transparent,
            spreadRadius: 4,
            blurRadius: 10)
      ],
      color: selectedInvoice == index ? color() : Colors.white.withOpacity(0.8),
      // selectedInvoice == index ? Color(0xffcaf0f8) : Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );
  }

  // invoice details
  Widget invoieDetails(Invoice invoice, index) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Expanded(
        child: Container(
      // height: typeMobile == TYPEMOBILE.TABLET ? 145 : 100,
      decoration: BoxDecoration(
          color: isDarkMode == false ? Colors.white : searchColorDark,
          // borderRadius: BorderRadius.circular(12),

          borderRadius: (() {
            if (index != selectedInvoice) {
              return BorderRadius.circular(12);
            } else if (Localization.of(context).locale == Locale('ar', 'SA')) {
              return BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              );
            } else {
              return BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              );
            }
          }())
          // Localization.of(context).locale == Locale('ar', 'SA')
          //     ? BorderRadius.only(
          //         topRight: Radius.circular(12),
          //         bottomRight: Radius.circular(12),
          //       )
          //     : BorderRadius.only(
          //         topLeft: Radius.circular(12),
          //         bottomLeft: Radius.circular(12),
          //       ),
          ),
      // merge ix , they add boxDecortation but i didnt .
      child: Row(
        children: [
          invoice.isReturn == 1
              ? rotatedBox(Localization.of(context).tr('RETURNED'))
              : rotatedBox(''),
          SizedBox(width: typeMobile == TYPEMOBILE.TABLET ? 15 : 3),
          invoiceNumberAndCustomer(invoice, index),
          invoiceTotalAndDate(invoice, index),
        ],
      ).paddingAll(typeMobile == TYPEMOBILE.TABLET ? 10 :5 ),
    ));
  }

  RotatedBox rotatedBox(String text) {
    return RotatedBox(
      quarterTurns:
          Localization.of(context).locale == Locale('ar', 'SA') ? 1 : -1,
      child: Text(
        '${text}',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
      ),
    );
  }

  // invoice tap
  invoiceTap(Invoice invoice, index) async {
    if (index != selectedInvoice) {
      InvoiceProvider i = Provider.of<InvoiceProvider>(context, listen: false);

      bool clearInvoice = await i.changeActiveInvoice(context, invoice.id);
      print('clear invoice :::::: ${clearInvoice}');
      print(' invoice id :::::: ${invoice.id}');
      print(' invoice coupon_code:::::: ${invoice.docStatus}');
      if (clearInvoice == true) {
        selectedInvoice = index;
        setState(() {});

        // await widget.clearInvoice();
        TablesProvider tablesProvider =
            Provider.of<TablesProvider>(context, listen: false);
        if (invoice.selectedDeliveryApplication != null) {
          DeliveryApplicationProvider deliveryApplicationProvider =
              Provider.of<DeliveryApplicationProvider>(context, listen: false);

          deliveryApplicationProvider.clearDeliveryApplication();

          i.currentInvoice.selectedDeliveryApplication =
              await DBDeliveryApplication.getByName(
                  invoice.selectedDeliveryApplication.customer);
          deliveryApplicationProvider.setSelectedDeliveryApplication(
              i.currentInvoice.selectedDeliveryApplication);
        }
        i.currentInvoice.id = invoice.id;
        i.currentInvoice.name = invoice.name;
        i.currentInvoice.customerRefactor.customerName = invoice.customer;
        i.currentInvoice.tableNo = invoice.tableNo;
        i.currentInvoice.discountAmount = invoice.discountAmount;
        tablesProvider.selectedTableNo = invoice.tableNo;
        i.setNewId(invoice.id);
        print('${invoice.id}  d   ${invoice.name}');
        i.currentInvoice.postingDate = invoice.postingDate;
        i.currentInvoice.docStatus = invoice.docStatus;
        i.currentInvoice.id = invoice.id;
        i.currentInvoice.discountAmount = invoice.discountAmount;
        i.currentInvoice.additionalDiscountPercentage =
            invoice.additionalDiscountPercentage;
        i.currentInvoice.coupon_code = invoice.coupon_code;
      }
    }
  }

  // invoice long tap
  invoiceLongTap(Invoice invoice) async {
    InvoiceProvider i = Provider.of<InvoiceProvider>(context, listen: false);
    await widget.clearInvoice();
    await i.changeActiveInvoice(context, invoice.id);
    i.setNewId(invoice.id);
    i.currentInvoice.tableNo = invoice.tableNo;
    print(
        'invoice.additionalDiscountPercentage :>>>>>>>>>:::::::: ${invoice.additionalDiscountPercentage}');
    i.currentInvoice.id = invoice.id;
    i.currentInvoice.name = invoice.name;
    i.currentInvoice.customerRefactor.customerName = invoice.customer;
    i.currentInvoice.tableNo = invoice.tableNo;
    i.setNewId(invoice.id);
    i.currentInvoice.postingDate = invoice.postingDate;
    i.currentInvoice.docStatus = invoice.docStatus;
    i.currentInvoice.discountAmount = invoice.discountAmount;
    i.currentInvoice.additionalDiscountPercentage =
        invoice.additionalDiscountPercentage;
    print("coupon_code coupon_code coupon_code ::: ${invoice.coupon_code}");
    print(
        "i.currentInvoice.coupon_code ::: i.currentInvoice.coupon_code ${i.currentInvoice.coupon_code}");
    i.currentInvoice.coupon_code = invoice.coupon_code;
    context.read<HomeProvider>().setMainIndex(0);
  }

  // action button
  Widget actionButtons(Invoice invoice) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode == false ? Colors.white : searchColorDark,
        borderRadius: Localization.of(context).locale == Locale('ar', 'SA')
            ? BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              )
            : BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
      ),
      width: 54,
      height: typeMobile == TYPEMOBILE.TABLET ? 145 : 100,
      child: invoice.docStatus == DOCSTATUS.SAVED
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [deleteInvoice(), editInvoice(invoice)],
            )
          : invoice.isReturn == 1
              ? const Nil()
              : Container(child: returnInvoice(invoice)),
    );
  }

  Widget invoiceNumberAndCustomer(Invoice invoice, int index) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    DeliveryApplication deliveryApplication = this
        .deliveryApplications
        .firstWhere(
            (e) => e.customer == invoice.selectedDeliveryApplication?.customer,
            orElse: () => null);
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invoice.name == null ? invoice.id.toString() : invoice.name,
          style: TextStyle(
              color: invoice.name == null || invoice.isSynced == 0
                  ? Colors.black
                  : themeColor,
              fontSize: typeMobile == TYPEMOBILE.TABLET ? 20 : 14),
        ),
        SizedBox(
          height: typeMobile == TYPEMOBILE.TABLET ? 28 : 8,
        ),
        deliveryApplication != null
            ? deliveryAppIcon(deliveryApplication)
            : Row(
                children: [
                  Image.asset(
                    'assets/side-menu/user.png',
                    color: getInvoiceContentColor(index),
                  ),
                  SizedBox(
                    width: typeMobile == TYPEMOBILE.TABLET ? 10 : 3,
                  ),
                  invoice.tableNo == null
                      ? Text(
                          '${invoice.customer} - Take away',
                          style: TextStyle(
                            fontSize: typeMobile == TYPEMOBILE.TABLET ? 14 : 11,
                          ),
                        )
                      : Text(
                          '${invoice.customer} - Table No: ${invoice.tableNo}',
                          style: TextStyle(
                            fontSize: typeMobile == TYPEMOBILE.TABLET ? 16 : 11,
                          ),
                        )
                ],
              ),
      ],
    ));
  }

  Widget deliveryAppIcon(DeliveryApplication deliveryApplication) {
    return Row(
      children: [
        deliveryApplication.icon != '' && deliveryApplication.icon != null
            ? Image.network(
                this.baseUrl + deliveryApplication.icon,
                width: 40,
              )
            : const SizedBox.shrink(),
        // Image.network(
        //   this.baseUrl + deliveryApplication.icon,
        //   width: 40,
        // ),
        SizedBox(width: 10),
        Text(
          deliveryApplication.customer,
          style: TextStyle(fontSize: 16),
        )
      ],
    );
  }

  // invoiec total
  Widget invoiceTotalAndDate(Invoice invoice, int index) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    DateTime dateTime = DateTime.parse(invoice.postingDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // merge ix , they remove getInvoiceContentColor function
        Text(
          invoice.total.toStringAsFixed(2),
          style: TextStyle(fontSize: 20, color: getInvoiceContentColor(index)),
        ),
        SizedBox(
          height: 28,
        ),
        Text(
          DateFormat('yyyy-MM-dd – kk:mm').format(dateTime),
          style: TextStyle(color: getInvoiceContentColor(index)),
        )
      ],
    );
  }

  Widget delete(Invoice invoice, int index) {
    DateTime dateTime = DateTime.parse(invoice.postingDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          alignment: Alignment.topCenter,
          height: 50,
          child:
              selectedInvoice == index && invoice.docStatus == DOCSTATUS.SAVED
                  ? deleteInvoice()
                  : Container(),
        ),
        SizedBox(
          height: 12,
        ),
        Text(
          DateFormat('yyyy-MM-dd – kk:mm').format(dateTime),
          style: TextStyle(color: getInvoiceContentColor(index)),
        )
      ],
    );
  }

  // delete button
  Widget deleteInvoice() {
    return InkWell(
      child: Container(
        child: Icon(
          Icons.delete,
          color: Colors.red,
        ),
      ).paddingAllNormal(),
      onTap: () {
        deleteInvoiceDialog();
      },
    );
  }

  // edit button
  Widget returnInvoice(Invoice invoice) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return InkWell(
      child: Container(
        // merge ix , they add CircleAvatar but i didnt
        child: Icon(
          Icons.arrow_drop_down_circle,
          size: typeMobile == TYPEMOBILE.TABLET ? 37 : 20,
          color: isDarkMode == false ? Colors.grey : Colors.black54,
        ).paddingAllNormal(),
      ),
      onTap: () {
        print(invoice.name);
        // ReturnPage(invoice: args)
        Navigator.pushNamed(context, '/return-invioce', arguments: invoice);
        // MyAppState.navigatorKey.currentState.pushNamed('/return-invioce');
      },
    );
  }

  // edit button
  Widget editInvoice(Invoice invoice) {
    return InkWell(
      child: Container(
        child: Icon(Icons.edit, color: Colors.black54).paddingAllNormal(),
      ),
      onTap: () {
        invoiceLongTap(invoice);
      },
    );
  }

  // delete invoice function
  deleteInvoiceDialog() async {
    Invoice invoice = await showDialog(
      context: context,
      builder: (_) {
        return ConfirmDialog(
          bodyText: Localization.of(context).tr('on_tab_delete_invoice_button'),
          icon: Image.asset('assets/delete.png'),
          onConfirm: () {
            onConfirmdDeleteInvoice();
          },
        );
      },
    );
    if (invoice?.name != null) {
      await Future.delayed(Duration(milliseconds: 600), () {
        InvoiceProvider().deleteInvoiceFromServer(context, invoice);
      });
    }
  }

  onConfirmdDeleteInvoice() async {
    InvoiceProvider invoiceProvider = context.read<InvoiceProvider>();
    Invoice invoice = invoiceProvider.currentInvoice;
    try {
      await InvoiceRepositoryRefactor()
          .deleteInvoice(invoiceProvider.currentInvoice);
      await DBInvoiceRefactor().isSynced(invoiceProvider.currentInvoice.id, 0);
      selectedInvoice = null;
      resetData();
      activeHeaderButton = 0;
      await getInvoices();
      toast('Invoice deleted', blueColor);
      await widget.clearInvoice();
      context
          .read<InvoiceProvider>()
          .setNewId(await InvoiceRepositoryRefactor().getNewInvoiceId());
      Navigator.pop(context, invoice);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
      toast(Localization.of(context).tr('error'), Colors.red);
    }
  }
}
