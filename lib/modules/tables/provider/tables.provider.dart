import 'package:app/modules/tables/tables.dart';
import 'package:flutter/material.dart';

class TablesProvider extends ChangeNotifier {
  TablesRepository _tablesRepository = TablesRepository();
  int selectedTableNo;

  String _selectedCategory;
  String get selectedCategory => _selectedCategory;

  Future<List<TableModel>> getTables(String category) async {
    return await _tablesRepository.getTables(category);
  }

  void setSelectedCategory(String cateogry) {
    this._selectedCategory = cateogry;
    notifyListeners();
  }

  void setSelectedTableNo(int no) {
    selectedTableNo = no;
    notifyListeners();
  }

  void clearTable() {
    selectedTableNo = null;
    notifyListeners();
  }
}
