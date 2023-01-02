
class OpeningDetails {
  String periodStartDate;
  String name;
  String profile;
  String company;
  String closingEntryName;

  OpeningDetails({this.periodStartDate, this.name, this.profile, this.company});

  Map<String, dynamic> toSqlite() {
    DateTime dateTime = DateTime.parse(this.periodStartDate);
    var map = <String, dynamic>{
      'period_start_date': "$dateTime",
      'name': this.name,
      'pos_profile': this.profile,
      'company': this.company,
      'closing_opening_name': this.closingEntryName,
    };
    return map;
  }

  //
  OpeningDetails.fromSqlite(Map<String, dynamic> json) {
    this.periodStartDate = json['period_start_date'];
    this.name = json['name'];
    this.profile = json['pos_profile'];
    this.company = json['company'];
    this.closingEntryName = json['closing_opening_name'];
  }
  //
  OpeningDetails.fromMap(OpeningDetails openingDetails) {
    this.periodStartDate = openingDetails.periodStartDate;
    this.name = openingDetails.name;
    this.profile = openingDetails.profile;
    this.company = openingDetails.closingEntryName;
    this.closingEntryName = openingDetails.closingEntryName;
  }

  OpeningDetails.fromServer(Map<String, dynamic> map) {
    this.name = map['name'];
    this.company = map['company'];
    this.profile = map['pos_profile'];
    this.periodStartDate = map['period_start_date'];
  }
}
