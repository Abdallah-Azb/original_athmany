import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/customer-refactor/models/Territory.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/modules/customer-refactor/models/customer_bills.dart';
import 'package:app/services/services.dart';

class CustomerRepository {
  Future<Territory> getAllTerritory() async {
    Territory territory = await ApiService().getTerritories();
    return territory;
  }

  Future<List<CustomerBill>> getCustomerBills(String customer) async {
    List<CustomerBill> customerBill =
        await ApiService().getCustomerBills(customer);
    return customerBill.reversed.toList();
  }
}
