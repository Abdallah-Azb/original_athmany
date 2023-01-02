import 'package:app/modules/return/models/return.model.dart';
import 'package:app/services/api.service.dart';
import 'package:dio/dio.dart';

class ReturnService {
  String _path =
      '/api/method/erpnext.accounts.doctype.pos_invoice.pos_invoice.make_sales_return';

  Future<ReturnInvoice> getReturnInvoice(String name) async {
    ReturnInvoice returnInvoice;

    Response response;
    response = await ApiService().dio.post(_path, data: {"source_name": name});
    if (response.statusCode == 200)
      returnInvoice = ReturnInvoice.fromServer(response.data['message']);
    else {
      print("error");
    }
    return returnInvoice;
  }

  // Future<String> sendInvoiceToServer(Invoice invoice) async {
  //   String name;
  //   Response response;
  //   if (invoice.name == null)
  //     response = await ApiService().dio.post(_path, data: invoice.toJson());
  //   else
  //     response = await ApiService().dio.put(
  //           '/api/resource/POS Invoice/${invoice.name}',
  //           data: invoice.toJson(),
  //         );
  //   if (response.statusCode == 200) {
  //     name = response.data['data']['name'];
  //   }
  //   return name;
  // }
}
