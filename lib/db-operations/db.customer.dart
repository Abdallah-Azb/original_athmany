import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/services/db.service.dart';

class DBCustomer {
  Future create() async {
    await DBService().createCustomersTable(db);
  }

  Future<List<Customer>> getAll() async {
    List<Customer> customers = [];
    final sql = '''SELECT * FROM customers ORDER BY id DESC''';
    final data = await db.rawQuery(sql);
    for (final node in data) {
      final Customer customer = Customer.fromSqlite(node);
      customers.add(customer);
    }
    print(customers.length);

    return customers;
  }

  Future<Customer> getDefaultCutomer() async {
    var data = await db
        .rawQuery('SELECT * FROM customers WHERE default_customer = ?', [1]);
    if (data.length > 0)
      return Customer.fromSqlite(data[0]);
    else
      return null;
  }

  Future<Customer> getNode(Customer customer) async {
    var data = await db
        .rawQuery('SELECT * FROM customers WHERE name = ?', [customer.name]);
    if (data.length > 0)
      return Customer.fromSqlite(data[0]);
    else
      return null;
  }

  Future<void> editCustomer(Customer customer) async {
    return await db.update('customers', customer.toMap(),
        where: 'name = ?', whereArgs: [customer.name]);
  }

  Future<int> add(Customer newCustomer) async {
    int newCustomerId;
    if (await getNode(newCustomer) == null)
      newCustomerId = await db.insert('customers', newCustomer.toMap());
    print(newCustomerId);
    return newCustomerId;
  }
}
