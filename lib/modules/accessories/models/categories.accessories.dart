import 'dart:convert';

class CategoriesAccessories {
  final int id;
  String categoryTitle;
  final int deviceId;
  final int categoryId;
  final bool isActive;

  CategoriesAccessories({
    this.id,
    this.deviceId,
    this.categoryId,
    this.categoryTitle,
    this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'FK_category_accessory_id': deviceId,
      'FK_category_group_id': categoryId,
    };
  }

  factory CategoriesAccessories.fromMap(Map<String, dynamic> map) {
    return CategoriesAccessories(
      id: map['id'],
      deviceId: map['FK_category_accessory_id'],
      categoryId: map['FK_category_group_id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriesAccessories.fromJson(String source) =>
      CategoriesAccessories.fromMap(json.decode(source));
}
