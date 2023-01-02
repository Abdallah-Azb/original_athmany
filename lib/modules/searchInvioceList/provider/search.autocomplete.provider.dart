import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/searchInvioceList/repositories/search.autocomplete.repository.dart';
import 'package:flutter/material.dart';

class SearchAutoCompleteProvider extends ChangeNotifier {
  SearchAutoCompleteRepository _autoCompleteRepository =
      SearchAutoCompleteRepository();
  DBInvoiceRefactor invoiceRefactor = DBInvoiceRefactor();
  String patteren = '';
  String selectedFilter = 'customerName';
  Iterable<String> customersResult;
  TextEditingController textEditingController = TextEditingController();

  Future filter(String value) async {
    switch (selectedFilter) {
      case 'customer':
        return _autoCompleteRepository.getInvoiceByCustomerName(value);
        break;
      case 'customerName':
        return await _autoCompleteRepository.getInvoiceByCustomerName(value);
        break;
      case 'invoiceNo':
        return await _autoCompleteRepository.getInvoiceByName(value);
        break;
      case 'invoiceTotal':
        return await _autoCompleteRepository
            .getInvoiceByTotal(double.parse(value));
        break;
      case 'invoiceTableNo':
        return await _autoCompleteRepository
            .getInvoiceByTableNo(int.parse(value));
        break;
    }
  }

  Future<List<Invoice>> getInvoices(String value) async {
    List<Invoice> invoices;

    switch (selectedFilter) {
      case 'customer':
        // invoices = await invoiceRefactor.getInvoiceByCustomerName(value);
        break;
      case 'customerName':
        break;
      case 'invoiceNo':
        break;
      case 'invoiceTotal':
        break;
    }
    return invoices;
  }

  Future getCustomers(String filter) async {
    customersResult = await _autoCompleteRepository.getCustomers(filter);

    return customersResult;
  }

  Future getInvoiceByNo(String value) async {}

  void clear(context) {
    setSearchSuggestion('');
    clearCustomerResult();
    clearFocus(context);
  }

  void setSelectedFilter(String value) {
    selectedFilter = value;
    textEditingController.text = '';
    notifyListeners();
  }

  void setPatteren(String value) {
    patteren = value;
  }

  void clearCustomerResult() {
    customersResult = null;
  }

  void setSearchSuggestion(String value) {
    textEditingController.text = value;
  }

  void clearFocus(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  bool get isShowClearIcon => patteren.isNotEmpty;
}
