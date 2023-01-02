class User {
  String sid;
  String userId;
  String username;
  String fullName;

  User({this.sid, this.userId, this.username, this.fullName});

  //
  User.fromSqlite(Map<String, dynamic> json) {
    this.sid = json['sid'];
    this.userId = json['user_id'];
    this.username = json['username'];
    this.fullName = json['full_name'];
  }

  //
  Map<String, dynamic> toSqlite() {
    var map = <String, dynamic>{
      'sid': this.sid,
      'user_id': this.userId,
      'username': this.username,
      'full_name': this.fullName,
    };
    return map;
  }
}
