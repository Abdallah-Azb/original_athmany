class Coupon {
  String name;
  String rateOrDiscount;
  double discountPercentage;
  double discountAmount;
  double maxAmt;

  Coupon({
    this.name,
    this.rateOrDiscount,
    this.discountPercentage,
    this.discountAmount,
    this.maxAmt
        });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = <String, dynamic>{
      'name': this.name,
      "rate_or_discount": this.rateOrDiscount,
      "discount_percentage": this.discountPercentage,
      "discount_amount": this.discountAmount,
      "max_amt": this.maxAmt
    };
  }

  // map
  Map<String, dynamic> fromServer(dynamic coupon) {
    Map<String, dynamic> map = <String, dynamic>{
      'name': coupon['name'],
      'rate_or_discount': coupon['rate_or_discount'],
      'discount_percentage': coupon['discount_percentage'],
      'discount_amount': coupon['discount_amount'],
      'max_amt': coupon['max_amt']
    };
    return map;
  }


}