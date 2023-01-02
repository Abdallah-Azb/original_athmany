class DeliveryApplication {
  String name;
  String icon;
  String priceList;
  String customer;
  int dueDateAfter;
  int allowPayment;
  double totalOfInvoices;

  DeliveryApplication(
      {this.name,
      this.icon,
      this.priceList,
      this.customer,
      this.dueDateAfter,
      this.allowPayment,
      this.totalOfInvoices});

  DeliveryApplication.fromJson(Map<String, dynamic> json) {
    name = "d${json['name']}";
    icon = json['icon'];
    priceList = json['price_list'];
    customer = json['customer'];
    dueDateAfter = json['due_date_after'];
    allowPayment = json['allow_payment'];
  }

  DeliveryApplication.fromSqlite(Map<String, dynamic> json) {
    name = json['name'];
    icon = json['icon'];
    priceList = json['price_list'];
    customer = json['customer'];
    dueDateAfter = json['due_date_after'];
    allowPayment = json['allow_payment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['price_list'] = this.priceList;
    data['customer'] = this.customer;
    data['due_date_after'] = this.dueDateAfter;
    data['allow_payment'] = this.allowPayment;
    return data;
  }
}
