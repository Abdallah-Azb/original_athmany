class Customer {
  int defaultCustomer;
  String name;
  String customerName;
  String customerType;
  String customerGroup;
  String territory;
  String defaultMobile;
  String defaultEmail;
  int allowDefermentOfPayment;

  Customer(
      {this.defaultCustomer,
      this.name,
      this.customerName,
      this.customerType,
      this.customerGroup,
      this.territory,
      this.defaultMobile,
      this.defaultEmail,
      this.allowDefermentOfPayment});

  factory Customer.empty() => Customer(
        territory: '',
      );

  Customer.fromJson(Map<String, dynamic> json) {
    this.name = json['name'];
    this.customerName = json['customer_name'];
    this.customerType = json['customer_type'];
    this.customerGroup = json['customer_group'];
    this.territory = json['territory'];
    this.defaultMobile = json['default_mobile'];
    this.defaultEmail = json['default_email'];
    this.allowDefermentOfPayment = json['allow_deferment_of_payment'];
  }

  Customer.fromSqlite(Map<String, dynamic> node) {
    this.name = node['name'];
    this.customerName = node['customer_name'];
    this.customerType = node['customer_type'];
    this.customerGroup = node['customer_group'];
    this.territory = node['territory'];
    this.defaultMobile = node['default_mobile'];
    this.defaultEmail = node['default_email'];
    this.allowDefermentOfPayment = node['allow_deferment_of_payment'];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'default_customer': this.defaultCustomer ?? 0,
      'name': this.name,
      'customer_name': this.customerName,
      'customer_type': this.customerType,
      'customer_group': this.customerGroup,
      'territory': this.territory,
      'default_mobile': this.defaultMobile,
      'default_email': this.defaultEmail,
      'allow_deferment_of_payment': this.allowDefermentOfPayment,
    };
    return map;
  }

  Customer copyWith({
    String territory,
  }) {
    return Customer(
      territory: territory ?? this.territory,
    );
  }
}
