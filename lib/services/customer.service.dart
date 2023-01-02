import 'package:app/modules/customer-refactor/models/models.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'api.service.dart';

class CustomerService {
  Future<Response> addCustomer(Customer customer) async {
    print("hi territory: ${customer.defaultMobile}");
    var request = {
      "customer_type": customer.customerType,
      "customer_group": customer.customerGroup,
      "territory": customer.territory,
      "customer_name": customer.customerName,
      "default_mobile": customer.defaultMobile,
      "default_email": customer.defaultEmail
    };
    return ApiService().dio.post('/api/resource/Customer', data: request);
  }

  Future<Response> editCustomer(Customer customer) async {
    var request = {
      "customer_type": customer.customerType,
      "customer_group": customer.customerGroup,
      "territory": customer.territory,
      "customer_name": customer.customerName,
      "default_mobile": customer.defaultMobile,
      "default_email": customer.defaultEmail
    };
    return ApiService()
        .dio
        .put('/api/resource/Customer/${customer.name}', data: request);
  }

  Future<List<Customer>> getCustomerSuggestions(String query) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    try {
      var response;
      if (_prefs.getString('CUSTOMER_GROUPS') == '') {
        response = await ApiService().dio.get(
            '/api/resource/Customer?filters=[["default_mobile","like","$query%"]]&fields=["name","customer_name","default_email","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]');
      } else {
        response = await ApiService().dio.get(
            '/api/resource/Customer?filters=[["customer_group", "in", "${_prefs.getString('CUSTOMER_GROUPS')}"],["default_mobile","like","$query%"]]&fields=["name","customer_name","default_email","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]');
      }
      if (response.statusCode == 200) {
        List customers = response.data['data'];
        return customers.map((json) => Customer.fromJson(json)).where((c) {
          final nameLower = c.defaultMobile.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower);
        }).toList();
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<Customer>> getCustomerSuggestionsName(String query) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    try {
      var response;
      print("============== |${_prefs.getString('CUSTOMER_GROUPS')}| =============");
      if (_prefs.getString('CUSTOMER_GROUPS') == '') {
        print("query is ======== $query");
        response = await ApiService().dio.get(
            '/api/resource/Customer?limit=700&filters=[["customer_name","like","$query%"]]&fields=["name","customer_name","default_email","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]');
      } else {
        print("query is ======== $query");
        response = await ApiService().dio.get(
            '/api/resource/Customer?limit=700&filters=[["customer_group", "in", "${_prefs.getString('CUSTOMER_GROUPS')}"],["customer_name","like","$query%"]]&fields=["name","customer_name","default_email","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]');
      }

      // final response = await ApiService().dio.get(
      //     '/api/resource/Customer?filters=[["customer_group", "in", "${_prefs.getString('CUSTOMER_GROUPS')}"],["name","like","%$query%"]]&fields=["name","customer_name","default_email","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]');
      // '/api/resource/Customer?filters=[["customer_group", "in", "All Customer Groups,Non Profit"],["name","like","%$query%"]]&fields=["name","customer_name","default_email","default_mobile","image","loyalty_program","customer_group","allow_deferment_of_payment"]');
      if (response.statusCode == 200) {
        List customers = response.data['data'];
        print("============ customer length :::  ${customers.length} ============");
        return customers.map((json) => Customer.fromJson(json)).where((c) {
          final nameLower = c.customerName.toLowerCase();
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower);
        }).toList();
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }
}
