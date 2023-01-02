class PosTransaction {
  String posInvoice;
  String postingDate;
  String customer;
  double grandTotal;

  PosTransaction(
      {this.posInvoice, this.postingDate, this.customer, this.grandTotal});

  PosTransaction.fromServer(Map<String, dynamic> map) {
    this.posInvoice = map['pos_invoice'];
    this.postingDate = map['posting_date'];
    this.customer = map['customer'];
    this.grandTotal = map['grand_total'];
  }
}
