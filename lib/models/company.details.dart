import 'dart:developer';

class CompanyDetails {
  String defaultReceivableAccount;
  String defaultBankAccount;
  String defaultCashAccount;

  CompanyDetails(
      {this.defaultReceivableAccount,
      this.defaultBankAccount,
      this.defaultCashAccount});

  // to sqlite
  Map<String, dynamic> toSqlite() {
    Map<String, dynamic> map = <String, dynamic>{
      'default_receivable_account': this.defaultReceivableAccount,
      'default_bank_account': this.defaultBankAccount,
      'default_cash_account': this.defaultCashAccount,
    };
    return map;
  }

  // get pos profile details from sqlite
  CompanyDetails.fromServer(Map<String, dynamic> json) {
    this.defaultReceivableAccount = json['default_receivable_account'];
    this.defaultBankAccount = json['default_bank_account'];
    this.defaultCashAccount = json['default_cash_account'];
  }

  // get company sqlite
  CompanyDetails.fromSqlite(Map<String, dynamic> json) {
    this.defaultReceivableAccount = json['default_receivable_account'];
    this.defaultBankAccount = json['default_bank_account'];
    this.defaultCashAccount = json['default_cash_account'];
  }

  List<String> validate(Map<String, dynamic> json) {
    Map<String, dynamic> map = Map.from(json);
    List<String> invalidList = [];
    map.forEach((key, value) {
      if (value == null || value == '') invalidList.add(key.toString());
    });
    return invalidList;
  }
}
