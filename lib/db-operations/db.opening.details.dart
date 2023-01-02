import 'package:app/modules/opening/opening.dart';
import 'package:app/services/auth.service.dart';
import 'package:app/services/db.service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqlite_api.dart';

class DBOpeningDetails {
  // drop and create opening table
  Future dropAndCreateOpeningDetailsTable() async {
    await db.execute("DROP TABLE IF EXISTS opening_details");
    await DBService().createOpeningDetailsTable(db);
  }

  Future create() async {
    await DBService().createOpeningDetailsTable(db);
  }

  Future dropOpeningDetailsTable() async {
    await db.execute("DROP TABLE IF EXISTS opening_details");
  }

  // add opening details to sqlite
  Future add(OpeningDetails openingDetails) async {
    try {
      return await db.insert('opening_details', openingDetails.toSqlite());
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure("database_error");
    }
  }

  // get opening details from sqlite
  Future<OpeningDetails> getOpeningDetails() async {
    OpeningDetails openingDetails;
    final sql = '''SELECT * FROM opening_details LIMIT 1''';
    final data = await db.rawQuery(sql);
    if (data.length > 0) {
      openingDetails = OpeningDetails.fromSqlite(data[0]);
    }
    return openingDetails;
  }

  // update closing entry name
  // reserve table
  Future<void> updateClosingEntryName(
      String name, String closingEntryName) async {
    var map = <String, dynamic>{'closing_opening_name': closingEntryName};
    try {
      return await db
          .update('opening_details', map, where: 'name = ?', whereArgs: [name]);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
    }
  }
}
