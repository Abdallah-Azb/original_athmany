import 'dart:async';

import 'package:app/core/enums/enums.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/invoice/widgets/side.invoice.details.dart';
import 'package:app/modules/menuItems/menu.item.dart';
import 'package:app/modules/tables/tables.dart';
import 'package:app/modules/pay-dialog/pay.dialog.refactor.dart';
import 'package:app/providers/providers.dart';
import 'package:app/services/print-service/print.service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../invoice.dart';

class InvoiceProvider extends ChangeNotifier {
  Invoice currentInvoice = Invoice.empty();
  int _newId;
  bool isSavingInProgress = false;
  InvoiceRepositoryRefactor _invoiceRepositoryRefactor =
      InvoiceRepositoryRefactor();
  bool printInProcess = false;
  bool printLoading = false;
  bool invoiceUpdated = false;

  bool _showItemOptions = true;
  bool get showItemOptions => _showItemOptions;
  switchShowItemOptions(bool state) {
    _showItemOptions = state;
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
      setSavingInProgress(true);
      await _invoiceRepositoryRefactor.saveInvoiceRefactor(
          currentInvoice, null);
      await resetAll(context);
      setSavingInProgress(false);
      int invoiceId = await DBInvoiceRefactor().getLastInsertedInvoiceId();
      Invoice invoice =
          await DBInvoiceRefactor().getCompleteInvoice(id: invoiceId);
      InvoiceRepositoryRefactor().sendInvoice(invoice);

      // try {
      //   if (currentInvoice.id != null) {
      //     bool isEdited = await _invoiceRepositoryRefactor
      //         .sendEditedInvoiceToServer(currentInvoice);

      //     if (isEdited) {
      //       await resetAll(context);
      //       toast(Localization.of(context).tr('data_saved'), blueColor);
      //       await Future.delayed(Duration(milliseconds: 500), () {
      //         toast(Localization.of(context).tr('data_synced_with_server'),
      //             themeColor);
      //       });
      //     } else {
      //       await toast(Localization.of(context).tr('data_saved'), blueColor);
      //     }
      //   } else {
      //     Invoice invoice = await saveInvoice(context);
      //     await _dbInvoiceRefactor.saveInvoiceTotal(invoice.id, invoice.items);
      //     if (invoice != null) {
      //       await DBInvoice.isSynced(invoice.id, 0);
      //       String name =
      //           await _invoiceRepositoryRefactor.sendInvoice(invoice);

      //       if (name != null) {
      //         await toast(
      //             Localization.of(context).tr('data_synced_with_server'),
      //             themeColor);
      //       }
      //     }
      //   }
      //   setSavingInProgress(false);
      // } on DioError catch (e) {
      //   setSavingInProgress(false);
      //   if (e.error is SocketException || e.error is TimeoutException) {
      //     await Future.delayed(const Duration(milliseconds: 500), () {});
      //     await toast(
      //         Localization.of(context).tr('check_your_internet_connection'),
      //         orangeColor);
      //   } else {
      //     print(e.response.data);
      //     await toast(Localization.of(context).tr('server_error'), orangeColor);
      //   }
      // } catch (e) {
      //   print(e);
      //   setSavingInProgress(false);
      //   await toast(Localization.of(context).tr('error'), Colors.red);
      // }
    }
  }

  Future<void> pay(context) async {
    print('ll');
    if (currentInvoice.itemsList.length > 0 &&
        currentInvoice.docStatus != DOCSTATUS.PAID) {
      if (currentInvoice.selectedDeliveryApplication != null &&
          currentInvoice.selectedDeliveryApplication.allowPayment == 0) {
        confirmCreditPayDialog(context);
      } else {
        await openPayDialog(context);
      }
    }
  }

  confirmCreditPayDialog(context) async {
    dynamic result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
            onConfirm: () async {
              currentInvoice..docStatus = DOCSTATUS.PAID;
              await _invoiceRepositoryRefactor.saveInvoiceRefactor(
                  currentInvoice, null);
              await resetAll(context);
              Navigator.pop(context, true);
            },
            bodyText: Localization.of(context).tr('confirm'));
      },
    );
    if (result == true) {
      int invoiceId;
      if (this.currentInvoice.id != null) {
        invoiceId = this.currentInvoice.id;
        await resetAll(context);
        Invoice invoice =
            await DBInvoiceRefactor().getCompleteInvoice(id: invoiceId);
        InvoiceRepositoryRefactor().sendInvoice(invoice);
      } else {
        await resetAll(context);
        invoiceId = await DBInvoiceRefactor().getLastInsertedInvoiceId();
        Invoice invoice =
            await DBInvoiceRefactor().getCompleteInvoice(id: invoiceId);
        InvoiceRepositoryRefactor().sendInvoice(invoice);
      }
      print(invoiceId);
    }
  }

  openPayDialog(context) async {
    dynamic result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            width: 913,
            height: 655,
            // child: PayDialogRefactor(),
            // child: PayDialog(updatePayDialogOpendValue: null),
            child: PayDialogRefactor(),
            // child: PayDialog(updatePayDialogOpendValue: null),
          ),
        );
      },
    );
    if (result == true) {
      int invoiceId;
      if (this.currentInvoice.id != null) {
        invoiceId = this.currentInvoice.id;
        await resetAll(context);
        Invoice invoice =
            await DBInvoiceRefactor().getCompleteInvoice(id: invoiceId);
        InvoiceRepositoryRefactor().sendInvoice(invoice);
      } else {
        await resetAll(context);
        invoiceId = await DBInvoiceRefactor().getLastInsertedInvoiceId();
        Invoice invoice =
            await DBInvoiceRefactor().getCompleteInvoice(id: invoiceId);
        InvoiceRepositoryRefactor().sendInvoice(invoice);
      }
      print(invoiceId);
    }
  }

  Future<void> printInvoice(context) async {
    if (printLoading) {
      print('wait for print please');
    } else {
      try {
        setPrinLoading(true);
        print(currentInvoice.id);

        await PrintService().printInvoice(currentInvoice.id);

        setPrinLoading(false);

        // if (currentInvoice.id != null &&
        //     currentInvoice.itemsList.length > 0 &&
        //     !printInProcess) {
        //   _invoiceRepository.printInvoice(currentInvoice.id, kitchen: false);
        //   setPrinLoading(false);
        // }
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        setPrinLoading(false);
        print(e);
      }
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
  Future<void> addItem(Item item) async {
    currentInvoice.itemsList.add(item);
    currentInvoice.lastUpdatedItem = item.itemCode;
    int itemIndex = currentInvoice.itemsList.reversed.toList().indexOf(item);
    notifyListeners();

    await sideInvoice.currentState.scrollToIndex(itemIndex);
    await sideInvoice.currentState.highlightToIndex(itemIndex);
  }

  // remove item
  void removeItem(item) {
    this.setInvoiceUpdated(true);
    currentInvoice.itemsList.remove(item);
    currentInvoice.lastUpdatedItem = item.uniqueId;
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
    this.setInvoiceUpdated(true);
    Item item =
        currentInvoice.itemsList.firstWhere((i) => i.uniqueId == uniqueId);
    item.qty += 1;
    currentInvoice.lastUpdatedItem = uniqueId;
    notifyListeners();
  }

  // decrease qty -
  decreaseItemQty(String uniqueId) async {
    this.setInvoiceUpdated(true);
    Item item =
        currentInvoice.itemsList.firstWhere((i) => i.uniqueId == uniqueId);

    if (item.qty != 1) {
      item.qty -= 1;
      currentInvoice.lastUpdatedItem = item.uniqueId;
      notifyListeners();
    }
  }

  // update item qty from qty dialog
  void updateItemQty(String uniqueId, List<ItemOption> itemOptionsWith,
      List<ItemOption> itemOptionsWithout, int qty) {
    this.setInvoiceUpdated(true);
    Item item = currentInvoice.itemsList
        .firstWhere((e) => e.uniqueId == uniqueId, orElse: () => null);
    item?.qty = qty;
    item?.itemOptionsWith = itemOptionsWith;
    item?.itemOptionsWithout = itemOptionsWithout;
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

  void setInvoiceUpdated(bool state) {
    invoiceUpdated = state;
    notifyListeners();
  }

  Future<bool> changeActiveInvoice(context, int id,
      {List<Item> extraItems}) async {
    bool clearInvoice = false;
    if (this.currentInvoice.id == null &&
        this.currentInvoice.itemsList.length == 0) {
      clearInvoice = true;
      await this.clearInvoice();
      await setActivatedInvoice(id, extraItems: extraItems);
      return clearInvoice;
    }
    if (this.currentInvoice.id != null && this.invoiceUpdated == false) {
      clearInvoice = true;
      await this.clearInvoice();
      await setActivatedInvoice(id, extraItems: extraItems);
      return clearInvoice;
    }
    if (this.invoiceUpdated == true) {
      if (await changeActivatedInvoiceConfirmDialog(context, id,
              extraItems: extraItems) ==
          true) {
        clearInvoice = true;
      }
    }
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
  }

  Future<void> setActiveInvoieFromClosing(String name) async {
    Invoice invoice = await DBInvoiceRefactor().getCompleteInvoice(name: name);
    List<Item> items = await DBInvoiceRefactor().getItemsOfInvoice(invoice.id);
    currentInvoice.id = invoice.id;
    currentInvoice.docStatus = invoice.docStatus;
    currentInvoice.customer = invoice.customer;
    items.forEach((i) {
      addItem(i);
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

    currentInvoice = Invoice.empty();
    // currentInvoice..customer = posProfileDetails.customer;
    currentInvoice..customerRefactor = await DBCustomer().getDefaultCutomer();
    setNewId(newId);
  }
}
