class PaymentReconciliation {
  String modeOfPayment;
  String icon;
  double openingAmount;
  double expectedAmount;
  double closingAmount;

  PaymentReconciliation(
      {this.modeOfPayment,
      this.icon,
      this.openingAmount,
      this.expectedAmount,
      this.closingAmount});

  PaymentReconciliation.fromServer(Map<String, dynamic> map) {
    this.modeOfPayment = map['mode_of_payment'];
    this.openingAmount = map['opening_amount'];
    this.expectedAmount = map['expected_amount'];
  }
}
