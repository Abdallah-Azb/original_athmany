class PaymentMethod {
  int defaultPaymentMode;
  String modeOfPayment;
  String icon;
  String type;
  String account;
  double openingAmount;
  double expectedAmount;
  double closingAmount;
  int allowInReturns;

  PaymentMethod(
      {this.defaultPaymentMode,
      this.modeOfPayment,
      this.icon,
      this.type,
      this.account,
      this.openingAmount,
      this.expectedAmount,
      this.closingAmount,
      this.allowInReturns});

  //
  factory PaymentMethod.fromServer(Map<String, dynamic> map,
      {String type, String account}) {
    PaymentMethod paymentMethod = PaymentMethod();
    paymentMethod.defaultPaymentMode = map['default'];
    paymentMethod.modeOfPayment = map['mode_of_payment'];
    paymentMethod.icon = map['icon'];
    paymentMethod.allowInReturns = map['allow_in_returns'];
    paymentMethod.type = type;
    paymentMethod.account = account;
    paymentMethod.openingAmount = 0.0;
    return paymentMethod;
  }

  //
  Map<String, dynamic> toSqlite() {
    var map = <String, dynamic>{
      'default_payment_mode': this.defaultPaymentMode,
      'mode_of_payment': this.modeOfPayment,
      'icon': this.icon,
      'type': this.type,
      'account': this.account,
      'allow_in_returns': this.allowInReturns
    };
    return map;
  }

  //
  factory PaymentMethod.fromSqlitee(Map<String, dynamic> map) {
    PaymentMethod paymentMethod = PaymentMethod();
    paymentMethod.defaultPaymentMode = map['default_payment_mode'];
    paymentMethod.modeOfPayment = map['mode_of_payment'];
    paymentMethod.icon = map['icon'];
    paymentMethod.type = map['type'];
    paymentMethod.account = map['account'];
    paymentMethod.allowInReturns = map['allow_in_returns'];
    return paymentMethod;
  }
}
