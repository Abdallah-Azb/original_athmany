import 'package:app/core/enums/enums.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';

class Invoice {
  int id;
  int tableNo;
  String name;
  String customer;
  Customer customerRefactor;
  String postingDate;
  String invoiceReference;
  String offlineInvoice;
  String defaultReceivableAccount;
  ProfileDetails profileDetails;
  double total;
  double paidTotal;
  int isSynced;
  int isReturn;
  String returnAgainst;
  int deleted;
  bool payDialogOpened;
  DOCSTATUS docStatus;
  DeliveryApplication selectedDeliveryApplication;
  List<Item> itemsList;
  List<Item> items;
  List taxes;
  List payments;
  String lastUpdatedItem;
  String printFor;
  String status;
  String applyDiscountOnInvoice;
  double additionalDiscountPercentage;
  double discountAmount;
  String coupon_code;

  Invoice({
    this.id,
    this.tableNo,
    this.name,
    this.customer,
    this.postingDate,
    this.invoiceReference,
    this.offlineInvoice,
    this.defaultReceivableAccount,
    this.profileDetails,
    this.total,
    this.paidTotal,
    this.isSynced,
    this.isReturn,
    this.returnAgainst,
    this.deleted,
    this.payDialogOpened,
    this.docStatus,
    this.selectedDeliveryApplication,
    this.itemsList,
    this.items,
    this.taxes,
    this.payments,
    this.lastUpdatedItem,
    this.printFor,
    this.status = "New",
    this.applyDiscountOnInvoice,
    this.additionalDiscountPercentage,
    this.discountAmount = 0.0,
    this.coupon_code,
  });

  factory Invoice.empty() => Invoice(
        isSynced: 0,
        deleted: 0,
        payDialogOpened: false,
        itemsList: [],
        items: [],
        taxes: [],
        payments: [],
      );

  // map
  Map<String, dynamic> toSqlite() {
    Map<String, dynamic> map = <String, dynamic>{
      'posting_date': DateTime.now().toString(),
      'deleted': 0,
      'doc_status': this.docStatus.index,
      'table_no': this.tableNo,
      'customer': this.selectedDeliveryApplication?.customer ??
          this.customerRefactor?.name ??
          this.customer,
      'delivery_application': this.selectedDeliveryApplication?.customer,
      'total': 0,
      'invoice_reference': this.invoiceReference,
      'offline_invoice': this.offlineInvoice,
      'is_synced': 0,
      'is_return': this.isReturn,
      'return_against': this.returnAgainst,
      'apply_discount_on': this.applyDiscountOnInvoice,
      'additional_discount_percentage': this.additionalDiscountPercentage,
      'discount_amount': this.discountAmount,
      'coupon_code': this.coupon_code,
    };
    return map;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = <String, dynamic>{
      "invoice_reference": this.invoiceReference,
      "offline_invoice": this.offlineInvoice,
      "docstatus": this.docStatus.index,
      "naming_series": "ACC-PSINV-.YYYY.-",
      "pos_profile": this.profileDetails.name,
      "customer": this.customer,
      "delivery_application": this.selectedDeliveryApplication?.customer,
      "cost_center": this.profileDetails.costCenter,
      "is_pos": 1,
      'is_return': this.isReturn,
      'return_against': this.returnAgainst,
      "company": this.profileDetails.company,
      "update_stock": this.profileDetails.updateStock,
      "posting_date": this.postingDate,
      "currency": this.profileDetails.currency,
      "selling_price_list": this.profileDetails.sellingPriceList,
      "price_list_currency": this.profileDetails.currency,
      "conversion_rate": 1,
      "plc_conversion_rate": 1,
      "is_dine_in": this.tableNo == null ? 0 : 1,
      "table_number": this.tableNo == null ? '' : this.tableNo,
      "write_off_account": this.profileDetails.writeOffAccount,
      "write_off_cost_center": this.profileDetails.writeOffCostCenter,
      "paid_amount": this.paidTotal,
      "base_paid_amount": this.paidTotal,
      "outstanding_amount": this.total - this.paidTotal,
      "debit_to": this.defaultReceivableAccount,
      "items": items.map((e) => e.toInvoiceMap(profileDetails)).toList(),
      "taxes": taxes.map((e) => e.toInvoiceMap()).toList(),
      "payments": payments.map((payment) => payment.toInvoiceMap()).toList(),
      'apply_discount_on': this.applyDiscountOnInvoice,
      'additional_discount_percentage': this.additionalDiscountPercentage,
      'discount_amount': this.discountAmount,
      'coupon_code': this.coupon_code,
      // 'grand_total' :this.paidTotal
    };
    return map;
  }

  // map
  Map<String, dynamic> fromServer(dynamic invoice) {
    Map<String, dynamic> map = <String, dynamic>{
      'name': invoice['name'],
      'posting_date': invoice['creation'],
      'doc_status': invoice['docstatus'],
      'table_no':
          invoice['table_number'] == '' ? null : invoice['table_number'],
      'customer': invoice['customer'],
      'delivery_application': invoice['delivery_application'],
      'total': invoice['base_grand_total'],
      'invoice_reference': invoice['invoice_reference'],
      'return_against': invoice['return_against'],
      'offline_invoice': invoice['offline_invoice'],
      'deleted': 0,
      'is_synced': 1,
      'is_return': invoice['is_return'],
      'apply_discount_on': invoice['apply_discount_on'],
      'additional_discount_percentage':
          invoice['additional_discount_percentage'],
      'discount_amount': invoice['discount_amount'],
      'coupon_code': invoice['coupon_code']
    };
    return map;
  }

  Invoice.fromSqlite1(Map<String, dynamic> node) {
    this.invoiceReference = node['invoice_reference'];
  }

  Invoice.fromJson(Map<String, dynamic> json) {
    this.offlineInvoice = json['offline_invoice'];
  }

  // get invoice from sqlite
  Invoice.fromSqlite(Map<String, dynamic> json) {
    this.id = json['id'];
    this.postingDate = json['posting_date'];
    this.name = json['name'];
    this.deleted = json['deleted'];
    this.docStatus = DOCSTATUS.values.elementAt(json['doc_status']);
    this.tableNo = json['table_no'];
    this.customer = json['customer'];
    this.total = json['total'];
    this.invoiceReference = json['invoice_reference'];
    this.offlineInvoice = json['offline_invoice'];
    this.applyDiscountOnInvoice = json['apply_discount_on'];
    this.additionalDiscountPercentage = json['additional_discount_percentage'];
    this.discountAmount = json['discount_amount'];
    this.coupon_code = json['coupon_code'];
    this.isSynced = json['is_synced'];
    this.isReturn = json['is_return'];
    this.returnAgainst = json['return_against'];
    this.selectedDeliveryApplication = json['delivery_application'] != null
        ? DeliveryApplication(customer: json['delivery_application'])
        : null;
  }
}
