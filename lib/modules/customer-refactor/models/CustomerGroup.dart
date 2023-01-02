import 'package:flutter/cupertino.dart';

class CustomerGroupItem {
  String name;
  String title;

  CustomerGroupItem({this.name, this.title});
}

class CustomerGroup with ChangeNotifier {
  List<CustomerGroupItem> _groups = [];

  Future<void> getCustomerGroups() async {}
}
