import 'package:app/models/models.dart';
import 'package:app/modules/pay-dialog/models/payment.method.dart';
import 'package:app/services/services.dart';

class DBPayments {
  Future create() async {
    await DBService().createPaymentsOfInvoicesTable(db);
  }

  Future<List<Payment>> getPaymentsOfInvoice(int invoiceId) async {
    final data = await db.rawQuery(
        'SELECT * FROM payments_of_invoices WHERE FK_payment_invoice_id = ?',
        [invoiceId]);

    List<Payment> payments = data.map((e) => Payment.fromSqlite(e)).toList();

    return payments;
  }

  // add payment of invoice to sqlite
  Future addPaymentOfInvoice(Payment payment) async {
    return await db.insert('payments_of_invoices', payment.toMap());
  }

  Future addPaymentOfInvoiceRefactor(PaymentMethodRefactor payment, int invoiceId) async {
    return await db.insert('payments_of_invoices', payment.toMap(invoiceId));
  }

  Future addPaymentsToInvoice(List<Payment> payments) async {
    for (var payment in payments) {
      await addPaymentOfInvoice(payment);
    }
  }

  Future addPaymentsToInvoiceRefactor(List<PaymentMethodRefactor> payments, int invoiceId) async {
    for (var payment in payments) {
      await addPaymentOfInvoiceRefactor(payment, invoiceId);
    }
  }

  // delete payments of invoice
  Future<void> deletePaymentsOfInvoice(int invoiceId) async {
    await db.rawQuery(
        'DELETE FROM payments_of_invoices WHERE FK_payment_invoice_id = ?',
        [invoiceId]);
  }
}
