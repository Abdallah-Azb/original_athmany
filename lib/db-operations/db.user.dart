import 'package:app/modules/auth/auth.dart';
import 'package:app/services/db.service.dart';

class DBUser {
  // drop and create logged in user table
  Future dropAndCreateSignedInUserTable() async {
    await db.execute("DROP TABLE IF EXISTS user");
    await DBService().createLoggedInUserTable(db);
  }

  Future dropUserTable() async {
    await db.execute("DROP TABLE IF EXISTS user");
  }

  // get signed in user from sqlite
  Future<User> getUser() async {
    User user;
    final sql = '''SELECT * FROM user''';
    final data = await db.rawQuery(sql);
    user = User.fromSqlite(data[0]);
    return user;
  }

  // add signed in user to sqlite
  Future add(User user) async {
    return await db.insert('user', user.toSqlite());
  }
}
