import 'dart:developer';

import 'package:app/services/db.service.dart';
import 'package:app/models/models.dart';
import 'package:sqflite/sqflite.dart';

import '../services/auth.service.dart';

class DBCompanyDetails {
  // drop and create company details table
  Future dropAndCreateCompanyDetailsTable() async {
    await db.execute("DROP TABLE IF EXISTS company_details");
    await DBService().createCompanyDetailsTable(db);
  }

  Future create() async {
    print("createCompanyDetailsTable");
    await DBService().createCompanyDetailsTable(db);
    print("createCompanyDetailsTable1");
  }

  // add company sqlite
  Future add(CompanyDetails companyDetails) async {
    // return await db.insert('company_details', companyDetails.toSqlite());
    try {
      return await db.insert('company_details', companyDetails.toSqlite());
    } on DatabaseException catch (e) {
      log("DBCompanyDetails catch error ::: $e");
      throw Failure("Could not save company details to sqlite");
    }
  }

  // get company
  Future<CompanyDetails> getCompanyDetails() async {
    final sql = '''SELECT * FROM company_details''';
    final data = await db.rawQuery(sql);
    CompanyDetails companyDetails = CompanyDetails.fromSqlite(data[0]);
    return companyDetails;
  }
}
