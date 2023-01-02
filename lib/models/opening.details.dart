// class OpeningDetails {
//   String periodStartDate;
//   String name;
//   String posProfile;
//   String company;
//   String closingEntryName;

//   OpeningDetails(
//       {this.periodStartDate, this.name, this.posProfile, this.company});

//   Map<String, dynamic> toSqlite() {
//     var map = <String, dynamic>{
//       'period_start_date': this.periodStartDate,
//       'name': this.name,
//       'pos_profile': this.posProfile,
//       'company': this.company,
//       'closing_opening_name': this.closingEntryName,
//     };
//     return map;
//   }

//   //
//   OpeningDetails.fromSqlite(Map<String, dynamic> json) {
//     this.periodStartDate = json['period_start_date'];
//     this.name = json['name'];
//     this.posProfile = json['pos_profile'];
//     this.company = json['company'];
//     this.closingEntryName = json['closing_opening_name'];
//   }
// }
