class Tax {
  String chargeType;
  String accountHead;
  String description;
  double rate;
  double taxAmount;
  double total;
  double taxAmountAfterDiscountAmount;
  double baseTaxAmount;
  double baseTotal;
  double baseTaxAmountAfterDiscountAmount;
  String costCenter;
  int includedInPrintRate;
  int invoiceId;

  Tax({
    this.chargeType,
    this.accountHead,
    this.description,
    this.rate,
    this.taxAmount,
    this.total,
    this.taxAmountAfterDiscountAmount,
    this.baseTaxAmount,
    this.baseTotal,
    this.baseTaxAmountAfterDiscountAmount,
    this.costCenter,
    this.includedInPrintRate,
    this.invoiceId,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'charge_type': this.chargeType,
      'account_head': this.accountHead,
      'description': this.description,
      'rate': this.rate,
      'tax_amount': this.taxAmount,
      'total': this.total,
      'tax_amount_after_discount_amount': this.taxAmountAfterDiscountAmount,
      'base_tax_amount': this.baseTaxAmount,
      'base_total': this.baseTotal,
      'base_tax_amount_after_discount_amount':
          this.baseTaxAmountAfterDiscountAmount,
      'cost_center': this.costCenter,
      'included_in_print_rate': this.includedInPrintRate,
      'FK_tax_invoice_id': this.invoiceId
    };
    return map;
  }

  // from sqlite
  Tax.fromSqlite(Map<String, dynamic> json) {
    this.chargeType = json['charge_type'];
    this.accountHead = json['account_head'];
    this.description = json['description'];
    this.rate = json['rate'];
    this.taxAmount = json['tax_amount'];
    this.total = json['total'];
    this.taxAmountAfterDiscountAmount =
        json['tax_amount_after_discount_amount'];
    this.baseTaxAmount = json['base_tax_amount'];
    this.baseTotal = json['base_total'];
    this.baseTaxAmountAfterDiscountAmount =
        json['base_tax_amount_after_discount_amount'];
    this.costCenter = json['cost_center'];
    this.includedInPrintRate = json['included_in_print_rate'];
  }

  // to invoice map
  Map<String, dynamic> toInvoiceMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'charge_type': this.chargeType,
      'account_head': this.accountHead,
      'description': this.description,
      'rate': this.rate,
      'tax_amount': this.taxAmount,
      'total': this.total,
      'tax_amount_after_discount_amount': this.taxAmountAfterDiscountAmount,
      'base_tax_amount': this.baseTaxAmount,
      'base_total': this.baseTotal,
      'base_tax_amount_after_discount_amount':
          this.baseTaxAmountAfterDiscountAmount,
      'cost_center': this.costCenter,
      'included_in_print_rate': this.includedInPrintRate,
    };
    return map;
  }
}
