import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/modules/customer/repositories/customers.repository.dart';
import 'package:flutter/material.dart';

class CustomersProvider extends ChangeNotifier {
  CustomersRepository _customersRepository = CustomersRepository();
  int selectedCustomerId;

  Future<List<Customer>> getCustomers() async {
    return await _customersRepository.getCustomersList();
  }

  void setSelectedCustomerId(int customerId) {
    selectedCustomerId = customerId;
    notifyListeners();
  }

  Customer _editCustomer;
  Customer get editCustomer => _editCustomer;

  void setEditCustomer(Customer customer) {
    _editCustomer = customer;
    notifyListeners();
  }

  void customerLastBills() {}

  void clearEditCustomer() {
    _editCustomer = null;
    notifyListeners();
  }
}
