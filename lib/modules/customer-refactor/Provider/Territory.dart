import 'dart:convert';

import 'package:app/modules/customer-refactor/models/Territory.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/modules/customer-refactor/repositories/customerRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DropdownListsProvider with ChangeNotifier {
  CustomerRepository _customersRepository = CustomerRepository();
  List<String> _customerType = ["Company", "Individual"];
  List<String> _territories = [];
  List<String> _customerGroup = [];
  Customer CustomerTerritory;
  String defaultCustomerType;
  String defaultTerritory;
  String defaultCustomerGroup;
  TerritoryProvider() {
    CustomerTerritory = Customer.empty();
  }

  List<String> get territories {
    if (_territories == null || _territories.isEmpty) {
      return [""];
    }
    return [..._territories];
  }

  List<String> get customerGroups {
    if (_customerGroup == null || _customerGroup.isEmpty) {
      return [""];
    }
    return [..._customerGroup];
  }

  List<String> get customerTypes {
    if (_customerType == null || _customerType.isEmpty) {
      return [""];
    }
    return [..._customerType];
  }

  Future<Datum> getTerritories() async {
    final response = await _customersRepository.getAllTerritory();
    final List<String> data = [];
    response.data.forEach((element) {
      data.add(element.name);
    });

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    // Get customerGroups from SharedPreferences
    var customerGroupsFromPrefs = _prefs.getString('CUSTOMER_GROUPS');
    _customerGroup = customerGroupsFromPrefs.split(",");

    // remove empty values
    _customerGroup.removeWhere((element) => element == "");
    print(_customerGroup);

    // Set dropdownLists values
    _territories = data.reversed.toList();
    _customerGroup == _customerGroup.reversed.toList();

    // Set default values to dropdownLists
    defaultCustomerType = _customerType[0];
    defaultTerritory = _territories[0];
    defaultCustomerGroup = _customerGroup[0];
    print("1CustomerGroup : ");
    print(customerGroupsFromPrefs);
    print("dropdownListValueS: " +
        defaultCustomerGroup +
        "," +
        defaultTerritory +
        ',' +
        defaultCustomerType);
    notifyListeners();
  }

  void onTerritory(String name) {
    print('sd: $name');
    CustomerTerritory.territory = name;

    notifyListeners();
  }
}
