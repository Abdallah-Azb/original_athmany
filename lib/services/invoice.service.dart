// import 'dart:async';

// import 'package:app/db-operations/db.invoice.refactor.dart';
// import 'package:app/db-operations/db.opening.details.dart';
// import 'package:app/modules/invoice/invoice.dart';
// import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
// import 'package:app/modules/opening/opening.dart';
// import 'package:app/services/api.service.dart';
// import 'package:app/services/print-service/print.service.dart';

// import '../db-operations/db.operations.dart';
// import '../models/models.dart';

// class InvoiceService {
//   InvoiceRepositoryRefactor _invoiceRefactorService =
//       InvoiceRepositoryRefactor();
//   // change invoice table no
//   static changeInvoiceTableNo(invoiceId, int tableNo, int oldTableNo) async {
//     await DBInvoice.changeTableNo(invoiceId, tableNo, oldTableNo);
//   }

//   // get new invoice id
//   static Future<int> getNewInvoiceId() async {
//     return await DBInvoice.getInvoicesLength() + 1;
//   }

//   // delete invoice
//   static Future<void> deleteInvoice(int invoiceId) async {
//     await DBInvoice.deleteInvoice(invoiceId);
//   }

//   // save invoice
//   static Future<int> saveInvoice(Invoice invoice, Function setNewId,
//       {bool pay = false, List<Payment> payments}) async {
//     try {
//       int createdInvoiceId;
//       if (invoice.id == null) {
//         OpeningDetails openingDetails =
//             await DBOpeningDetails().getOpeningDetails();
//         String invoiceReference =
//             "${openingDetails.name}${DateTime.now().millisecondsSinceEpoch}";
//         createdInvoiceId = await DBInvoice.add(invoice, invoiceReference);
//       }
//       // save invoice table no only if invoice is new
//       if (invoice.id == null && invoice.tableNo != null)
//         await DBInvoice.reserveTable(invoice.tableNo);
//       await saveItems(
//           invoice.id == null ? createdInvoiceId : invoice.id, invoice);
//       await saveInvoiceTotal(
//           invoice.id == null ? createdInvoiceId : invoice.id, invoice);
//       await saveTaxes(
//           invoice.id == null ? createdInvoiceId : invoice.id, invoice);
//       await savePayments(
//           invoice.id == null ? createdInvoiceId : invoice.id, invoice, setNewId,
//           pay: pay, payments: payments);
//       return invoice.id == null ? createdInvoiceId : invoice.id;
//     } catch (e) {
//       throw e;
//     }
//   }

// // save items
//   static Future<void> saveItems(int invoiceId, Invoice invoice) async {
//     try {
//       if (invoice.id != null) await DBInvoice.deleteItemsOfInvoice(invoice.id);
//       invoice.itemsList.forEach((i) async {
//         await DBInvoice.addItemOfInvoice(i, invoiceId);
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

// // save taxes
//   static Future<void> saveTaxes(int invoiceId, Invoice invoice) async {
//     if (invoice.id != null) await DBInvoice.deleteTaxesOfInvoice(invoice.id);

//     // get itemsPriceTotal
//     double itemsPriceTotal = 0;
//     invoice.itemsList.forEach((item) {
//       itemsPriceTotal += item.rate * item.qty;
//     });

//     List<SalesTaxesDetails> salesTaxeDetails =
//         await DBSalesTaxesDetails().getSalesTaxeDetails();
//     double finalItemPriceTotal = 0;

//     for (int i = 0; i < salesTaxeDetails.length; i++) {
//       double taxAmount = salesTaxeDetails[i].rate == 0
//           ? 0
//           : (itemsPriceTotal * salesTaxeDetails[i].rate) / 100;
//       finalItemPriceTotal += taxAmount + itemsPriceTotal;
//       final Tax tax = Tax(
//         chargeType: salesTaxeDetails[i].chargeType,
//         accountHead: salesTaxeDetails[i].accountHead,
//         description: salesTaxeDetails[i].description,
//         rate: salesTaxeDetails[i].rate,
//         taxAmount: taxAmount,
//         total: finalItemPriceTotal,
//         taxAmountAfterDiscountAmount: taxAmount,
//         baseTaxAmount: taxAmount,
//         baseTotal: finalItemPriceTotal,
//         baseTaxAmountAfterDiscountAmount: taxAmount,
//         costCenter: null,
//         includedInPrintRate: salesTaxeDetails[i].includedInPrintRate,
//       );
//       await DBInvoice.addTaxOfInvoice(tax, invoiceId);
//     }
//   }

// // save payments
//   static Future<void> savePayments(
//       int invoiceId, Invoice invoice, Function setNewId,
//       {bool pay = false, List<Payment> payments}) async {
//     if (invoice.id != null) await DBInvoice.deletePaymentsOfInvoice(invoice.id);
//     if (!pay) {
//       List<Payment> payments = [];
//       List<PaymentMethod> paymentMethods =
//           await DBPaymentMethod().getPaymentMethods();
//       for (int i = 0; i < paymentMethods.length; i++) {
//         Payment payment = Payment(
//           defaultPaymentMode: paymentMethods[i].defaultPaymentMode,
//           modeOfPayment: paymentMethods[i].modeOfPayment,
//           icon: paymentMethods[i].icon,
//           type: paymentMethods[i].type,
//           account: paymentMethods[i].account,
//           amount: 0,
//           baseAmount: 0,
//           amountStr: "0",
//         );
//         payments.add(payment);
//       }
//       payments.forEach((p) async {
//         await DBInvoice.addPaymentOfInvoice(p, invoiceId);
//       });
//       // await sendInvoiceToServer(invoiceId);

//       setNewId(await getNewInvoiceId());
//     } else {
//       payments.forEach((p) async {
//         await DBInvoice.addPaymentOfInvoice(p, invoiceId);
//       });
//       // await sendInvoiceToServer(invoiceId, pay: true);
//       await DBInvoice.invoiceIsPaid(invoiceId);
//       setNewId(await getNewInvoiceId());
//       // await printInvoice(
//       //     invoiceId, calculateInvoice(invoice.items, salestaxesDetails));
//       try {
//         // PrintService().logo('assets/pos-black-logo.jpg');
//         await PrintService().printInvoice(invoiceId);
//         // await PrintingService().printTest();
//       } catch (e) {
//         print(e);
//       }
//     }
//   }

// // save invoice total
//   static Future<void> saveInvoiceTotal(int invoiceId, Invoice invoice) async {
//     // taxes details
//     List<SalesTaxesDetails> salestaxesDetails =
//         await DBSalesTaxesDetails().getSalesTaxeDetails();

//     List<Item> itemsOfInvoce = invoice.itemsList;
//     List items = [];
//     itemsOfInvoce.forEach((i) {
//       items.add(i.toMap());
//     });

//     double invoiceTotal =
//         calculateInvoice(invoice.itemsList, salestaxesDetails)['totalWithVat'];
//     await DBInvoice.updateInvoiceTotal(invoiceId, invoiceTotal);
//   }

// // get invioce totals
//   static Map<String, double> calculateInvoice(
//       List<Item> invoiceItems, List<SalesTaxesDetails> salestaxesDetails,
//       {List<ItemOption> itemsOptionsWith}) {
//     double itemOptionsPriceTotal = 0;
//     if (itemsOptionsWith != null) {
//       for (ItemOption itemOptionWith in itemsOptionsWith) {
//         itemOptionsPriceTotal += itemOptionWith.priceListRate;
//       }
//     }

//     // // get items of invioce
//     List<Item> itemsOfInvoce = invoiceItems;
//     List items = [];
//     itemsOfInvoce.forEach((i) {
//       items.add(i.toMap());
//     });

//     // // get itemsPriceTotal
//     double itemsPriceTotal = itemOptionsPriceTotal;
//     items.forEach((item) {
//       itemsPriceTotal += item['rate'] * item['qty'];
//     });

//     double vat = 0;
//     double netTotal = itemsPriceTotal;
//     double totalWithVat = 0;
//     double rate = 0;

//     salestaxesDetails
//         .forEach((t) => {if (t.includedInPrintRate == 1) rate += t.rate});

//     if (rate > 0) netTotal = ((itemsPriceTotal * 100.0) / (100.0 + rate));

//     for (int i = 0; i < salestaxesDetails.length; i++) {
//       switch (salestaxesDetails[i].chargeType) {
//         case "On Net Total":
//           double taxAmount = netTotal * salestaxesDetails[i].rate / 100;
//           vat += taxAmount;
//           totalWithVat = netTotal + vat;
//           break;
//       }
//     }
//     // print('netTotal: $netTotal');
//     // print('vat: $vat');
//     // print('totalWithVat: $totalWithVat');

//     Map<String, double> map = {
//       'itemsPriceTotal': itemsPriceTotal,
//       'vat': vat,
//       'totalWithVat': totalWithVat,
//     };

//     return map;
//   }

//   /// send invoice to server
//   static Future<String> sendInvoiceToServer(int invoiceId,
//       {bool pay = false, int allowPayment = 1}) async {
//     return '';
//     // String name;
//     // // TODO: check if there internet connection
//     // //  get invoice from sqlite
//     // // Invoice invoice = await DBInvoice.getInvoice(invoiceId);
//     // Invoice invoice = await DBInvoice.getInvoice(invoiceId);
//     // // get pos profile details
//     // ProfileDetails posProfileDetails =
//     //     await DBProfileDetails.getProfileDetails();

//     // CompanyDetails companyDetails = await DBCompanyDetails.getCompanyDetails();

//     // // get items of the invioce
//     // List<Item> itemsOfInvoce = await DBInvoice.getItemsOfInvoice(invoiceId);
//     // List items = [];
//     // itemsOfInvoce.forEach((i) {
//     //   items.add(i.toInvoiceMap(posProfileDetails));
//     // });

//     // // // get taxes of the invioce
//     // List<Tax> taxesOfInvoce = await DBInvoice.getTaxesOfInvoice(invoiceId);
//     // List taxes = [];
//     // taxesOfInvoce.forEach((t) {
//     //   taxes.add(t.toInvoiceMap());
//     // });

//     // // if pay
//     // // get payments of the invioce
//     // List<Payment> paymentsOfInvoce =
//     //     await DBInvoice.getPaymentsOfInvoice(invoiceId);
//     // List payments = [];
//     // double paidTotal = 0;

//     // paymentsOfInvoce.forEach((p) {
//     //   if (p.amount > 0) {
//     //     payments.add(p.toInvoiceMap());
//     //     paidTotal += p.amount;
//     //   }
//     // });

//     // // if save
//     // if (!pay || allowPayment == 0) {
//     //   List<PaymentMethod> paymentMethods =
//     //       await DBPaymentMethod().getPaymentMethods();
//     //   PaymentMethod defaultPaymentMethod =
//     //       paymentMethods.firstWhere((pm) => pm.defaultPaymentMode == 1);

//     //   Payment defaultPayment = Payment(
//     //     defaultPaymentMode: defaultPaymentMethod.defaultPaymentMode,
//     //     modeOfPayment: defaultPaymentMethod.modeOfPayment,
//     //     type: defaultPaymentMethod.type,
//     //     account: defaultPaymentMethod.account,
//     //     amount: 0,
//     //     baseAmount: 0,
//     //     amountStr: "0",
//     //   );
//     //   payments.add(defaultPayment.toInvoiceMap());
//     // }

//     // // print('toata with vat');
//     // // print('total paid');
//     // // print(paidTotal);

//     // // create invoice map
//     // Map<String, dynamic> map = <String, dynamic>{
//     //   // "invoice_reference":
//     //   //     "${openingDetails.name} | ${DateTime.now().millisecondsSinceEpoch}",
//     //   "invoice_reference": invoice.invoiceReference,
//     //   "docstatus": invoice.docStatus.index,
//     //   "naming_series": "ACC-PSINV-.YYYY.-",
//     //   "pos_profile": posProfileDetails.name,
//     //   "customer": invoice.customer,
//     //   "delivery_application": invoice.selectedDeliveryApplication?.customer,
//     //   "cost_center": posProfileDetails.costCenter,
//     //   "is_pos": 1,
//     //   "company": posProfileDetails.company,
//     //   "update_stock": posProfileDetails.updateStock,
//     //   "posting_date": invoice.postingDate,
//     //   "currency": posProfileDetails.currency,
//     //   "selling_price_list": posProfileDetails.sellingPriceList,
//     //   "price_list_currency": posProfileDetails.currency,
//     //   "conversion_rate": 1,
//     //   "plc_conversion_rate": 1,
//     //   // "base_net_total": itemsPriceTotal,
//     //   // "base_grand_total": itemsPriceTotal + ((itemsPriceTotal / 100) * rate),
//     //   // "grand_total": itemsPriceTotal + ((itemsPriceTotal / 100) * rate),
//     //   "is_dine_in": invoice.tableNo == null ? 0 : 1,
//     //   "table_number": invoice.tableNo == null ? '' : invoice.tableNo,
//     //   "write_off_account": posProfileDetails.writeOffAccount,
//     //   "write_off_cost_center": posProfileDetails.writeOffCostCenter,
//     //   "paid_amount": paidTotal,
//     //   "base_paid_amount": paidTotal,
//     //   "outstanding_amount": invoice.total - paidTotal,
//     //   // TODO: fix this (from company details)
//     //   "debit_to": companyDetails.defaultReceivableAccount,
//     //   "items": items,
//     //   "taxes": taxes,
//     //   "payments": payments
//     // };
//     // try {
//     //   // print(JsonEncoder.withIndent('  ').convert(map));
//     //   // print('print item');
//     //   // print(JsonEncoder.withIndent('  ').convert(items));
//     //   // print(JsonEncoder.withIndent('  ').convert(taxes));
//     //   print(JsonEncoder.withIndent('  ').convert(payments));
//     //   // print(defaultPayment.toMap(invoiceId));
//     //   dynamic data = await ApiService().sendInvoiceToServer(map, invoice.name);
//     //   name = data['name'];
//     //   if (invoice.name == null)
//     //     await DBInvoice.updateInvoiceNameFromServer(invoiceId, data['name']);
//     //   return name;
//     // } on DioError catch (e) {
//     //   throw e;
//     // } catch (e) {
//     //   throw e;
//     // }
//   }

//   // when re connect to internet sync invoices
//   Future syncInvoices() async {
//     List<Invoice> invoices = await DBInvoice.getAllInvoices();
//     for (Invoice invoice in invoices) {
//       if (invoice.isSynced == 0) {
//         if (invoice.deleted == 0) {
//           try {
//             await InvoiceRepositoryRefactor().sendInvoice(invoice);
//             await DBInvoiceRefactor().isSynced(invoice.id, 1);
//             print("Invoice id: ${invoice.id} is synced");
//           } catch (e) {
//             print("Could'nt sync invoice id: ${invoice.id} is synced");
//           }
//         } else if (invoice.name != null && invoice.deleted == 1) {
//           try {
//             await ApiService().deleteInvoiceFromServer(invoice.name);
//             await DBInvoiceRefactor().isSynced(invoice.id, 1);
//             print("Invoice id: ${invoice.id} is synced");
//           } catch (e) {
//             print("Could'nt sync invoice id: ${invoice.id} is synced");
//           }
//         }
//       }
//     }
//     // for (int x = 0; invoices.length > x; x++) {
//     //   if (invoices[x].isSynced == 0 &&
//     //       invoices[x].deleted == 0 &&
//     //       invoices[x].name == null) {
//     //     await _invoiceRefactorService.sendInvoice(invoices[x]);

//     //     await DBInvoice.isSynced(invoices[x].id, 1);
//     //   }
//     //   if (invoices[x].isSynced == 0 && invoices[x].deleted == 1) {
//     //     await ApiService().deleteInvoiceFromServer(invoices[x].name);
//     //     await DBInvoice.isSynced(invoices[x].id, 1);
//     //   }
//     // }
//   }

//   static printInvoice(int invoiceId, Map<String, double> map) async {
//     // try {
//     //   User user = await DBUser.getSignedInUser();
//     //   POSProfileDetails posProfileDetails =
//     //       await DBPOSProfileDetails.getPOSProfileDetails();

//     //   // get invoice
//     //   Invoice invoice = await DBInvoice.getInvoice(invoiceId);

//     //   // get invoice items
//     //   List<Item> items = await DBInvoice.getItemsOfInvoice(invoiceId);

//     //   ////////////////////////////
//     //   ///
//     //   ///print
//     //   ///

//     //   // logo
//     //   if (posProfileDetails.posLogo == null) {
//     //     ByteData bytes = await rootBundle.load('assets/pos-black-logo.jpg');
//     //     final buffer = bytes.buffer;
//     //     final imgData = base64.encode(Uint8List.view(buffer));
//     //     SunmiPrinter.image(imgData);
//     //   } else {
//     //     // SharedPreferences prefs = await SharedPreferences.getInstance();
//     //     // Uint8List bytes = await networkImageToByte('https://upload.wikimedia.org/wikipedia/sco/thumb/b/bf/KFC_logo.svg/1200px-KFC_logo.svg.png');
//     //     // Uint8List bytes = await networkImageToByte('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPGUyY2wCMtolk4F5GtG1rLqg6rQ140jCnmw&usqp=CAU');
//     //     dynamic bytes;
//     //     if (posProfileDetails.posLogo != null &&
//     //         posProfileDetails.posLogo != '') {
//     //       String localPath = await CacheItemImageService().localPath;
//     //       Io.File file = Io.File('$localPath/invoice-logo.png');
//     //       bytes = await file.readAsBytes();
//     //     } else {
//     //       bytes = await rootBundle.load('assets/pos-black-logo.jpg');
//     //     }
//     //     // Uint8List bytes = await networkImageToByte('${prefs.getString('base_url')}${posProfileDetails.posLogo}');
//     //     // ByteData bytes = await rootBundle.load('assets/pos-black-logo.jpg');
//     //     final buffer = bytes.buffer;
//     //     final imgData = base64.encode(Uint8List.view(buffer));
//     //     SunmiPrinter.image(imgData);
//     //   }

//     //   // company name
//     //   SunmiPrinter.emptyLines(1);
//     //   SunmiPrinter.text(
//     //     posProfileDetails.company,
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.lg),
//     //   );

//     //   // profile name
//     //   SunmiPrinter.emptyLines(1);
//     //   SunmiPrinter.text(
//     //     posProfileDetails.name,
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.lg),
//     //   );

//     //   // posting date
//     //   DateTime dateTime = DateTime.parse(invoice.postingDate);
//     //   SunmiPrinter.emptyLines(1);
//     //   SunmiPrinter.text(
//     //     DateFormat('yyyy-MM-dd – kk:mm:ss').format(dateTime),
//     //     // invoice.postingDate,
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.md),
//     //   );

//     //   // paid or not paid
//     //   SunmiPrinter.emptyLines(1);
//     //   SunmiPrinter.text(
//     //     invoice.isPaid == 1 ? 'مدفوعة' : 'غير مدفوعة',
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.md),
//     //   );

//     //   // empty lines
//     //   SunmiPrinter.emptyLines(2);

//     //   // VAT NO.
//     //   SunmiPrinter.text(
//     //     "الرقم الضريبي ${posProfileDetails.taxId}",
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.md),
//     //   );

//     //   // empty lines
//     //   SunmiPrinter.emptyLines(1);

//     //   // order no
//     //   SunmiPrinter.text(
//     //     "# $invoiceId",
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.xl),
//     //   );

//     //   // empty lines
//     //   SunmiPrinter.emptyLines(1);

//     //   // cashier name
//     //   SunmiPrinter.text(
//     //     "الكاشير ${user.fullName}",
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.md),
//     //   );

//     //   // empty lines
//     //   SunmiPrinter.emptyLines(2);

//     //   // take away or dine in
//     //   if (invoice.tableNo == null) {
//     //     SunmiPrinter.text(
//     //       "Takeaway",
//     //       styles: SunmiStyles(
//     //           bold: true,
//     //           underline: true,
//     //           align: SunmiAlign.center,
//     //           size: SunmiSize.md),
//     //     );
//     //   } else {
//     //     SunmiPrinter.text(
//     //       "Table No. ${invoice.tableNo}",
//     //       styles: SunmiStyles(
//     //           bold: true,
//     //           underline: true,
//     //           align: SunmiAlign.left,
//     //           size: SunmiSize.lg),
//     //     );
//     //   }

//     //   // empty lines
//     //   SunmiPrinter.emptyLines(1);

//     //   // invoice header
//     //   SunmiPrinter.row(
//     //     textSize: SunmiSize.md,
//     //     cols: [
//     //       SunmiCol(text: 'Qty', width: 2, align: SunmiAlign.left),
//     //       SunmiCol(text: 'Item', width: 7, align: SunmiAlign.center),
//     //       SunmiCol(text: 'Price', width: 3, align: SunmiAlign.right),
//     //     ],
//     //   );

//     //   SunmiPrinter.hr();

//     //   // empty lines
//     //   SunmiPrinter.emptyLines(1);

//     //   // items details
//     //   for (int i = 0; i < items.length; i++) {
//     //     SunmiPrinter.row(
//     //       textSize: SunmiSize.md,
//     //       cols: [
//     //         SunmiCol(
//     //             text: items[i].qty.toString(),
//     //             width: 2,
//     //             align: SunmiAlign.left),
//     //         SunmiCol(text: items[i].itemName, width: 7, align: SunmiAlign.left),
//     //         SunmiCol(
//     //             text: (items[i].qty * items[i].rate).toString(),
//     //             width: 3,
//     //             align: SunmiAlign.right),
//     //       ],
//     //     );
//     //     // SunmiPrinter.hr();

//     //     // empty lines
//     //     SunmiPrinter.emptyLines(1);
//     //   }

//     //   // // TOTAL WITHOUT VAT
//     //   // SunmiPrinter.hr();
//     //   // SunmiPrinter.row(
//     //   //   textSize: SunmiSize.lg,
//     //   //   cols: [
//     //   //     SunmiCol(text: '', width: 3, align: SunmiAlign.right),
//     //   //     SunmiCol(text: 'Total', width: 6, align: SunmiAlign.right),
//     //   //     SunmiCol(
//     //   //         text: itemsPriceTotal.toString(),
//     //   //         width: 3,
//     //   //         align: SunmiAlign.right),
//     //   //   ],
//     //   // );

//     //   // VAT
//     //   // SunmiPrinter.row(
//     //   //   textSize: SunmiSize.xl,
//     //   //   cols: [
//     //   //     SunmiCol(text: 'Total Taxex', width: 6, align: SunmiAlign.left),
//     //   //     SunmiCol(
//     //   //         text: ((itemsPriceTotal / 100) * rate).toString(),
//     //   //         width: 3,
//     //   //         align: SunmiAlign.left),
//     //   //     SunmiCol(text: '', width: 3, align: SunmiAlign.left),
//     //   //   ],
//     //   // );

//     //   SunmiPrinter.hr();

//     //   // VAT
//     //   SunmiPrinter.row(
//     //     textSize: SunmiSize.lg,
//     //     cols: [
//     //       SunmiCol(text: 'Taxex', width: 3, align: SunmiAlign.right),
//     //       SunmiCol(text: '', width: 1, align: SunmiAlign.right),
//     //       SunmiCol(
//     //           text: map['vat'].toStringAsFixed(2),
//     //           width: 8,
//     //           align: SunmiAlign.right),
//     //     ],
//     //   );

//     //   // total with vat
//     //   SunmiPrinter.row(
//     //     textSize: SunmiSize.lg,
//     //     cols: [
//     //       SunmiCol(text: 'Total', width: 3, align: SunmiAlign.right),
//     //       SunmiCol(text: '', width: 1, align: SunmiAlign.right),
//     //       SunmiCol(
//     //           text: (map['totalWithVat'].toStringAsFixed(2)),
//     //           width: 8,
//     //           align: SunmiAlign.right),
//     //     ],
//     //   );

//     //   SunmiPrinter.emptyLines(2);

//     //   // time
//     //   SunmiPrinter.text(
//     //     DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now()),
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.md),
//     //   );

//     //   // invoice reference
//     //   SunmiPrinter.text(
//     //     invoice.invoiceReference,
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.md),
//     //   );

//     //   SunmiPrinter.emptyLines(1);

//     //   // thank you
//     //   SunmiPrinter.text(
//     //     'TAHNK YOU',
//     //     styles: SunmiStyles(
//     //         bold: true,
//     //         underline: true,
//     //         align: SunmiAlign.center,
//     //         size: SunmiSize.md),
//     //   );
//     //   // empty lines
//     //   SunmiPrinter.emptyLines(5);

//     //   await SunmiPrinter.cutPaper();
//     // } catch (e) {
//     //   throw e;
//     // }
//   }
// }
