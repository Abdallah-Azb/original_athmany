import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/modules/customer/customer.dart';

class SearchAutoCompleteRepository {
  CustomersRepository _customersRepository = CustomersRepository();
  DBInvoiceRefactor _dbInvoiceRefactor = DBInvoiceRefactor();

  Future getCustomers(String filter) async {
    List<Customer> customers = await _customersRepository.getAllCustomers();

    return customers
        .where((element) =>
            element.name.toLowerCase().contains(filter.toLowerCase()))
        .map((e) => e.name);
  }

  Future getInvoiceByCustomerName(String customerName) async {
    return await _dbInvoiceRefactor.findInvoicesByCustomerName(customerName);
  }

  Future getInvoiceByName(String name) async {
    return await _dbInvoiceRefactor.findInvoicesByName(name);
  }

  Future getInvoiceByTotal(double total) async {
    return await _dbInvoiceRefactor.findInvoicesByTotal(total);
  }

  Future getInvoiceByTableNo(int tableNo) async {
    return await _dbInvoiceRefactor.findInvoicesByTableNo(tableNo);
  }
}
