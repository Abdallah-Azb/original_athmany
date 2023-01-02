class CustomerBill {
  String name;
  double grand_total;
  String status;
  String posting_date;
  String posting_time;
  String currency;

  CustomerBill({
    this.name,
    this.grand_total,
    this.status,
    this.posting_date,
    this.posting_time,
    this.currency,
  });

  CustomerBill.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.grand_total = json['grand_total'];
    this.status = json['status'];
    this.posting_date = json['posting_date'];
    this.posting_time = json['posting_time'];
    this.currency = json['currency'];
  }

  CustomerBill.fromSqlite(Map<String, dynamic> node) {
    this.name = node['name'];
    this.grand_total = node['grand_total'];
    this.status = node['status'];
    this.posting_date = node['posting_date'];
    this.posting_time = node['posting_time'];
    this.currency = node['currency'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'name': this.name,
      'grand_total': this.grand_total,
      'status': this.status,
      'posting_date': this.posting_date,
      'posting_time': this.posting_time,
      'currency': this.currency,
    };
    return map;
  }
}
