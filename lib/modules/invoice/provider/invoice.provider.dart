import 'dart:async';
import 'dart:developer';
import 'package:app/core/enums/enums.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/accessories/models/accessory.dart';
import 'package:app/modules/invoice/models/coupon.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/invoice/widgets/side.invoice.details.dart';
import 'package:app/modules/menuItems/menu.item.dart';
import 'package:app/modules/return/provider/return.invioce.proivder.dart';
import 'package:app/modules/tables/tables.dart';
import 'package:app/modules/pay-dialog/pay.dialog.refactor.dart';
import 'package:app/providers/providers.dart';
import 'package:app/services/invoices-service/invoice.new.dart';
import 'package:app/services/print-service/print.service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../discount-dialog/discount_dialog.dart';
import '../invoice.dart';

class InvoiceProvider extends ChangeNotifier {
  Invoice currentInvoice = Invoice.empty();
  DBItems _dbItems = DBItems();
  DBItemOptions _dbItemOptions = DBItemOptions();
  DBTaxes _dbTaxes = DBTaxes();
  int _newId;
  double returnTotal;
  double discountAmount;
  double discountPercentage;
  InvoiceTotal invoice_Total;
  IconData deleteItem = Icons.remove;
  bool isSavingInProgress = false;

  // for overlay loading on returning screen
  bool isReturnLoading = false;
  InvoiceRepositoryRefactor _invoiceRepositoryRefactor =
      InvoiceRepositoryRefactor();
  bool printInProcess = false;
  bool printLoading = false;
  bool printKitchenLoading = false;
  bool invoiceUpdated = false;
  bool isThereKitchenDevice = false;
  bool isTherePrintersDevice = false;
  bool _showItemOptions = true;
  bool get showItemOptions => _showItemOptions;
  switchShowItemOptions(bool state) {
    _showItemOptions = state;
    notifyListeners();
  }

  void setReturnLoadingValue(bool loadingValue) async {
    isReturnLoading = loadingValue;
    notifyListeners();
  }

  GlobalKey<SideInvoiceDetailsState> sideInvoice =
      GlobalKey<SideInvoiceDetailsState>();
  final GlobalKey<MenuState> menuState = GlobalKey<MenuState>();

  int get newId => _newId;
  bool get newInvoice => currentInvoice.docStatus == null;

  Future<void> handleNewOrder(context) async {
    if (currentInvoice.docStatus == DOCSTATUS.PAID ||
        (currentInvoice.id == null && currentInvoice.itemsList.length == 0)) {
      await onNewOrder(context);
    } else {
      if (this.invoiceUpdated == true) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) {
            return ConfirmDialog(
              icon: Image.asset('assets/unsave.png'),
              onConfirm: () async {
                await onNewOrder(dialogContext);
                Navigator.pop(dialogContext);
              },
              bodyText: Localization.of(context).tr('on_tab_new_order_button'),
            );
          },
        );
      } else {
        Provider.of<InvoiceProvider>(context, listen: false)
            .setInvoiceUpdated(false);
        await onNewOrder(context);
      }
    }
  }

  Future<void> save(context) async {
    if (currentInvoice.itemsList.length > 0 &&
        currentInvoice.docStatus != DOCSTATUS.PAID) {
      try {
        print(currentInvoice.itemsList.length);
        print(currentInvoice.coupon_code);
        setSavingInProgress(true);
        int invoiceId = await _invoiceRepositoryRefactor.saveInvoiceRefactor(
            currentInvoice, null);
        print("invoiceId invoiceId ${invoiceId}");
        await resetAll(context);
        setSavingInProgress(false);
        toast(Localization.of(context).tr('data_saved'), blueColor);
        await Future.delayed(Duration(milliseconds: 600), () {
          sendInvoice(context, invoiceId);
        });
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        setSavingInProgress(false);
        print("save invoice error :::: ${e.toString()}");
        toast(Localization.of(context).tr('error'), Colors.red);
      }
    }
  }

  void clearItemsList() {
    currentInvoice.itemsList.clear();
  }

  Future<String> submitReturnInvoice(
    BuildContext context,
    bool isDarkMode,
    Invoice invoice,
    ReturnInvoiceProvider returnInvoiceProvider,
    String applyDiscountOn,
  ) async {
    var i = 0;
    List<Item> returnedItems = [];
    for (i; i < returnInvoiceProvider.returnItems.length; i++) {
      if (returnInvoiceProvider.returnItems[i].returnQty != 0) {
        currentInvoice.itemsList[i].qty =
            returnInvoiceProvider.returnItems[i].returnQty * -1;
        currentInvoice.itemsList[i].rate =
            returnInvoiceProvider.returnItems[i].rate;
        returnedItems.add(currentInvoice.itemsList[i]);
      }
    }

    // assign current itemsList to currentReturnInvoice
    currentInvoice.itemsList = returnedItems;
    setInvoice(currentInvoice);

    await payReturn(
      context,
      isDarkMode,
      applyDiscountOn,
    );
  }

  void setInvoice(Invoice invoice) {
    print("::::::::: SETINVOICE :::::::::");
    print(returnTotal);
    currentInvoice.total = returnTotal * -1;
    currentInvoice.paidTotal = returnTotal * -1;
    currentInvoice.returnAgainst = invoice.name;
    currentInvoice.additionalDiscountPercentage =
        invoice.additionalDiscountPercentage;
    currentInvoice.postingDate = invoice.postingDate;
    currentInvoice.discountAmount = invoice.discountAmount;
    currentInvoice.coupon_code = invoice.coupon_code;
    currentInvoice.itemsList = invoice.itemsList;
    currentInvoice.tableNo = invoice.tableNo;
    currentInvoice.isReturn = 1;
    currentInvoice.customer = invoice.customer;
    currentInvoice.tableNo = invoice.tableNo;
    currentInvoice.isReturn = 1;
    currentInvoice.customer = invoice.customer;
    print(currentInvoice.itemsList.length);
    notifyListeners();
  }

  Future<void> saveReturn(context) async {
    try {
      int invoiceId = await _invoiceRepositoryRefactor.saveReturnRepo(
          currentInvoice, null, context);

      // clear everything
      await resetAll(context);

      // notify user about status of action
      toast(Localization.of(context).tr('data_saved'), blueColor);
      await Future.delayed(Duration(milliseconds: 10), () {
        // send invoice to server
        sendInvoice(context, invoiceId);
      });
    } catch (e) {}
  }

  Future<String> sendInvoice(context, int invoiceId, {Invoice invoice}) async {
    try {
      var now = DateTime.now();
      Invoice invoice =
          await DBInvoiceRefactor().getCompleteInvoice(id: invoiceId);
      String name = await InvoiceRepositoryRefactor()
          .sendInvoice(invoice, context: context);
      print("Name Name Name NameName NameNameNameNameName :::::::: ${name}");
      return name;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      toast(Localization.of(context).tr('server_error'), Colors.red);
    }
  }

  Future<void> deleteInvoiceFromServer(context, Invoice invoice) async {
    try {
      await InvoiceRepositoryRefactor().deleteInvoiceFromServer(invoice);
      toast(Localization.of(context).tr('data_synced_with_server'), themeColor);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      toast(Localization.of(context).tr('check_your_internet_connection'),
          Colors.red);
    }
  }

  Future<String> payReturn(
      context, bool isDarkMode, String applyDiscountOn) async {
    print(
        "pay current invoice length :::::: ${currentInvoice.itemsList.length}");
    int invoiceId;
    int deleteReturned;
    String name;
    int isReturned = currentInvoice.isReturn;
    print("${currentInvoice.isReturn} ========= ::::::::");
    invoiceId = await openReturnPayDialog(context, isDarkMode,
        applyDiscountOn: applyDiscountOn);
    // }
    if (invoiceId != null) {
      await resetAll(context);
      var now = DateTime.now();
      print("PAY PAY PAY PAY PAY PAY PAY PAY     ${now}   ");
      // printInvoice(context, invoiceId: invoiceId);
      name = await sendInvoice(context, invoiceId);

      print(" invoiceId TO POP UP ::::::::::: ${invoiceId}");

      print("========= :::::::: ${currentInvoice.isReturn} ========= ::::::::");
      if (name == null && isReturned == 1) {
        // await _dbItems.deleteItemsOfInvoice(invoiceId);
        // await _dbItemOptions.deleteItemsOptionsOfInvoice(invoiceId);
        // await _dbTaxes.deleteTaxesOfInvoice(invoiceId);
        setReturnLoadingValue(false);
        await DBInvoiceRefactor().deleteInvoicePermanently(invoiceId);
      }
      if (name != null) popAndToast(context);
      if (name == null && isReturned == 1)
        popAndToast(context, isReturned: isReturned);
    }
    return name;
  }

  popAndToast(context, {int isReturned}) {
    setReturnLoadingValue(false);
    Navigator.pop(context);
    if (isReturned == 1) {
      toast(Localization.of(context).tr('error'), Colors.red);
      return;
    }
    toast(Localization.of(context).tr('data_saved'), blueColor);
    toast(Localization.of(context).tr('data_synced_with_server'), successToast);
  }

  Future<void> pay(context, bool isDarkMode, String applyDiscountOn) async {
    String name;
    print(
        "pay current invoice length :::::: ${currentInvoice.itemsList.length}");
    if (currentInvoice.itemsList.length > 0 &&
        currentInvoice.docStatus != DOCSTATUS.PAID) {
      int invoiceId;
      if (currentInvoice.selectedDeliveryApplication != null &&
          currentInvoice.selectedDeliveryApplication.allowPayment == 0) {
        invoiceId = await confirmCreditPayDialog(context);
      } else {
        invoiceId = await openPayDialog(context, isDarkMode,
            applyDiscountOn: applyDiscountOn);
      }
      if (invoiceId != null) {
        await resetAll(context);
        var now = DateTime.now();
        print("PAY PAY PAY PAY PAY PAY PAY PAY     ${now}   ");
        printInvoice(context, invoiceId: invoiceId);
        await Future.delayed(Duration(milliseconds: 100), () async {
          name = await sendInvoice(context, invoiceId);

          // to delete dublicate invoice if server said its dublicate
          print("name name dublicate ::::: ${name}");
          if (name == null) await DBInvoiceRefactor().deleteInvoice(invoiceId);
          toast(Localization.of(context).tr('data_synced_with_server'),
              successToast);
        });
      }
    }
  }

  Future<void> discount(
      context, bool isDarkMode, String applyDiscountOn) async {
    // checkCoupon
    print("discount model is : ${currentInvoice.coupon_code}");
    if (currentInvoice.itemsList.length > 0 &&
        currentInvoice.docStatus != DOCSTATUS.PAID) {
      bool invoiceId;
      invoiceId = await openDiscountDialog(context, isDarkMode,
          applyDiscountOn: applyDiscountOn);
      if (invoiceId != null) {}
    }
  }

  Future<void> payAndPrintFotKitchen(context) async {
    if (currentInvoice.itemsList.length > 0 &&
        currentInvoice.docStatus != DOCSTATUS.PAID) {
      int invoiceId;
      if (currentInvoice.selectedDeliveryApplication != null &&
          currentInvoice.selectedDeliveryApplication.allowPayment == 0) {
        invoiceId = await confirmCreditPayDialog(context);
      } else {
        invoiceId = await openPayDialog(context, true);
      }
      if (invoiceId != null) {
        await resetAll(context);
        printInvoice(context, invoiceId: invoiceId);
        await Future.delayed(Duration(milliseconds: 600), () {
          sendInvoice(context, invoiceId);
        });
      }
    }
  }

  confirmCreditPayDialog(context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
            onConfirm: () async {
              currentInvoice..docStatus = DOCSTATUS.PAID;
              int invoiceId = await _invoiceRepositoryRefactor
                  .saveInvoiceRefactor(currentInvoice, null);
              await resetAll(context);
              Navigator.pop(context, invoiceId);
            },
            bodyText: Localization.of(context).tr('confirm'));
      },
    );
  }

  Future<double> getIinvoiceTotal(context) async {
    InvoiceProvider invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    List<SalesTaxesDetails> salestaxesDetails =
        await DBSalesTaxesDetails().getSalesTaxeDetails();
    print('currentInvoice.itemsList.length :::::::: ');
    print('${currentInvoice.itemsList.length}');
    InvoiceTotal invoiceTotal = InvoiceRepositoryRefactor().calculateInvoice(
        invoiceProvider.currentInvoice.itemsList, salestaxesDetails);
    invoice_Total = invoiceTotal;
    notifyListeners();
    print('invoiceTotal.totalWithVat :::: ${invoiceTotal.totalWithVat}');
    return invoiceTotal.totalWithVat;
  }

  Future<double> getInvoiceGrandTotal(context) async {
    InvoiceProvider invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    List<SalesTaxesDetails> salestaxesDetails =
        await DBSalesTaxesDetails().getSalesTaxeDetails();
    InvoiceTotal invoiceTotal = InvoiceRepositoryRefactor().calculateInvoice(
        invoiceProvider.currentInvoice.itemsList, salestaxesDetails);
    invoice_Total = invoiceTotal;
    notifyListeners();
    return invoiceTotal.totalWithVat;
  }

  Future<double> getInvoiceNetTotal(context) async {
    InvoiceProvider invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    List<SalesTaxesDetails> salestaxesDetails =
        await DBSalesTaxesDetails().getSalesTaxeDetails();
    InvoiceTotal invoiceTotal = InvoiceRepositoryRefactor().calculateInvoice(
        invoiceProvider.currentInvoice.itemsList, salestaxesDetails);
    invoice_Total = invoiceTotal;
    notifyListeners();
    return invoiceTotal.total;
  }

  openPayDialog(context, bool isDarkMode,
      {String applyDiscountOn, double discountPercentage}) async {
    double invoiceTotal = await getIinvoiceTotal(context);
    if (currentInvoice.discountAmount != null)
      invoiceTotal = invoiceTotal - currentInvoice.discountAmount;
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            width: 913,
            height: 655,
            color: isDarkMode == false ? Colors.transparent : Color(0xff1F1F1F),
            // child: PayDialog(updatePayDialogOpendValue: null),
            child: PayDialogRefactor(
              invoiceTotal: invoiceTotal,
              applyDiscountOn: applyDiscountOn,
              discountAmount: discountAmount,
              isReturn: 0,
            ),
          ),
        );
      },
    );
  }

  openReturnPayDialog(context, bool isDarkMode,
      {String applyDiscountOn, double discountPercentage}) async {
    double invoiceTotal = await getIinvoiceTotal(context);
    if (currentInvoice.discountAmount != null)
      invoiceTotal = invoiceTotal - currentInvoice.discountAmount;
    print(
        "============================ ${currentInvoice.total} ============================");
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            width: 913,
            height: 655,
            color: isDarkMode == false ? Colors.transparent : Color(0xff1F1F1F),
            // child: PayDialog(updatePayDialogOpendValue: null),
            child: PayDialogRefactor(
                invoiceTotal: currentInvoice.total,
                applyDiscountOn: applyDiscountOn,
                isReturn: 1
                // discountAmount: discountAmount,
                ),
          ),
        );
      },
    );
  }

  openDiscountDialog(context, bool isDarkMode, {String applyDiscountOn}) async {
    double invoiceTotal = await getIinvoiceTotal(context);
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            width: 600,
            height: 400,
            color: isDarkMode == false ? Colors.transparent : Color(0xff1F1F1F),
            child: DiscountDialog(
              invoiceTotal: invoiceTotal,
              applyDiscountOn: applyDiscountOn,
            ),
          ),
        );
      },
    );
  }

  Future<void> printInvoice(context, {invoiceId}) async {
    if (!printLoading) {
      try {
        setPrinLoading(true);
        if (invoiceId == null) invoiceId = currentInvoice.id;
        print("invoice id ==== ${invoiceId}");
        await PrintService().printInvoice(invoiceId);
        setPrinLoading(false);
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        setPrinLoading(false);
        print('error : ${e}');
      }
    }
  }

  Future<void> SendDataToKitchen(Invoice invoice, context,
      {invoiceId, bool kitchen}) async {
    if (!printLoading) {
      print("invoice id ==== ${invoice.id}");
      try {
        setPrinLoading(true);
        print("SendDataToKitchen Provider :");
        List<Map<String, dynamic>> data = [];
        List<Item> dataa = invoice.itemsList;
        data.clear();
        log("🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖kitchen 🤖🤖🤖🤖🤖🤖🤖🤖🤖");
        for (Item item in invoice.itemsList) {
          await data.add({
            "item_code": item.itemCode.toString(),
            "item_name": item.itemName.toString(),
            "is_sup": item.isSup == null ? 0 : 1,
            "is_custom": 1,
            "description": item.descriptionSection.toString(),
            "qty": item.qty,
            "stock_uom": item.stockUom.toString(),
          });
        }
        print("SendDataToKitchen Provider ItemsData : ${data}");
        await PrintService().sendDataToKitchenService(invoice, data);
        setPrinLoading(false);
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        setPrinLoading(false);
        print('error : ${e}');
      }
    }
  }

  Future<void> printInvoiceForKitchen(context, {invoiceId}) async {
    if (!printKitchenLoading) {
      try {
        setPrintKitchenLoading(true);
        if (invoiceId == null) invoiceId = currentInvoice.id;
        List<Accessory> printers = await PrintService().getAllDevices();
        for (var printer in printers)
          if (printer.deviceFor == DeviceFor.KITCHEN)
            await PrintService().printInvoiceKitchen(invoiceId);
        //toast(Localization.of(context).tr('no_kitchen_printer'), Colors.red);
        setPrintKitchenLoading(false);
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        setPrintKitchenLoading(false);
        print(e);
      }
    }
  }

  Future<bool> checkIfThereIsKitchenDevices() async {
    List<Accessory> printers = await PrintService().getAllDevices();
    for (var printer in printers) {
      print(printer.deviceFor);
      if (printer.deviceFor == DeviceFor.KITCHEN) setKitchenAvailability(true);
    }
  }

  Future<bool> checkIfThereIsPrintersDevices() async {
    List<Accessory> printers = await PrintService().getAllDevices();
    for (var printer in printers) {
      print(printer.deviceFor);
      if (printers.length > 0) setKitchenAvailability(true);
    }
  }

  // Future<Invoice> saveInvoice(context) async {
  //   Invoice invoice;

  //   invoice = await _invoiceRepositoryRefactor.saveInvoice(currentInvoice);

  //   if (invoice != null) {
  //     await DBInvoice.isSynced(invoice.id, 0);
  //     await resetAll(context);
  //     toast(Localization.of(context).tr('data_saved'), blueColor);
  //   }
  //   return invoice;
  // }

  Future<void> onNewOrder(BuildContext context) async {
    await resetAll(context);
  }

  // add new item or update item qty
  Future<void> addItemOrUpdateItemQty(ItemOfGroup itemOfGroup) async {
    try {
      if (currentInvoice.docStatus != DOCSTATUS.PAID) {
        ClearDiscount();
        List<ItemOption> itemOptions =
            await DBItemOptions().getItemOptions(itemOfGroup.itemCode);
        List<ItemOption> itemOptionsWith =
            itemOptions.where((e) => e.optionWith == 1).toList();
        List<ItemOption> itemOptionsWithOut =
            itemOptions.where((e) => e.optionWith == 0).toList();
        Item newItem = Item().createItem(itemOfGroup,
            itemOptionsWith: itemOptionsWith,
            itemOptionsWithout: itemOptionsWithOut);
        Item item = currentInvoice.itemsList.firstWhere(
            (e) =>
                e.itemCode == newItem.itemCode &&
                e.itemOptionsWith.firstWhere((element) => element.selected,
                        orElse: () => null) ==
                    null,
            orElse: () => null);
        if (item != null) {
          await increaseItemQty(newItem.itemCode);
        } else {
          await addItem(newItem);
          this.setInvoiceUpdated(true);
        }

        // // print(item.costCenter);
        // bool itemAdded = false;
        // // check if item already added
        // currentInvoice.itemsList.forEach((i) {
        //   if (i.itemCode == newItem.itemCode) itemAdded = true;
        // });
        // // if item added icrease qty
        // if (itemAdded)
        //   await increaseItemQty(newItem.itemCode);
        // else
        //   // add new item
        //   await addItem(newItem);
        // this.setInvoiceUpdated(true);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  // add item
  Future<void> addItem(Item item, {bool scroll = true}) async {
    currentInvoice.itemsList.add(item);
    currentInvoice.lastUpdatedItem = item.itemCode;
    int itemIndex = currentInvoice.itemsList.reversed.toList().indexOf(item);
    notifyListeners();

    if (scroll) {
      await sideInvoice.currentState.scrollToIndex(itemIndex);
      await sideInvoice.currentState.highlightToIndex(itemIndex);
    }
  }

  void applyDiscount(context, String discount, double total) async {
    print(" :::::::: applyDiscount ::::::::");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // amount of discount
    double discountTotal;
    Coupon coupon = await _invoiceRepositoryRefactor.checkCoupon(discount);
    currentInvoice.coupon_code = coupon.name;

    if (coupon.rateOrDiscount == 'Discount Percentage')
      discountTotal = (coupon.discountPercentage / 100) * total;
    if (coupon.rateOrDiscount == 'Discount Amount')
      discountTotal = coupon.discountAmount;

    // if max amount not zero make DiscountTotal = max amount
    coupon.maxAmt != 0.0 ? discountTotal = coupon.maxAmt : discountTotal;

    currentInvoice.total = currentInvoice.total;

    // if the discountTotal bigger then invoice total don't apply the discount
    if (discountTotal > total) {
      toast(Localization.of(context).tr('discountBiggerThenTotalError'),
          Colors.red);
      currentInvoice.coupon_code = null;
    } else {
      currentInvoice.total = total - discountTotal;
      print(':::: totalAfterDiscount :::::::: ${currentInvoice.total}');

      print("total after discount ::::::: ${currentInvoice.total}");
      print("percentage ::::::: ${coupon.discountPercentage}");
      sharedPreferences.setDouble('discount_amount', discountTotal);

      // to empty percentage if it was filled with a value
      if (coupon.rateOrDiscount == 'Discount Amount')
        currentInvoice.additionalDiscountPercentage = null;
      if (coupon.rateOrDiscount == 'Discount Percentage')
        currentInvoice.additionalDiscountPercentage = coupon.discountPercentage;

      currentInvoice.discountAmount = discountTotal;
      discountAmount = total - currentInvoice.total;
      print(" :::::::: #### ##### ${currentInvoice.total}");
      Navigator.pop(context, true);
      toast('Discount has been applied', Colors.green);
      notifyListeners();
    }
  }

  // remove item
  void removeItem(item) {
    this.setInvoiceUpdated(true);
    ClearDiscount();
    currentInvoice.itemsList.remove(item);
    currentInvoice.lastUpdatedItem = item.uniqueId;
    notifyListeners();
  }

  void ClearDiscount() {
    print(
        "currentInvoice.discountAmount ::::: ${currentInvoice.discountAmount}");
    if (currentInvoice.discountAmount != null) {
      print("discount will be cleared");
      currentInvoice.discountAmount = null;
      currentInvoice.additionalDiscountPercentage = null;
      currentInvoice.coupon_code = null;
    }
    print(
        "=============== currentInvoice.coupon_code ::::::: ${currentInvoice.coupon_code}");
    notifyListeners();
  }

  // increase qty +
  increaseItemQty(String itemCode) async {
    this.setInvoiceUpdated(true);
    Item item = currentInvoice.itemsList.firstWhere((i) =>
        i.itemCode == itemCode &&
        i.itemOptionsWith.firstWhere((e) => e.selected, orElse: () => null) ==
            null);
    int itemIndex = currentInvoice.itemsList.reversed.toList().indexOf(item);
    item.qty += 1;
    currentInvoice.lastUpdatedItem = itemCode;
    notifyListeners();

    await sideInvoice.currentState.scrollToIndex(itemIndex);
    await sideInvoice.currentState.highlightToIndex(itemIndex);
  }

  increaseItemsFromPlus(String uniqueId) async {
    ClearDiscount();
    this.setInvoiceUpdated(true);
    Item item =
        currentInvoice.itemsList.firstWhere((i) => i.uniqueId == uniqueId);
    item.qty += 1;
    currentInvoice.lastUpdatedItem = uniqueId;
    notifyListeners();
  }

  // decrease qty -
  decreaseItemQty(String uniqueId) async {
    currentInvoice.status = 'Changed';
    print(
        'currentInvoice.discountAmount :${currentInvoice.additionalDiscountPercentage}');
    ClearDiscount();
    print(
        'currentInvoice.discountAmount :${currentInvoice.additionalDiscountPercentage}');
    notifyListeners();
    print(currentInvoice.status);
    this.setInvoiceUpdated(true);
    Item item =
        currentInvoice.itemsList.firstWhere((i) => i.uniqueId == uniqueId);

    if (item.qty != 1) {
      deleteItem = Icons.delete_forever;
      item.qty -= 1;
      currentInvoice.lastUpdatedItem = item.uniqueId;
      notifyListeners();
    }
    deleteItem = Icons.remove;
  }

  // update item qty from qty dialog
  void updateItemQty(String uniqueId, List<ItemOption> itemOptionsWith,
      List<ItemOption> itemOptionsWithout, int qty) {
    currentInvoice.status = 'Changed';
    ClearDiscount();
    notifyListeners();
    this.setInvoiceUpdated(true);
    Item item = currentInvoice.itemsList
        .firstWhere((e) => e.uniqueId == uniqueId, orElse: () => null);
    item?.qty = qty;
    item?.itemOptionsWith = itemOptionsWith;
    item?.itemOptionsWithout = itemOptionsWithout;
    notifyListeners();
  }

  // update show item options of item state
  void updateShowItemOptionsState(String uniqueId, bool state) {
    currentInvoice.status = 'Changed';
    ClearDiscount();
    notifyListeners();
    Item item = currentInvoice.itemsList
        .firstWhere((e) => e.uniqueId == uniqueId, orElse: () => null);
    item?.showOptions = state;
    notifyListeners();
  }

  void setNewId(int newId) {
    this._newId = newId;
    notifyListeners();
  }

  void setCustomer(String newCustomer, {bool newDeliveryApplication = false}) {
    currentInvoice.customer = newCustomer;

    if (!newDeliveryApplication) {
      currentInvoice.selectedDeliveryApplication = null;
    }
    notifyListeners();
  }

  void setSelectedDeliveryApplication(
      DeliveryApplication newDeliveryApplication) {
    currentInvoice.selectedDeliveryApplication = newDeliveryApplication;
    currentInvoice.tableNo = null;
  }

  void setSavingInProgress(bool state) {
    isSavingInProgress = state;
    notifyListeners();
  }

  void setPrinLoading(bool state) {
    printLoading = state;
    notifyListeners();
  }

  void setPrintKitchenLoading(bool state) {
    printKitchenLoading = state;
    notifyListeners();
  }

  void setKitchenAvailability(bool state) {
    isThereKitchenDevice = state;
    notifyListeners();
  }

  void setPrintersAvailability(bool state) {
    isTherePrintersDevice = state;
    notifyListeners();
  }

  void setInvoiceUpdated(bool state) {
    invoiceUpdated = state;
    notifyListeners();
  }

  Future<bool> changeActiveInvoice(context, int id,
      {List<Item> extraItems}) async {
    final c = Stopwatch()..start();
    bool clearInvoice = false;
    if (this.currentInvoice.id == null &&
        this.currentInvoice.itemsList.length == 0) {
      clearInvoice = true;
      await this.clearInvoice();
      await setActivatedInvoice(id, extraItems: extraItems);
      print("time elapsed 1 :::::::::: ${c.elapsed}");
      return clearInvoice;
    }
    if (this.currentInvoice.id != null && this.invoiceUpdated == false) {
      clearInvoice = true;
      await this.clearInvoice();
      await setActivatedInvoice(id, extraItems: extraItems);
      print("time elapsed 2 :::::::::: ${c.elapsed}");
      return clearInvoice;
    }
    if (this.invoiceUpdated == true) {
      if (await changeActivatedInvoiceConfirmDialog(context, id,
              extraItems: extraItems) ==
          true) {
        clearInvoice = true;
      }
    }
    print("time elapsed 3 :::::::::: ${c.elapsed}");
    return clearInvoice;
  }

  // change activated invoice confirm dialog
  Future<bool> changeActivatedInvoiceConfirmDialog(context, int id,
      {List<Item> extraItems}) async {
    // return await showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return ConfirmDialog(
    //       bodyText: "asdf",
    //       onConfirm: () async {
    //       await this.clearInvoice();
    //       setInvoiceUpdated(false);
    //       await setActivatedInvoice(id, extraItems: extraItems);
    //       Navigator.pop(context, true);
    //     });
    //   },
    // );
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return myDialog(context, id);
      },
    );
  }

  myDialog(context, int id, {List<Item> extraItems}) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      child: buttonsWrapper(context, id),
      // child: Container(
      //   width: MediaQuery.of(context).size.width * 0.5,
      //   height: 100,
      //   child: Container(
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         confirmButton(context, id),
      //         cancelButton(context)
      //         InkWell(
      //           child: Container(
      //             child: TextButton(
      //               child: Text('ACCEPT'),
      //               onPressed: () async {
      //                 await this.clearInvoice();
      //                 setInvoiceUpdated(false);
      //                 await setActivatedInvoice(id, extraItems: extraItems);
      //                 Navigator.pop(context, true);
      //               },
      //             ),
      //           ),
      //         ),
      //         InkWell(
      //           child: Container(
      //             child: TextButton(
      //               child: Text('REJECT'),
      //               onPressed: () {
      //                 Navigator.pop(context, false);
      //               },
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  buttonsWrapper(context, int id) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: [
                SizedBox(height: 24.0),
                SizedBox(
                  height: 50,
                  child: Image.asset('assets/unsave.png'),
                ),
                SizedBox(height: 16.0),
                Text(
                  Localization.of(context).tr('on_tab_new_order_button'),
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32.0),
                Row(
                  children: [
                    confirmButton(context, id),
                    cancelButton(context),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  confirmButton(context, int id, {List<Item> extraItems}) {
    return Expanded(
      child: Container(
        color: themeColor,
        child: TextButton(
          child: Text('Accept',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () async {
            await this.clearInvoice();
            setInvoiceUpdated(false);
            await setActivatedInvoice(id, extraItems: extraItems);
            Navigator.pop(context, true);
          },
        ),
      ),
    );
  }

  cancelButton(context) {
    return Expanded(
      child: Container(
        color: Colors.grey.withOpacity(0.5),
        child: TextButton(
          child: Text(
            'CANCEL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ),
    );
  }

  // get activated invioce
  Future<void> setActivatedInvoice(int id, {List<Item> extraItems}) async {
    List<Item> items = await DBInvoiceRefactor().getItemsOfInvoice(id);
    currentInvoice.id = id;

    if (extraItems != null) {
      extraItems.forEach((element) {
        Item item = items.firstWhere((e) => e.itemName == element.itemName,
            orElse: () => null);

        if (item != null) {
          item..qty += element.qty;
        } else {
          items.add(element);
        }
      });
    }

    final c = Stopwatch()..start();
    items.forEach((item) async {
      List<ItemOption> itemOptions =
          await DBItemOptions().getItemOptionsOfInvoice(item.uniqueId);

      List<ItemOption> itemOptionsWith = [];
      List<ItemOption> itemOptionsWithout = [];
      for (ItemOption itemOption in itemOptions) {
        itemOption.selected = true;
        if (itemOption.optionWith == 1) {
          itemOptionsWith.add(itemOption);
        }
        if (itemOption.optionWith == 0) {
          itemOptionsWithout.add(itemOption);
        }
      }
      item.itemOptionsWith = itemOptionsWith;
      item.itemOptionsWithout = itemOptionsWithout;

      currentInvoice.itemsList.add(item);
      currentInvoice.lastUpdatedItem = item.itemCode;
      int itemIndex = currentInvoice.itemsList.reversed.toList().indexOf(item);
      notifyListeners();

      await sideInvoice.currentState.scrollToIndex(itemIndex);
      await sideInvoice.currentState.highlightToIndex(itemIndex);
    });
    print("setActiveInvoice elapsed ::::::::: ${c.elapsed}");
  }

  Future<void> setActiveInvoieFromClosing(String name) async {
    Invoice invoice = await DBInvoiceRefactor().getCompleteInvoice(name: name);
    List<Item> items = await DBInvoiceRefactor().getItemsOfInvoice(invoice.id);
    currentInvoice.id = invoice.id;
    setNewId(invoice.id);
    currentInvoice.docStatus = invoice.docStatus;
    currentInvoice.customer = invoice.customer;

    items.forEach((item) async {
      item.itemOptionsWith = [];
      item.itemOptionsWithout = [];

      // i comment following line because it caused duplicate items when going from closing screen to specific invoice
      // addItem(item, scroll: false);
      List<ItemOption> itemOptions =
          await DBItemOptions().getItemOptionsOfInvoice(item.uniqueId);

      List<ItemOption> itemOptionsWith = [];
      List<ItemOption> itemOptionsWithout = [];
      for (ItemOption itemOption in itemOptions) {
        itemOption.selected = true;
        if (itemOption.optionWith == 1) {
          itemOptionsWith.add(itemOption);
        }
        if (itemOption.optionWith == 0) {
          itemOptionsWithout.add(itemOption);
        }
      }
      item.itemOptionsWith = itemOptionsWith;
      item.itemOptionsWithout = itemOptionsWithout;

      currentInvoice.itemsList.add(item);
      currentInvoice.lastUpdatedItem = item.itemCode;
      notifyListeners();
    });
  }

  Future<void> resetAll(BuildContext context, {bool logout = false}) async {
    MenuItemProvider menuItemProvider =
        Provider.of<MenuItemProvider>(context, listen: false);
    HomeProvider homeProvider =
        Provider.of<HomeProvider>(context, listen: false);
    DeliveryApplicationProvider deliveryApplicationProvider =
        Provider.of<DeliveryApplicationProvider>(context, listen: false);
    TablesProvider _tablesProvider =
        Provider.of<TablesProvider>(context, listen: false);
    await clearInvoice();
    menuItemProvider.resetItemGroup();
    _tablesProvider.clearTable();
    if (!logout) homeProvider.setMainIndex(0);
    if (menuState.currentState != null && !logout) {
      menuState.currentState.updateSelectedIndex(0);
    }
    deliveryApplicationProvider.clearDeliveryApplication();
  }

  // clear invoice
  Future<void> clearInvoice() async {
    int newId = await InvoiceRepositoryRefactor().getNewInvoiceId();

    print(
        "clearInvoice function currentInvoice.total : ${currentInvoice.total}");
    currentInvoice = Invoice.empty();
    print(
        "clearInvoice function currentInvoice.discountAmount : ${currentInvoice.discountAmount}");
    // currentInvoice..customer = posProfileDetails.customer;
    currentInvoice..customerRefactor = await DBCustomer().getDefaultCutomer();

    setNewId(newId);
  }
}
