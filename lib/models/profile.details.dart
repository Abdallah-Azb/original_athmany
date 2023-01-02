import 'package:app/models/delivery.application.dart';
import 'package:app/models/items.group.dart';

class ProfileDetails {
  String name;
  String posLogo;
  String customer;
  String company;
  int updateStock;
  String currency;
  String taxId;
  String costCenter;
  String sellingPriceList;
  String warehouse;
  String incomeAccount;
  int totalOfTables;
  List posTables;
  String writeOffAccount;
  String writeOffCostCenter;
  List<dynamic> payments;
  String taxesAndCharges;
  List<ItemsGroups> itemGroups;
  List<DeliveryApplication> deliveryApplications;
  List customerGroups;
  String address;
  int hideTotalAmount;
  int rating_qr_invoice;
  String applyDiscountOn;

  ProfileDetails({
    this.name,
    this.posLogo,
    this.customer,
    this.company,
    this.updateStock,
    this.currency,
    this.taxId,
    this.costCenter,
    this.sellingPriceList,
    this.warehouse,
    this.incomeAccount,
    this.totalOfTables,
    this.posTables,
    this.writeOffAccount,
    this.writeOffCostCenter,
    this.payments,
    this.taxesAndCharges,
    this.itemGroups,
    this.deliveryApplications,
    this.address,
    this.hideTotalAmount,
    this.rating_qr_invoice,
    this.applyDiscountOn
  });

  //
  factory ProfileDetails.fromServer(Map<String, dynamic> map) {
    ProfileDetails profileDetails = ProfileDetails();
    if (map['message'] != null) map = map['message'];

    profileDetails.name = map['name'];
    profileDetails.posLogo = map['pos_logo'];
    profileDetails.customer = map['customer'];
    profileDetails.company = map['company'];
    profileDetails.updateStock = map['update_stock'];
    profileDetails.currency = map['currency'];
    profileDetails.taxId = map['tax_id'];
    profileDetails.costCenter = map['cost_center'];
    profileDetails.sellingPriceList = map['selling_price_list'];
    profileDetails.warehouse = map['warehouse'];
    profileDetails.incomeAccount = map['income_account'];
    profileDetails.totalOfTables = map['total_of_table'];
    profileDetails.posTables = map['pos_tables'];
    profileDetails.writeOffAccount = map['write_off_account'];
    profileDetails.writeOffCostCenter = map['write_off_cost_center'];
    profileDetails.payments = map['payments'];
    profileDetails.taxesAndCharges = map['taxes_and_charges'];
    profileDetails.hideTotalAmount = map['hide_total_amount'];
    profileDetails.rating_qr_invoice = map['rating_qr_invoice'];
    profileDetails.applyDiscountOn = map['apply_discount_on'];
    profileDetails.itemGroups = (map['item_groups'] as List)
        .map((e) => ItemsGroups(
              itemGroup: e['item_group'],
            ))
        .toList();
    profileDetails.deliveryApplications = (map['delivery_applications'] as List)
        .map((e) => DeliveryApplication.fromJson(e))
        .toList();

    profileDetails.customerGroups = map['customer_groups'];
    profileDetails.address = map['address'];

    return profileDetails;
  }

  //
  Map<String, dynamic> toSqlite() {
    var map = <String, dynamic>{
      'name': this.name,
      'pos_logo': this.posLogo,
      'customer': this.customer,
      'company': this.company,
      'update_stock': this.updateStock,
      'currency': this.currency,
      'tax_id': this.taxId,
      'cost_center': this.costCenter,
      'selling_price_list': this.sellingPriceList,
      'warehouse': this.warehouse,
      'income_account': this.incomeAccount,
      'total_of_tables': this.totalOfTables,
      'write_off_account': this.writeOffAccount,
      'write_off_cost_center': this.writeOffCostCenter,
      'address': this.address,
      'hide_total_amount': this.hideTotalAmount,
      'rating_qr_invoice': this.rating_qr_invoice,
      'apply_discount_on': this.applyDiscountOn
    };
    return map;
  }

  // get pos profile details from sqlite
  ProfileDetails.fromSqlite(Map<String, dynamic> json) {
    this.name = json['name'];
    this.posLogo = json['pos_logo'];
    this.customer = json['customer'];
    this.company = json['company'];
    this.updateStock = json['update_stock'];
    this.currency = json['currency'];
    this.taxId = json['tax_id'].toString();
    this.costCenter = json['cost_center'];
    this.sellingPriceList = json['selling_price_list'];
    this.warehouse = json['warehouse'];
    this.incomeAccount = json['income_account'];
    this.totalOfTables = json['total_of_tables'];
    this.writeOffAccount = json['write_off_account'];
    this.writeOffCostCenter = json['write_off_cost_center'];
    this.address = json['address'];
    this.hideTotalAmount = json['hide_total_amount'];
    this.rating_qr_invoice = json['rating_qr_invoice'];
    this.applyDiscountOn = json['apply_discount_on'];
  }

  List<String> validate(Map<String, dynamic> json) {
    Map<String, dynamic> map = Map.from(json)
      ..remove("pos_logo")
      ..remove("income_account")
      ..remove("total_of_tables");
    List<String> invalidList = [];
    map.forEach((key, value) {
      if (value == null || value == '') invalidList.add(key.toString());
    });
    return invalidList;
  }
}
