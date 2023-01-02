import 'models.dart';

class PaymentMethodRefactor {
  int defaultPaymentMode;
  String modeOfPayment;
  String icon;
  String type;
  String account;
  double openingAmount;
  double expectedAmount;
  double closingAmount;
  PaymentRefactor payment;
  int allowInReturns;

  PaymentMethodRefactor(
      {this.defaultPaymentMode,
      this.modeOfPayment,
      this.icon,
      this.type,
      this.account,
      this.openingAmount,
      this.expectedAmount,
      this.closingAmount,
      this.payment,
      this.allowInReturns});

  //
  factory PaymentMethodRefactor.fromSqlite(Map<String, dynamic> map) {
    PaymentMethodRefactor paymentMethod = PaymentMethodRefactor();
    paymentMethod.defaultPaymentMode = map['default_payment_mode'];
    paymentMethod.modeOfPayment = map['mode_of_payment'];
    paymentMethod.icon = map['icon'];
    paymentMethod.type = map['type'];
    paymentMethod.account = map['account'];
    paymentMethod.allowInReturns = map['allow_in_returns'];
    return paymentMethod;
  }

  Map<String, dynamic> toMap(int invoiceId) {
    Map<String, dynamic> map = <String, dynamic>{
      'default_payment_mode': this.defaultPaymentMode,
      'mode_of_payment': this.modeOfPayment,
      'account': this.account,
      'type': this.type,
      'base_amount': this.payment.amount,
      'allow_in_returns': this.allowInReturns,
      'amount': double.parse(this.payment.amountStr),
      'FK_payment_invoice_id': invoiceId
    };
    return map;
  }
}
