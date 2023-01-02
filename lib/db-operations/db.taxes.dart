import 'package:app/models/models.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/services/services.dart';

import 'db.operations.dart';

class DBTaxes {
  // get taxes of invoice
  Future<List<Tax>> getTaxesOfInvoice(int invoiceId) async {
    final data = await db.rawQuery(
        'SELECT * FROM taxes_of_invoices WHERE FK_tax_invoice_id = ?',
        [invoiceId]);

    List<Tax> taxes = data.map((e) => Tax.fromSqlite(e)).toList();

    return taxes;
  }

  Future create() async {
    await DBService().createTaxesOfInvoicesTable(db);
  }

  // add tax of invoice to sqlite
  Future addTaxOfInvoice(Tax tax) async {
    return await db.insert('taxes_of_invoices', tax.toMap());
  }

  

  Future addTaxesToInvoice(List taxes) async {
    for (var tax in taxes) {
      await addTaxOfInvoice(tax);
    }
  }

  // delete taxes of invoice
  Future<void> deleteTaxesOfInvoice(int invoiceId) async {
    await db.rawQuery(
        'DELETE FROM taxes_of_invoices WHERE FK_tax_invoice_id = ?',
        [invoiceId]);
  }

  Future<void> saveTaxes(int invoiceId, Invoice invoice) async {
    // get itemsPriceTotal
    double itemsPriceTotal = 0;
    invoice.itemsList.forEach((item) {
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
        invoiceId: invoiceId,
      );
      await addTaxOfInvoice(tax);
    }
  }
}
