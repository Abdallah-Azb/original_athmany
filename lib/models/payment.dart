class Payment {
  int defaultPaymentMode;
  String modeOfPayment;
  String account;
  String type;
  double baseAmount;
  double amount;
  String icon;
  String amountStr;
  int invoiceId;

  Payment({
    this.defaultPaymentMode,
    this.modeOfPayment,
    this.account,
    this.type,
    this.baseAmount = 0,
    this.amount = 0,
    this.icon,
    this.amountStr = "0",
    this.invoiceId,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'default_payment_mode': this.defaultPaymentMode,
      'mode_of_payment': this.modeOfPayment,
      'account': this.account,
      'type': this.type,
      'base_amount': this.amount,
      'amount': this.amount,
      'FK_payment_invoice_id': this.invoiceId
    };
    return map;
  }

  // from sqlite
  Payment.fromSqlite(Map<String, dynamic> json) {
    this.defaultPaymentMode = json['default_payment_mode'];
    this.modeOfPayment = json['mode_of_payment'];
    this.account = json['account'];
    this.type = json['type'];
    this.baseAmount = json['base_amount'];
    this.amount = json['amount'];
    this.amount = json['amount'];
  }

  // to invoice map
  Map<String, dynamic> toInvoiceMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'default': this.defaultPaymentMode,
      'mode_of_payment': this.modeOfPayment,
      'account': this.account,
      'type': this.type,
      'base_amount': this.amount,
      'amount': this.amount,
    };
    return map;
  }
}
