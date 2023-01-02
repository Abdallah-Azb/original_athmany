class SalesTaxesDetails {
  String chargeType;
  String accountHead;
  String description;
  double rate;
  int includedInPrintRate;

  SalesTaxesDetails(
      {this.chargeType, this.accountHead, this.description, this.rate});

  // from server
  factory SalesTaxesDetails.fromServer(Map<String, dynamic> json) {
    SalesTaxesDetails salesTaxeDetails = SalesTaxesDetails();
    salesTaxeDetails.chargeType = json['charge_type'];
    salesTaxeDetails.accountHead = json['account_head'];
    salesTaxeDetails.description = json['description'];
    salesTaxeDetails.rate = json['rate'];
    salesTaxeDetails.includedInPrintRate = json['included_in_print_rate'];
    return salesTaxeDetails;
  }

  // save to sqlite
  Map<String, dynamic> toSqlite() {
    Map<String, dynamic> map = <String, dynamic>{
      'charge_type': this.chargeType,
      'account_head': this.accountHead,
      'description': this.description,
      'rate': this.rate,
      'included_in_print_rate': this.includedInPrintRate,
    };
    return map;
  }

  // get tax details details from sqlit
  SalesTaxesDetails.fromSqlite(Map<String, dynamic> json) {
    this.chargeType = json['charge_type'];
    this.accountHead = json['account_head'];
    this.description = json['description'];
    this.rate = json['rate'];
    this.includedInPrintRate = json['included_in_print_rate'];
  }

  List<String> validate(Map<String, dynamic> json) {
    Map<String, dynamic> map = Map.from(json)..remove("included_in_print_rate");
    List<String> invalidList = [];
    map.forEach((key, value) {
      if (value == null || value == '') invalidList.add(key.toString());
    });
    return invalidList;
  }
}
