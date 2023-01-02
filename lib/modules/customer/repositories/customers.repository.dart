import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/services/services.dart';

class CustomersRepository {
  Future<List<Customer>> getAllCustomers() async {
    List<Customer> customers = await ApiService().getCustomersList();

    return customers;
  }

  Future<List<Customer>> getCustomersList() async {
    List<Customer> customers = await ApiService().getCustomersList();

    List<DeliveryApplication> deliveryApplications =
        await DBDeliveryApplication().getAll();

    return customers
        .where((customer) =>
            deliveryApplications
                .indexWhere((e) => e.customer == customer.name) ==
            -1)
        .toList();
  }
}
