import 'package:app/services/db.service.dart';
import 'package:app/models/models.dart';
import 'package:sqflite/sqflite.dart';

import '../services/auth.service.dart';

class DBProfileDetails {
  // drop and create pos profile details table
  Future dropAndCreatePOSProfileDetailsTable() async {
    await db.execute("DROP TABLE IF EXISTS pos_profile_details");
    await DBService().createPOSProfileDetailsTable(db);
  }

  Future create() async {
    await DBService().createPOSProfileDetailsTable(db);
    print("createPOSProfileDetailsTable");
  }

  // add pos profile details to sqlite
  Future add(ProfileDetails posProfileDetails) async {
    try {
          return await db.insert(
              'pos_profile_details', posProfileDetails.toSqlite());
        } on DatabaseException catch (e) {
          throw Failure("Could not save company details to sqlite");
        }
  }

  // get pos profile details
  Future<ProfileDetails> getProfileDetails() async {
    final sql = '''SELECT * FROM pos_profile_details''';
    final data = await db.rawQuery(sql);
    ProfileDetails posProfileDetails = ProfileDetails.fromSqlite(data[0]);
    return posProfileDetails;
  }
}
