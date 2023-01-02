import 'dart:convert';
import 'dart:io';

import 'package:app/core/enums/enums.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/db-operations/db.tables.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/models/coupon.dart';
import 'package:app/modules/pay-dialog/models/payment.method.dart';
import 'package:app/providers/home.provider.dart';
import 'package:app/services/auth.service.dart';
import 'package:app/services/invoice.refactor.service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/toas.dart';
import '../invoice.dart';
import 'package:path_provider/path_provider.dart';

class InvoiceRepositoryRefactor {
  DBInvoiceRefactor _dbInvoiceRefactor = DBInvoiceRefactor();
  DBTaxes _dbTaxes = DBTaxes();
  DBItems _dbItems = DBItems();
  InvoiceRefactorService _invoiceRefactorService = InvoiceRefactorService();

  Future<String> getInvoicesDirectoryPath() async {
    //Get this App Document Directory
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/invoices/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  Future<File> invoiceFile(invoiceId) async {
    String invoicesPath = await getInvoicesDirectoryPath();
    return File('$invoicesPath/$invoiceId.json');
  }

  Future<File> writeInvoice(Map json) async {
    final file = await invoiceFile(json['offline_invoice']);
    return file.writeAsString("$json");
  }

  Future syncInvoices() async {
    var now = DateTime.now();
    List<Invoice> notSyncedInvoices =
        await _dbInvoiceRefactor.getAllNotSyncedInvoices();
    if (notSyncedInvoices.length == 0) print("all invoices are synced!");
    for (Invoice invoice in notSyncedInvoices) {
      // convert invoiceDateTime string to DateTime Format to be able to get tge difference between now and invoiceTime
      DateTime tempDate =
          new DateFormat("yyyy-MM-dd HH:mm:ss").parse(invoice.postingDate);
      var dif = now.difference(tempDate).inMinutes;
      print(
          "invoice.postingDate :::::: ${tempDate} and now is ::::::::: ${now.toString()}");
      print("dif dif dif :::::: ${dif}");
      if (dif >= 1) {
        print('synced after ${dif}');
        if (invoice.deleted == 0) {
          try {
            Invoice completeInvoice =
                await _dbInvoiceRefactor.getCompleteInvoice(id: invoice.id);
            await sendInvoice(completeInvoice);
            print("🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖 Im 1 🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖");
            await _dbInvoiceRefactor.isSynced(invoice.id, 1);
            print("Invoice id: ${invoice.id} is synced");
          } on Failure catch (e, stackTrace) {
            await Sentry.captureException(
              e,
              stackTrace: stackTrace,
            );
            print("Could'nt sync invoice id: ${invoice.id}");
            throw e;
          }
        } else if (invoice.name != null && invoice.deleted == 1) {
          try {
            await _invoiceRefactorService.deleteInvoice(invoice.name);
            print("🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖 Im 2 🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖");
            await _dbInvoiceRefactor.isSynced(invoice.id, 1);
            print("Invoice id: ${invoice.id} is deleted");
          } on Failure catch (e, stackTrace) {
            await Sentry.captureException(
              e,
              stackTrace: stackTrace,
            );
            print("Could'nt sync(delete) invoice id: ${invoice.id}");
            throw e;
          }
        }
      }
    }
  }

  Future<String> sendInvoice(Invoice invoice, {BuildContext context}) async {
    await addItemsOptionsAsInvoiceItems(invoice);
    print('${invoice.total} :::: ${invoice.additionalDiscountPercentage}');
    String name = await _invoiceRefactorService.sendInvoiceToServer(invoice,
        context: context);
    print("name name name name :: ${name}");
    if (name != null) {
      if (invoice.name == null)
        await _dbInvoiceRefactor.updateInvoiceNameFromServer(invoice.id, name);
      print("🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖 Im 3 🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖");
      await _dbInvoiceRefactor.isSynced(invoice.id, 1);
    }
    return name;
  }

  Future<Coupon> checkCoupon(String couponCode) async {
    try {
      Coupon coupon =
          await _invoiceRefactorService.checkCouponService(couponCode);
      return coupon;
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print("Coupon error ${e}");
      throw e;
    }
  }

  Future<int> getNewInvoiceId() async {
    return await DBInvoice.getInvoicesLength() + 1;
  }

  // before sending invoice to server
  // add invoice itemsOptionsWith list to invoice items list
  Future<Invoice> addItemsOptionsAsInvoiceItems(Invoice invoice) async {
    for (Item item in invoice.items) {
      List<ItemOption> itemOptions =
          await DBItemOptions().getItemOptionsOfInvoice(item.uniqueId);

      List itemOptionsList = [];
      for (ItemOption itemOption in itemOptions) {
        Map<String, dynamic> map = itemOption.toJson();
        itemOptionsList.add(JsonEncoder.withIndent('  ').convert(map));
      }
      item.itemOptions = "$itemOptionsList";
    }

    List<ItemOption> itemOptions =
        await DBItemOptions().getItemsOptionsOfInvoice(invoice.id);
    for (ItemOption itemOption
        in itemOptions.where((e) => e.optionWith == 1).toList()) {
      Item item = Item(
          itemCode: itemOption.itemCode,
          qty: invoice.items
              .firstWhere(
                  (element) => element.uniqueId == itemOption.itemUniqueId)
              .qty,
          isSup: 1);

      invoice.items.add(item);
    }
    return invoice;
  }

  Future<int> saveInvoiceRefactor(
      Invoice invoice, List<PaymentMethodRefactor> payments) async {
    int invoiceId;
    invoice = invoice..payments = payments;
    print("delivery app payments ??? :${invoice.payments}");

    print(invoice.paidTotal);
    print("saveInvoiceRefactor 2 isReturn  ::::::::::: ${invoice.isReturn}");
    if (invoice.id == null) {
      invoiceId = await saveInvoiceDataReafactor(invoice, payments);
    } else if (invoice.id != null) {
      invoiceId = invoice.id;
      print("DB TOTAL THAT WILL INSERT :::::::::: ${invoice.total}");
      await updateInvoiceRefactor(invoice, payments);
    }
    print("☎️☎☎️☎☎️☎☎️☎☎️☎☎️☎saveInvoiceRefactor FUNC ::: invoice.offlineInvoice ================== ${invoice.offlineInvoice} ☎️☎☎️☎☎️☎☎️☎☎️☎☎️☎☎️☎☎️☎");
    if (invoice.docStatus == DOCSTATUS.PAID && invoice.tableNo != null)
      await DBDineInTables().releaseTable(invoice.tableNo);
    print("🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖 Im 4 🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖");
    await _dbInvoiceRefactor.isSynced(invoiceId, 0);
    return invoiceId;
  }

  Future<int> saveReturnRepo(Invoice invoice,
      List<PaymentMethodRefactor> payments, BuildContext context) async {
    InvoiceProvider invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    invoiceProvider.setReturnLoadingValue(true);
    int invoiceId;
    invoice = invoice..payments = payments;

    if (invoice.tableNo != null)
      await DBDineInTables().releaseTable(invoice.tableNo);
    invoiceId = await saveReturn(invoice, payments);
    return invoiceId;
  }

  Future<int> saveReturn(
      Invoice invoice, List<PaymentMethodRefactor> payments) async {
    int invoiceId;

    print("saveReturn");
    print("${invoice.total}");

    // save invoice to sqlite
    invoiceId = await _dbInvoiceRefactor.saveInvoice(invoice,
        docstatus: invoice.docStatus);
    print("DDDDDDDDDDDDDDDDDD ${invoice.total}");

    // save items
    List<Item> items =
        invoice.itemsList.map((e) => e..invoiceId = invoiceId).toList();
    await _dbItems.addItemsToInvoice(items);

    // save items options
    List<ItemOption> itemsOptions = [];

    for (Item item in items) {
      for (ItemOption itemOptionOfItem
          in item.itemOptionsWith.where((e) => e.selected)) {
        ItemOption itemOption = itemOptionOfItem;
        itemOption..invoiceId = invoiceId;
        itemOption..itemUniqueId = item.uniqueId;
        itemOption..optionWith = 1;
        itemsOptions.add(itemOption);
      }
      for (ItemOption itemOptionOfItem
          in item.itemOptionsWithout.where((e) => e.selected)) {
        ItemOption itemOption = itemOptionOfItem;
        itemOption..invoiceId = invoiceId;
        itemOption..itemUniqueId = item.uniqueId;
        itemOption..priceListRate = 0.0;
        itemOption..optionWith = 0;
        itemsOptions.add(itemOption);
      }
    }

    for (ItemOption itemOption in itemsOptions) {
      await DBItemOptions().addItemOptionOfInvoice(itemOption);
    }

    // save taxes
    await _dbTaxes.saveTaxes(invoiceId, invoice);

    // save payments
    if (invoice.payments == null) {
      Payment defaultPayment = await getDefaultyPeyment();
      defaultPayment..invoiceId = invoiceId;
      await DBPayments().addPaymentOfInvoice(defaultPayment);
    } else {
      await DBPayments().addPaymentsToInvoiceRefactor(payments, invoiceId);
    }

    print("invnnvnvnvnvn ${invoice.total}");
    // save invoice total , debug point
    await DBInvoiceRefactor().saveInvoiceTotal(invoiceId, items, invoice);
    print("invnnvnvnvnvn ${invoice.total}");
    Invoice completeInvoice =
        await _dbInvoiceRefactor.getCompleteInvoice(id: invoiceId);
    print("invnnvnvnvnvn ${invoice.total}");
    await writeInvoice(completeInvoice.toJson());
    return invoiceId;
  }

  Future<int> saveInvoiceDataReafactor(
      Invoice invoice, List<PaymentMethodRefactor> payments) async {
    int invoiceId;
    if (invoice.id == null) {
      print("saveInvoiceDataReafactor");
      var now = DateTime.now();
      print("saveInvoiceDataReafactor saveInvoiceDataReafactor     ${now}   ");
      print("invoice.paidTotal :::::: ${invoice.paidTotal}");

      // save invoice to sqlite
      invoiceId = await _dbInvoiceRefactor.saveInvoice(invoice,
          docstatus: invoice.docStatus);
      print("DDDDDDDDDDDDDDDDDD ${invoiceId}");
    } else {
      invoiceId = invoice.id;
      // update docstatus
      await DBInvoiceRefactor().updateDocStatus(invoice.docStatus, invoiceId);
    }

    // save items
    List<Item> items =
        invoice.itemsList.map((e) => e..invoiceId = invoiceId).toList();
    await _dbItems.addItemsToInvoice(items);

    // save items options
    List<ItemOption> itemsOptions = [];

    for (Item item in items) {
      for (ItemOption itemOptionOfItem
          in item.itemOptionsWith.where((e) => e.selected)) {
        ItemOption itemOption = itemOptionOfItem;
        itemOption..invoiceId = invoiceId;
        itemOption..itemUniqueId = item.uniqueId;
        itemOption..optionWith = 1;
        itemsOptions.add(itemOption);
      }
      for (ItemOption itemOptionOfItem
          in item.itemOptionsWithout.where((e) => e.selected)) {
        ItemOption itemOption = itemOptionOfItem;
        itemOption..invoiceId = invoiceId;
        itemOption..itemUniqueId = item.uniqueId;
        itemOption..priceListRate = 0.0;
        itemOption..optionWith = 0;
        itemsOptions.add(itemOption);
      }
    }

    for (ItemOption itemOption in itemsOptions) {
      await DBItemOptions().addItemOptionOfInvoice(itemOption);
    }

    // save taxes
    await _dbTaxes.saveTaxes(invoiceId, invoice);

    // save payments
    if (invoice.payments == null) {
      Payment defaultPayment = await getDefaultyPeyment();
      defaultPayment..invoiceId = invoiceId;
      await DBPayments().addPaymentOfInvoice(defaultPayment);
    } else {
      await DBPayments().addPaymentsToInvoiceRefactor(payments, invoiceId);
    }

    print("invnnvnvnvnvn ${invoice.discountAmount}");
    print("invnnvnvnvnvn ${invoice.total}");
    // save invoice total , debug point
    await DBInvoiceRefactor().saveInvoiceTotal(invoiceId, items, invoice);
    Invoice completeInvoice =
        await _dbInvoiceRefactor.getCompleteInvoice(id: invoiceId);
    await writeInvoice(completeInvoice.toJson());
    return invoiceId;
  }

  Future updateInvoiceRefactor(
      Invoice invoice, List<PaymentMethodRefactor> payments) async {
    await DBItems().deleteItemsOfInvoice(invoice.id);
    await DBItemOptions().deleteItemsOptionsOfInvoice(invoice.id);
    await DBTaxes().deleteTaxesOfInvoice(invoice.id);
    await DBPayments().deletePaymentsOfInvoice(invoice.id);
    await saveInvoiceDataReafactor(invoice, payments);
  }

  Future<Payment> getDefaultyPeyment() async {
    List<PaymentMethod> paymentMethods =
        await DBPaymentMethod().getPaymentMethods();

    PaymentMethod defaultPaymentMethod =
        paymentMethods.firstWhere((pm) => pm.defaultPaymentMode == 1);

    Payment defaultPayment = Payment(
      defaultPaymentMode: defaultPaymentMethod.defaultPaymentMode,
      modeOfPayment: defaultPaymentMethod.modeOfPayment,
      type: defaultPaymentMethod.type,
      account: defaultPaymentMethod.account,
    );
    return defaultPayment;
  }

  Future deleteInvoice(Invoice invoice) async {
    await DBInvoiceRefactor().deleteInvoice(invoice.id);
    // return await _invoiceRefactorService.deleteInvoice(invoice) != null;
  }

  Future deleteInvoiceFromServer(Invoice invoice) async {
    await _invoiceRefactorService.deleteInvoice(invoice.name);
    print("🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖 Im 5 🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖");
    await DBInvoiceRefactor().isSynced(invoice.id, 1);
  }

  Future<PaymentsInfo> getPayments(Invoice invoice) async {
    List<Payment> payments = [];
    double paidTotal = 0;

    if (invoice.docStatus == DOCSTATUS.SAVED) {
      List<PaymentMethod> paymentMethods =
          await DBPaymentMethod().getPaymentMethods();

      PaymentMethod defaultPaymentMethod =
          paymentMethods.firstWhere((pm) => pm.defaultPaymentMode == 1);

      Payment defaultPayment = Payment(
        defaultPaymentMode: defaultPaymentMethod.defaultPaymentMode,
        modeOfPayment: defaultPaymentMethod.modeOfPayment,
        type: defaultPaymentMethod.type,
        account: defaultPaymentMethod.account,
      );

      payments.add(defaultPayment);
    } else if (invoice.docStatus == DOCSTATUS.PAID) {
      List<Payment> paymentsOfInvoice =
          await DBInvoiceRefactor().getPaymentsOfInvoice(invoice.id);

      paymentsOfInvoice.forEach((p) {
        // return invoice
        if (invoice.isReturn == 1) {
          payments.add(p);
          paidTotal += p.amount;
        }
        // regular invoice
        if (p.amount > 0) {
          payments.add(p);
          paidTotal += p.amount;
        }
      });
    }

    return PaymentsInfo(payments, paidTotal);
  }

  discountAmountFromSharedPref() async {
    double discountAmount;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    discountAmount = sharedPreferences.getDouble('discount_amount');
    return discountAmount;
  }

  applyDiscountOn() async {
    String applyDiscount_on;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    applyDiscount_on = sharedPreferences.getString('apply_discount_on');
    return applyDiscount_on;
  }

  // get invioce totals
  InvoiceTotal calculateInvoice(
      List<Item> invoiceItems, List<SalesTaxesDetails> salestaxesDetails,
      {String applyDiscountOn, double discountAmount}) {
    double itemOptionsPriceTotal = 0;
    discountAmount != null
        ? discountAmount = discountAmount
        : discountAmount = 0;
    // print(":::::::: DISC AMOUNT : ${discountAmount}");
    for (Item item in invoiceItems) {
      for (ItemOption itemOptionWith
          in item.itemOptionsWith.where((element) => element.selected)) {
        itemOptionsPriceTotal += itemOptionWith.priceListRate * item.qty;
      }
    }

    // // get items of invioce
    List items = invoiceItems.map((e) => e.toMap()).toList();

    // // get itemsPriceTotal
    double itemsPriceTotal = itemOptionsPriceTotal;
    items.forEach((item) {
      itemsPriceTotal += item['rate'] * item['qty'];
    });
    double amount = 10;

    double vat = 0;
    double netTotal = itemsPriceTotal - discountAmount;
    double totalWithVat = 0;
    double rate = 0;

    salestaxesDetails
        .forEach((t) => {if (t.includedInPrintRate == 1) rate += t.rate});

    if (rate > 0) netTotal = ((netTotal * 100.0) / (100.0 + rate));
    print(netTotal);
    for (int i = 0; i < salestaxesDetails.length; i++) {
      switch (salestaxesDetails[i].chargeType) {
        case "On Net Total":
          double taxAmount = netTotal * salestaxesDetails[i].rate / 100;
          vat += taxAmount;
          totalWithVat = netTotal + vat;
          break;
      }
    }

    print('💰 💰 itemsPriceTotal 💰💰: ${itemsPriceTotal}');
    return InvoiceTotal(
      total: itemsPriceTotal,
      vat: vat,
      totalWithVat: totalWithVat,
    );
  }
}

class PaymentsInfo {
  final List<Payment> payments;
  final double paidTotal;

  PaymentsInfo(
    this.payments,
    this.paidTotal,
  );
}

class InvoiceTotal {
  final double total;
  final double vat;
  final double totalWithVat;

  InvoiceTotal({
    this.total,
    this.vat,
    this.totalWithVat,
  });
}
