import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/invoice.dart';

// save invoice
// Future<void> saveInvoice(Invoice invoice,
//     {bool pay = false, List<Payment> payments}) async {
//   int createdInvoiceId;
//   if (invoice.id == null) createdInvoiceId = await DBInvoice.add(invoice);
//   // save invoice table no only if invoice is new
//   if (invoice.id == null && invoice.tableNo != null)
//     await DBInvoice.reserveTable(invoice.tableNo);
//   await saveItems(invoice.id == null ? createdInvoiceId : invoice.id, invoice);
//   await saveInvoiceTotal(
//       invoice.id == null ? createdInvoiceId : invoice.id, invoice);
//   await saveTaxes(invoice.id == null ? createdInvoiceId : invoice.id, invoice);
//   if (!pay && invoice.id == null) await savePayments(createdInvoiceId);
//   if (pay)
//     await savePayments(invoice.id == null ? createdInvoiceId : invoice.id,
//         payments: payments);
// }

// save items
Future<void> saveItems(int invoiceId, InvoiceProvider invoice) async {
  if (invoice.currentInvoice.id != null)
    await DBItems().deleteItemsOfInvoice(invoice.currentInvoice.id);
  invoice.currentInvoice.itemsList.forEach((i) async {
    // print('try print item');
    // print(i.toMap());
    await DBInvoice.addItemOfInvoice(i, invoiceId);
  });
}

// save taxes
Future<void> saveTaxes(int invoiceId, InvoiceProvider invoice) async {
  if (invoice.currentInvoice.id != null)
    await DBInvoice.deleteTaxesOfInvoice(invoice.currentInvoice.id);

  // get itemsPriceTotal
  double itemsPriceTotal = 0;
  invoice.currentInvoice.itemsList.forEach((item) {
    itemsPriceTotal += item.rate * item.qty;
  });

  List<SalesTaxesDetails> salesTaxeDetails =
      await DBSalesTaxesDetails().getSalesTaxeDetails();
  double finalItemPriceTotal = 0;

  for (int i = 0; i < salesTaxeDetails.length; i++) {
    double taxAmount = salesTaxeDetails[i].rate == 0
        ? 0
        : (itemsPriceTotal * salesTaxeDetails[i].rate) / 100;
    finalItemPriceTotal += taxAmount + itemsPriceTotal;
    final Tax tax = Tax(
      chargeType: salesTaxeDetails[i].chargeType,
      accountHead: salesTaxeDetails[i].accountHead,
      description: salesTaxeDetails[i].description,
      rate: salesTaxeDetails[i].rate,
      taxAmount: taxAmount,
      total: finalItemPriceTotal,
      taxAmountAfterDiscountAmount: taxAmount,
      baseTaxAmount: taxAmount,
      baseTotal: finalItemPriceTotal,
      baseTaxAmountAfterDiscountAmount: taxAmount,
      costCenter: null,
      includedInPrintRate: salesTaxeDetails[i].includedInPrintRate,
    );
    await DBInvoice.addTaxOfInvoice(tax, invoiceId);
  }
}

// save payments
Future<void> savePayments(int invoiceId, {List<Payment> payments}) async {
  if (payments == null) {
    List<Payment> payments = [];
    List<PaymentMethod> paymentMethods =
        await DBPaymentMethod().getPaymentMethods();
    for (int i = 0; i < paymentMethods.length; i++) {
      Payment payment = Payment(
        defaultPaymentMode: paymentMethods[i].defaultPaymentMode,
        modeOfPayment: paymentMethods[i].modeOfPayment,
        icon: paymentMethods[i].icon,
        type: paymentMethods[i].type,
        account: paymentMethods[i].account,
        amount: 0,
        baseAmount: 0,
        amountStr: "0",
      );
      payments.add(payment);
    }
  } else {
    payments.forEach((p) async {
      await DBInvoice.addPaymentOfInvoice(p, invoiceId);
    });
  }
}

// save invoice total
Future<void> saveInvoiceTotal(int invoiceId, InvoiceProvider invoice) async {
  double invoiceTotal = await getInvoiceTotalWithVAT(invoice);
  await DBInvoice.updateInvoiceTotal(invoiceId, invoiceTotal);
}

// get invoice total with vat
Future<double> getInvoiceTotalWithVAT(InvoiceProvider invoice) async {
  // get taxes rate
  List<SalesTaxesDetails> salesTaxeDetailsList =
      await DBSalesTaxesDetails().getSalesTaxeDetails();
  double rate = 0;
  salesTaxeDetailsList.forEach((e) {
    rate += e.rate;
  });

  // get items of invioce
  List<Item> itemsOfInvoce = invoice.currentInvoice.itemsList;
  List items = [];
  itemsOfInvoce.forEach((i) {
    items.add(i.toMap());
  });

  // get itemsPriceTotal
  double itemsPriceTotal = 0;
  items.forEach((item) {
    itemsPriceTotal += item['rate'] * item['qty'];
  });

  return itemsPriceTotal + ((itemsPriceTotal / 100) * rate);
}
