class OpeningBalance {
  String modeOfPayment;
  String icon;
  double openingAmount;

  OpeningBalance({this.modeOfPayment, this.icon, this.openingAmount});

  //
  factory OpeningBalance.fromServer(Map<String, dynamic> map) {
    OpeningBalance openingPaymentMethod = OpeningBalance();
    openingPaymentMethod.modeOfPayment = map['mode_of_payment'];
    openingPaymentMethod.icon = map['icon'];
    openingPaymentMethod.openingAmount = 0.0;
    return openingPaymentMethod;
  }
}
