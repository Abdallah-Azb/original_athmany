import 'dart:convert';

import 'package:app/core/enums/enums.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/db-operations/db.tables.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/pay-dialog/models/payment.method.dart';
import 'package:app/services/invoice.refactor.service.dart';

import '../invoice.dart';

class InvoiceRepositoryRefactor {
  DBInvoiceRefactor _dbInvoiceRefactor = DBInvoiceRefactor();
  DBTaxes _dbTaxes = DBTaxes();
  DBItems _dbItems = DBItems();
  InvoiceRefactorService _invoiceRefactorService = InvoiceRefactorService();

  // Future sendInvoice(Invoice invoice) async {
  //   await addItemsOptionsAsInvoiceItems(invoice);
  //   String name = await _invoiceRefactorService.sendInvoiceToServer(invoice);
  //   if (name != null) {
  //     if (invoice.name == null)
  //       await DBInvoiceRefactor().updateInvoiceNameFromServer(invoice.id, name);
  //     await _dbInvoiceRefactor.isSynced(invoice.id, 1);
  //   }
  //   return name;
  // }

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

  // Future<bool> sendEditedInvoiceToServer(Invoice invoice) async {
  //   String name;
  //   Invoice updatedInvoice = await editSavedInvoice(invoice);

  //   if (invoice.name != null || invoice.name.isNotEmpty) {
  //     name = await _invoiceRefactorService.editSavedInvoice(updatedInvoice);

  //     if (name != null) {
  //       await _dbInvoiceRefactor.isSynced(updatedInvoice.id, 1);
  //     }
  //   }

  //   List<ItemOption> itemOptionsWith = [];
  //   for (Item item in updatedInvoice.items) {
  //     for (ItemOption itemOptionWith in item.itemOptionsWith) {
  //       itemOptionsWith.add(itemOptionWith);
  //     }
  //   }

  //   await _dbInvoiceRefactor.saveInvoiceTotal(
  //       updatedInvoice.id, updatedInvoice.items);

  //   return name != null;
  // }

  Future saveInvoiceRefactor(
      Invoice invoice, List<PaymentMethodRefactor> payments) async {
    invoice = invoice..payments = payments;
    if (invoice.id == null) {
      await saveNewInvoiceRefactor(invoice, payments);
    } else if (invoice.id != null) {
      await updateInvoiceRefactor(invoice, payments);
    }
    if (invoice.docStatus == DOCSTATUS.PAID && invoice.tableNo != null)
      await DBDineInTables().releaseTable(invoice.tableNo);
  }

  Future saveNewInvoiceRefactor(
      Invoice invoice, List<PaymentMethodRefactor> payments) async {
    int invoiceId;
    if (invoice.id == null) {
      // save invoice to sqlite
      invoiceId = await _dbInvoiceRefactor.saveInvoice(invoice,
          docstatus: invoice.docStatus);
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
    if (invoice.docStatus == DOCSTATUS.PAID) {
      await DBPayments().addPaymentsToInvoiceRefactor(payments, invoiceId);
    } else {
      Payment defaultPayment = await getDefaultyPeyment();
      defaultPayment..invoiceId = invoiceId;
      await DBPayments().addPaymentOfInvoice(defaultPayment);
    }

    // save invoice total
    await DBInvoiceRefactor().saveInvoiceTotal(invoiceId, items,invoice);
  }

  Future updateInvoiceRefactor(
      Invoice invoice, List<PaymentMethodRefactor> payments) async {
    await DBItems().deleteItemsOfInvoice(invoice.id);
    await DBItemOptions().deleteItemsOptionsOfInvoice(invoice.id);
    await DBTaxes().deleteTaxesOfInvoice(invoice.id);
    await DBPayments().deletePaymentsOfInvoice(invoice.id);
    await saveNewInvoiceRefactor(invoice, payments);
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

  Future payInvoice(Invoice invoice, List<Payment> incomingPayment) async {
    // invoice = invoice..docStatus = DOCSTATUS.PAID;

    // if (invoice.id == null) {
    //   Invoice savedInvoice =
    //       await saveInvoice(invoice..payments = incomingPayment);

    //   await DBPayments().deletePaymentsOfInvoice(savedInvoice.id);
    //   await DBPayments().addPaymentsToInvoice(
    //       incomingPayment.map((e) => e..invoiceId = savedInvoice.id).toList());

    //   await sendInvoice(savedInvoice..payments = incomingPayment);
    // } else {
    //   await DBPayments().deletePaymentsOfInvoice(invoice.id);
    //   await DBPayments().addPaymentsToInvoice(
    //       incomingPayment.map((e) => e..invoiceId = invoice.id).toList());

    //   await sendEditedInvoiceToServer(invoice..payments = incomingPayment);
    // }

    // if (invoice.tableNo != null) {
    //   await DBDineInTables().releaseTable(invoice.tableNo);
    // }
  }

  Future<bool> deleteInvoice(Invoice invoice) async {
    // return await _invoiceRefactorService.deleteInvoice(invoice) != null;
  }

  // Future<Invoice> saveInvoice(Invoice invoice) async {
  //   int invoiceId = await _dbInvoiceRefactor.saveInvoice(invoice,
  //       docstatus: invoice.docStatus);

  //   List<Item> items =
  //       invoice.itemsList.map((e) => e..invoiceId = invoiceId).toList();

  //   await _dbItems.addItemsToInvoice(items);

  //   List<ItemOption> itemsOptions = [];

  //   for (Item item in items) {
  //     for (ItemOption itemOptionOfItem
  //         in item.itemOptionsWith.where((e) => e.selected)) {
  //       ItemOption itemOption = ItemOption(
  //         invoiceId: invoiceId,
  //         itemUniqueId: item.uniqueId,
  //         parent: itemOptionOfItem.parent,
  //         itemCode: itemOptionOfItem.itemCode,
  //         itemName: itemOptionOfItem.itemName,
  //         priceListRate: itemOptionOfItem.priceListRate,
  //         optionWith: 1,
  //       );
  //       itemsOptions.add(itemOption);
  //     }
  //     for (ItemOption itemOptionOfItem
  //         in item.itemOptionsWithout.where((e) => e.selected)) {
  //       ItemOption itemOption = ItemOption(
  //         invoiceId: invoiceId,
  //         itemUniqueId: item.uniqueId,
  //         parent: itemOptionOfItem.parent,
  //         itemCode: itemOptionOfItem.itemCode,
  //         itemName: itemOptionOfItem.itemName,
  //         priceListRate: 0.0,
  //         optionWith: 0,
  //       );
  //       itemsOptions.add(itemOption);
  //     }
  //   }

  //   for (ItemOption itemOption in itemsOptions) {
  //     await DBItemOptions().addItemOptionOfInvoice(itemOption);
  //   }

  //   await _dbTaxes.saveTaxes(invoiceId, invoice);

  //   PaymentsInfo paymentsInfo = await getPayments(invoice..id = invoiceId);

  //   await DBPayments().addPaymentsToInvoice(
  //       paymentsInfo.payments.map((e) => e..invoiceId = invoiceId).toList());

  //   Invoice newInvoice = await _dbInvoiceRefactor.getInvoice(id: invoiceId);

  //   await DBInvoiceRefactor().saveInvoiceTotal(newInvoice.id, newInvoice.items);
  //   return newInvoice;
  // }

  // Future<Invoice> editSavedInvoice(Invoice invoice) async {
  //   await _dbInvoiceRefactor.updateInvoice(invoice);
  //   await DBInvoice.isSynced(invoice.id, 0);
  //   Invoice updatedInvoice =
  //       await _dbInvoiceRefactor.getInvoice(id: invoice.id);

  //   return updatedInvoice;
  // }

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
        if (p.amount > 0) {
          payments.add(p);
          paidTotal += p.amount;
        }
      });
    }

    return PaymentsInfo(payments, paidTotal);
  }

  // get invioce totals
  InvoiceTotal calculateInvoice(
      List<Item> invoiceItems, List<SalesTaxesDetails> salestaxesDetails) {
    double itemOptionsPriceTotal = 0;

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

    double vat = 0;
    double netTotal = itemsPriceTotal;
    double totalWithVat = 0;
    double rate = 0;

    salestaxesDetails
        .forEach((t) => {if (t.includedInPrintRate == 1) rate += t.rate});

    if (rate > 0) netTotal = ((itemsPriceTotal * 100.0) / (100.0 + rate));

    for (int i = 0; i < salestaxesDetails.length; i++) {
      switch (salestaxesDetails[i].chargeType) {
        case "On Net Total":
          double taxAmount = netTotal * salestaxesDetails[i].rate / 100;
          vat += taxAmount;
          totalWithVat = netTotal + vat;
          break;
      }
    }

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
