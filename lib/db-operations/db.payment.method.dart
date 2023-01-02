import 'package:app/modules/pay-dialog/models/payment.method.dart';
import 'package:app/res.dart';
import 'package:app/services/db.service.dart';
import 'package:app/models/models.dart';

class DBPaymentMethod {
  // drop and create payment methods table
  Future dropAndPaymentMethodsTable() async {
    await db.execute("DROP TABLE IF EXISTS payment_methods");
    await DBService().createPaymentMethodsTable(db);
  }

  Future create() async {
    await DBService().createPaymentMethodsTable(db);
  }

  // add payment method to sqlite
  Future add(PaymentMethod paymentMethod) async {
    return await db.insert('payment_methods', paymentMethod.toSqlite());
  }

  Future addAll(List<PaymentMethod> paymentMethods) async {
    for (var paymentMethod in paymentMethods) {
      await add(paymentMethod);
    }
  }

  // get payment methods
  Future<List<PaymentMethod>> getPaymentMethods() async {
    List<PaymentMethod> paymentMethods = [];
    final sql = '''SELECT * FROM payment_methods''';
    final data = await db.rawQuery(sql);
    for (final node in data) {
      final PaymentMethod paymentMethod = PaymentMethod.fromSqlitee(node);
      paymentMethods.add(paymentMethod);
    }
    return paymentMethods;
  }

  // get payment methods refactor
  Future<List<PaymentMethodRefactor>> getPaymentMethodsRefactor(
      {int isReturn}) async {
    List<PaymentMethodRefactor> paymentMethods = [];
    List<PaymentMethodRefactor> paymentMethodsForReturns = [];
    final sql = '''SELECT * FROM payment_methods''';
    final data = await db.rawQuery(sql);
    for (final node in data) {
      final PaymentMethodRefactor paymentMethod =
          PaymentMethodRefactor.fromSqlite(node);
      if (isReturn == 1 && paymentMethod.allowInReturns == 1)
        paymentMethodsForReturns.add(paymentMethod);
      paymentMethods.add(paymentMethod);
    }
    if (isReturn == 1) return paymentMethodsForReturns;
    if (isReturn == 0) return paymentMethods;
  }
}
