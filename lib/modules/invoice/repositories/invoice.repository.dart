// import 'package:app/core/enums/enums.dart';
// import 'package:app/db-operations/db.operations.dart';
// import 'package:app/models/models.dart';
// import 'package:app/services/print-service/print.service.dart';
// import 'package:app/services/services.dart';

// import '../invoice.dart';

// class InvoiceRepository {
//   Future<String> sendInvoiceToServer(int invoiceId,
//       {bool pay = false, int allowPayment = 1}) async {
//     return await InvoiceService.sendInvoiceToServer(
//       invoiceId,
//       pay: true,
//       allowPayment: 0,
//     );
//   }

//   Future<int> saveInvoice(Invoice invoice, Function setNewId,
//       {bool pay = false, List<Payment> payments}) async {
//     invoice..docStatus = DOCSTATUS.SAVED;
//     return await InvoiceService.saveInvoice(invoice, setNewId);
//   }

//   Future<void> printInvoice(int invoiceId, {bool kitchen}) async {
//     await PrintService().printInvoice(invoiceId, kitchen: false);
//   }

//   Future<List<PaymentMethod>> getPaymentMethods() async {
//     return await DBPaymentMethod().getPaymentMethods();
//   }
// }
