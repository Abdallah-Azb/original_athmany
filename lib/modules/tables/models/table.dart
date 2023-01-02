import 'dart:convert';

class Tables {
  List<TableModel> tables;

  Tables({
    this.tables,
  });

  factory Tables.fromMap(Map<String, dynamic> map) {
    return Tables(
      tables: List<TableModel>.from(
          map['tables']?.map((x) => TableModel.fromMap(x))),
    );
  }

  factory Tables.fromJson(String source) => Tables.fromMap(json.decode(source));
}

class TableModel {
  String category;
  int no;
  final int reserved;

  TableModel({
    this.category,
    this.no,
    this.reserved,
  });

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      category: map['category'],
      no: map['no'],
      reserved: map['reserved'],
    );
  }

  factory TableModel.fromJson(String source) =>
      TableModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'no': no,
      'reserved': reserved ?? 0,
    };
  }
}
