import 'dart:convert';

Territory territoryFromJson(String str) => Territory.fromJson(json.decode(str));

String territoryToJson(Territory data) => json.encode(data.toJson());

class Territory {
  Territory({
    this.data,
  });

  List<Datum> data;

  factory Territory.fromJson(Map<String, dynamic> json) => Territory(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.name,
  });

  String name;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

//
// import 'package:app/models/items.group.dart';
//
// class Territory {
//   String name;
//   List<ItemsGroups> itemsGroups;
//
//   Territory({
//     this.name,
//   });
//
//   factory Territory.empty() => Territory(
//         name: "",
//       );
//
//   // map
//   Map<String, dynamic> toMap() {
//     Map<String, dynamic> map = <String, dynamic>{
//       'name': this.name,
//     };
//     return map;
//   }
//
//   // get device from sqlite
//   Territory.fromSqlite(Map<String, dynamic> json) {
//     this.name = json['id'];
//   }
//
//   factory Territory.fromJson(Map<String, dynamic> json) {
//     Territory territory = Territory();
//     territory.name = json['name'];
//     return territory;
//   }
//
//   Territory copyWith({
//     String name,
//   }) {
//     return Territory(
//       name: name ?? this.name,
//     );
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is Territory && other.name == name;
//   }
//
//   @override
//   int get hashCode {
//     return name.hashCode;
//   }
// }
