// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui';
// import 'dart:ui' as ui;
//
// import 'package:app/db-operations/db.categories.accessories.dart';
// import 'package:app/db-operations/db.item.options.dart';
// import 'package:app/db-operations/db.items.group.dart';
// import 'package:app/db-operations/db.profile.details.dart';
// import 'package:app/db-operations/db.sales.taxes.details.dart';
// import 'package:app/db-operations/db.user.dart';
// import 'package:app/models/models.dart';
// import 'package:app/models/profile.details.dart';
// import 'package:app/modules/accessories/models/models.dart';
// import 'package:app/modules/auth/models/models.dart';
// import 'package:app/modules/closing/models.dart/closing.data.dart';
// import 'package:app/modules/closing/models.dart/paymentReconciliation.dart';
// import 'package:app/modules/closing/models.dart/pos.transactions.dart';
// import 'package:app/modules/invoice/models/models.dart';
// import 'package:app/modules/invoice/repositories/invoice.repository.refactor.old.dart';
// import 'package:app/services/print-service/print.invoice.elements.dart';
// import 'package:device_info/device_info.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter_sunmi_printer_t2/flutter_sunmi_printer_t2.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../modules/opening/models/opening.details.dart';
//
// class SunmiService {
//   PrintInvoiceElements _printInvoiceElements = PrintInvoiceElements();
//   printSunmiCashier(Invoice invoice) async {
//     bool smallPrinter = false;
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     if (Platform.isAndroid) {
//       var androidDeviceInfo = await deviceInfo.androidInfo;
//       if (androidDeviceInfo.model == 'D2mini') smallPrinter = true;
//     }
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String baseUrl = prefs.getString('base_url');
//
//     List<SalesTaxesDetails> salestaxesDetails =
//         await DBSalesTaxesDetails().getSalesTaxeDetails();
//     bool includedInPrintRate = false;
//     for (SalesTaxesDetails salesTaxes in salestaxesDetails) {
//       if (salesTaxes.includedInPrintRate == 1) includedInPrintRate = true;
//     }
//
//     List<ItemOption> itemsOptionsOfInvoice =
//         await DBItemOptions().getItemsOptionsOfInvoice(invoice.id);
//     // await getItemsOptionsOfInvoice(invoiceItems);
//
//     ProfileDetails posProfileDetails =
//         await DBProfileDetails().getProfileDetails();
//     User user = await DBUser().getUser();
//
//     InvoiceTotal invoiceTotal = InvoiceRepositoryRefactor()
//         .calculateInvoice(invoice.items, salestaxesDetails);
//
//     // divider
//     ByteData dividerByte = await createImageFromWidgetNew(
//         _printInvoiceElements.divider(),
//         logicalSize: Size(500, 500),
//         imageSize: Size(680, 680));
//
//     // invoice header
//     Widget logo = await _printInvoiceElements.logoForPrint(posProfileDetails);
//
//     // فاتورة ضريبية مبسطة
//     ByteData titleByte = await createImageFromWidgetNew(
//         Container(
//           color: Colors.white,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _printInvoiceElements.title(),
//             ],
//           ),
//         ),
//         logicalSize: Size(530, 530),
//         imageSize: Size(680, 680));
//
//     await SunmiPrinter.image(base64.encode(Uint8List.view(titleByte.buffer)));
//
//     // invoice ref
//     ByteData invoiceRefNoAndPrintTimeByte = await createImageFromWidgetNew(
//       Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _printInvoiceElements.offlineInvoice(invoice.offlineInvoice,
//               width: 420),
//         ],
//       ),
//       logicalSize: Size(500, 500),
//       imageSize: Size(680, 680),
//     );
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(invoiceRefNoAndPrintTimeByte.buffer)));
//
//     // logo
//     ByteData invoiceLogoByte = await createImageFromWidgetNew(
//         Container(
//           color: Colors.white,
//           child: logo,
//         ),
//         logicalSize: Size(530, 530),
//         imageSize: Size(680, 680));
//
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(invoiceLogoByte.buffer)));
//
//     // companyAndBranchName
//     ByteData companyAndBranchNameByte = await createImageFromWidgetNew(
//         Container(
//           color: Colors.white,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SizedBox(height: 20),
//               _printInvoiceElements.compnayNameAndBranchName(
//                   posProfileDetails.company, posProfileDetails.name),
//             ],
//           ),
//         ),
//         logicalSize: Size(530, 530),
//         imageSize: Size(680, 680));
//
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(companyAndBranchNameByte.buffer)));
//
//     // address
//     ByteData addressBiteData = await createImageFromWidgetNew(
//       _printInvoiceElements.address(posProfileDetails.address),
//       logicalSize: Size(500, 500),
//       imageSize: Size(680, 680),
//     );
//
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(addressBiteData.buffer)));
//
//     ByteData invoiceHeaderByte = await createImageFromWidgetNew(
//         Container(
//           color: Colors.white,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _printInvoiceElements.cashierNameAndPostingDate(
//                   user.fullName, invoice.postingDate),
//               _printInvoiceElements.vatNo(posProfileDetails.taxId),
//               _printInvoiceElements.invoiceStatusAndOrderType(
//                   invoice.docStatus, invoice.tableNo),
//               _printInvoiceElements.customerName(invoice.customer),
//               _printInvoiceElements.orderNo(invoice.id),
//             ],
//           ),
//         ),
//         logicalSize: Size(530, 530),
//         imageSize: Size(680, 680));
//
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(invoiceHeaderByte.buffer)));
//
//     // invoice table header
//     ByteData invoicetableHeaderByte = await createImageFromWidgetNew(
//         _printInvoiceElements.tableHeader(width: 420),
//         logicalSize: Size(500, 500),
//         imageSize: Size(680, 680));
//
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(invoicetableHeaderByte.buffer)));
//
//     await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
//
//     int totalOfItems = 0;
//     for (Item item in invoice.items) {
//       List<ItemOption> itemOptions = itemsOptionsOfInvoice
//           .where((e) => e.itemUniqueId == item.uniqueId)
//           .toList();
//       double itemOptionsTotal = 0;
//       for (ItemOption itemOption
//           in itemOptions.where((e) => e.optionWith == 1).toList()) {
//         itemOptionsTotal += itemOption.priceListRate * item.qty;
//       }
//
//       totalOfItems += item.qty;
//       // table item row
//       ByteData invoicetableItemRowByte = await createImageFromWidgetNew(
//           _printInvoiceElements.tableItemRow(item.itemName, item.qty,
//               price: ((item.rate * item.qty) + itemOptionsTotal),
//               itemOptions: itemOptions,
//               width: 420),
//           logicalSize: Size(500, 500),
//           imageSize: Size(680, 680));
//       await SunmiPrinter.image(
//           base64.encode(Uint8List.view(invoicetableItemRowByte.buffer)));
//     }
//
//     await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
//
//     // invoice table fotter
//     ByteData invoiceTableFotterByte = await createImageFromWidgetNew(
//         _printInvoiceElements.tableFotter(
//             includedInPrintRate, invoiceTotal, totalOfItems,
//             width: 420),
//         logicalSize: Size(500, 500),
//         imageSize: Size(680, 680));
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(invoiceTableFotterByte.buffer)));
//
//     await SunmiPrinter.emptyLines(2);
//
//     // print time
//     ByteData PrintTimeByte = await createImageFromWidgetNew(
//         _printInvoiceElements.referenceNoAndPrintTime(invoice.offlineInvoice),
//         logicalSize: Size(500, 500),
//         imageSize: Size(680, 680));
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(PrintTimeByte.buffer)));
//
//     //await SunmiPrinter.emptyLines(3);
//
//     // cashier name
//     ByteData cashierNameByte = await createImageFromWidgetNew(
//         _printInvoiceElements.cashierName(user.fullName),
//         logicalSize: Size(500, 500),
//         imageSize: Size(680, 680));
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(cashierNameByte.buffer)));
//
//     await SunmiPrinter.emptyLines(3);
//
//     // qr code
//     // ByteData qrBiteData = await createImageFromWidgetNew(
//     //   _printInvoiceElements.qrCode(baseUrl, invoice.offlineInvoice),
//     //   logicalSize: Size(500, 500),
//     //   imageSize: Size(680, 680),
//     // );
//
//     String tlvData = _printInvoiceElements.tlvData(
//       posProfileDetails.company,
//       posProfileDetails.taxId,
//       invoice.postingDate,
//       invoiceTotal,
//     );
//
//     // qr code
//     ByteData tlvQrBiteData = await createImageFromWidgetNew(
//       _printInvoiceElements.qrCode(invoice.offlineInvoice, data: tlvData),
//       logicalSize: Size(500, 500),
//       imageSize: Size(680, 680),
//     );
//
//     ByteData QrdividerAs8List = await createImageFromWidgetNew(
//         _printInvoiceElements.QrDivider(),
//         logicalSize: Size(500, 500),
//         imageSize: Size(680, 680));
//
//     ByteData RateArTitleAs8List = await createImageFromWidgetNew(
//         _printInvoiceElements.RateTitleAR(),
//         logicalSize: Size(500, 500),
//         imageSize: Size(680, 680));
//     ByteData RateEnTitleAs8List = await createImageFromWidgetNew(
//         _printInvoiceElements.RateTitleEN(),
//         logicalSize: Size(500, 500),
//         imageSize: Size(680, 680));
//
//     ByteData RateQrBiteData = await createImageFromWidgetNew(
//       _printInvoiceElements.qrCode(invoice.offlineInvoice, baseUrl: baseUrl),
//       logicalSize: Size(500, 500),
//       imageSize: Size(680, 680),
//     );
//
//     await SunmiPrinter.emptyLines(3);
//
//     // await SunmiPrinter.image(base64.encode(Uint8List.view(qrBiteData.buffer)));
//
//     await SunmiPrinter.image(
//         base64.encode(Uint8List.view(tlvQrBiteData.buffer)));
//
//     await SunmiPrinter.emptyLines(2);
//     String ratingQrInvoice = prefs.getString('rating_qr_invoice');
//     if (ratingQrInvoice == '1') {
//       await SunmiPrinter.image(
//           base64.encode(Uint8List.view(QrdividerAs8List.buffer)));
//       await SunmiPrinter.emptyLines(2);
//
//       await SunmiPrinter.image(
//           base64.encode(Uint8List.view(RateArTitleAs8List.buffer)));
//       await SunmiPrinter.image(
//           base64.encode(Uint8List.view(RateEnTitleAs8List.buffer)));
//       await SunmiPrinter.image(
//           base64.encode(Uint8List.view(RateQrBiteData.buffer)));
//     }
//
//     await SunmiPrinter.emptyLines(1);
//
//     await SunmiPrinter.emptyLines(3);
//     await SunmiPrinter.cutPaper();
//   }
//
//   // Accessory printer,
//   //     List<PosTransaction> posTransaction,
//   // List<dynamic> stockItem,
//   //     double grandTotal,
//   // double netTotal,
//   //     List<PaymentReconciliation> payments,
//   // printSunmiClosing(
//   //   ClosingData closingData,
//   //   ProfileDetails posProfileDetails,
//   //   OpeningDetails openingDetails,
//   //   User user,
//   // ) async {
//   //   bool smallPrinter = false;
//   //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   //   if (Platform.isAndroid) {
//   //     var androidDeviceInfo = await deviceInfo.androidInfo;
//   //     if (androidDeviceInfo.model == 'D2mini') smallPrinter = true;
//   //   }
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   String baseUrl = prefs.getString('base_url');
//   //
//   //   List<SalesTaxesDetails> salestaxesDetails =
//   //       await DBSalesTaxesDetails().getSalesTaxeDetails();
//   //   bool includedInPrintRate = false;
//   //   for (SalesTaxesDetails salesTaxes in salestaxesDetails) {
//   //     if (salesTaxes.includedInPrintRate == 1) includedInPrintRate = true;
//   //   }
//   //
//   //   // List<ItemOption> itemsOptionsOfInvoice =
//   //   // await DBItemOptions().getItemsOptionsOfInvoice(invoice.id);
//   //   // await getItemsOptionsOfInvoice(invoiceItems);
//   //
//   //   double invoiceTotal = closingData.grandTotal;
//   //
//   //   // divider
//   //   ByteData dividerByte = await createImageFromWidgetNew(
//   //       _printInvoiceElements.divider(),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   // invoice header
//   //   Widget logo = await _printInvoiceElements.logoForPrint(posProfileDetails);
//   //
//   //   // تقرير الاصناف او Z report
//   //   ByteData titleAs8List = await createImageFromWidgetNew(
//   //       Column(
//   //         mainAxisSize: MainAxisSize.min,
//   //         mainAxisAlignment: MainAxisAlignment.center,
//   //         children: [
//   //           _printInvoiceElements.StockTitle(),
//   //         ],
//   //       ),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(titleAs8List.buffer)));
//   //
//   //   // invoice ref
//   //   // ByteData invoiceRefNoAndPrintTimeByte = await createImageFromWidgetNew(
//   //   //   Column(
//   //   //     mainAxisSize: MainAxisSize.min,
//   //   //     mainAxisAlignment: MainAxisAlignment.center,
//   //   //     children: [
//   //   //       _printInvoiceElements.offlineInvoice(invoice.offlineInvoice,
//   //   //           width: 420),
//   //   //     ],
//   //   //   ),
//   //   //   logicalSize: Size(500, 500),
//   //   //   imageSize: Size(680, 680),
//   //   // );
//   //   // await SunmiPrinter.image(
//   //   //     base64.encode(Uint8List.view(invoiceRefNoAndPrintTimeByte.buffer)));
//   //
//   //   // logo
//   //   ByteData invoiceLogoByte = await createImageFromWidgetNew(
//   //       Container(
//   //         color: Colors.white,
//   //         child: logo,
//   //       ),
//   //       logicalSize: Size(530, 530),
//   //       imageSize: Size(680, 680));
//   //
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(invoiceLogoByte.buffer)));
//   //
//   //   // companyAndBranchName
//   //   ByteData companyAndBranchNameByte = await createImageFromWidgetNew(
//   //       Container(
//   //         color: Colors.white,
//   //         child: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             SizedBox(height: 20),
//   //             _printInvoiceElements.compnayNameAndBranchName(
//   //                 posProfileDetails.company, posProfileDetails.name),
//   //           ],
//   //         ),
//   //       ),
//   //       logicalSize: Size(530, 530),
//   //       imageSize: Size(680, 680));
//   //
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(companyAndBranchNameByte.buffer)));
//   //
//   //   // address
//   //   ByteData addressBiteData = await createImageFromWidgetNew(
//   //     _printInvoiceElements.address(posProfileDetails.address),
//   //     logicalSize: Size(500, 500),
//   //     imageSize: Size(680, 680),
//   //   );
//   //
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(addressBiteData.buffer)));
//   //
//   //   // print time
//   //   ByteData PrintTimeByte = await createImageFromWidgetNew(
//   //       _printInvoiceElements.closingInvoice(),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(PrintTimeByte.buffer)));
//   //
//   //   //await SunmiPrinter.emptyLines(3);
//   //
//   //   // cashier name
//   //   ByteData cashierNameByte = await createImageFromWidgetNew(
//   //       _printInvoiceElements.cashierName(user.fullName),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(cashierNameByte.buffer)));
//   //
//   //   await SunmiPrinter.emptyLines(3);
//   //
//   //   ByteData invoiceHeaderByte = await createImageFromWidgetNew(
//   //       Container(
//   //         color: Colors.white,
//   //         child: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             _printInvoiceElements.ClosingTableHeader(width: 420),
//   //           ],
//   //         ),
//   //       ),
//   //       logicalSize: Size(530, 530),
//   //       imageSize: Size(680, 680));
//   //
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(invoiceHeaderByte.buffer)));
//   //
//   //   // invoice table header
//   //   ByteData invoicetableHeaderByte = await createImageFromWidgetNew(
//   //       _printInvoiceElements.tableHeader(width: 420),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(invoicetableHeaderByte.buffer)));
//   //
//   //   await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
//   //
//   //   closingData.stockItems.forEach((element) async {
//   //     print(' element 0 ===== ${element[0]}');
//   //     print(' element 1 ===== ${element[1]}');
//   //     print(' element 2 ===== ${element[2]}');
//   //     print(' element 3 ===== ${element[3]}');
//   //
//   //     ByteData tableItemRowAs8List = await createImageFromWidgetNew(
//   //         _printInvoiceElements.TableStockItem(
//   //           element[0],
//   //           element[1],
//   //           element[2],
//   //           element[3],
//   //         ),
//   //         logicalSize: Size(500, 500),
//   //         imageSize: Size(680, 680));
//   //
//   //     await SunmiPrinter.image(
//   //         base64.encode(Uint8List.view(tableItemRowAs8List.buffer)));
//   //     await Future.delayed(const Duration(milliseconds: 50), () {});
//   //   });
//   //
//   //   // PAYMENTS TITLE
//   //   ByteData PaymentTitleAs8List = await createImageFromWidgetNew(
//   //       Column(
//   //         mainAxisSize: MainAxisSize.min,
//   //         mainAxisAlignment: MainAxisAlignment.center,
//   //         children: [
//   //           _printInvoiceElements.PaymentsTitle(),
//   //         ],
//   //       ),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(PaymentTitleAs8List.buffer)));
//   //
//   //   // TYPES OF PAYMENT WITH ITS AMOUNT
//   //   ByteData modeOfPaymentHeaderAs8List = await createImageFromWidgetNew(
//   //       _printInvoiceElements.modeOfPaymentTableHeader(),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(PaymentTitleAs8List.buffer)));
//   //
//   //   closingData.paymentReconciliations.forEach((element) async {
//   //     ByteData tableItemRowAs8List = await createImageFromWidgetNew(
//   //         _printInvoiceElements.TableModeOfPaymentsItem(
//   //             element.modeOfPayment, element.expectedAmount),
//   //         logicalSize: Size(500, 500),
//   //         imageSize: Size(680, 680));
//   //
//   //     await SunmiPrinter.image(
//   //         base64.encode(Uint8List.view(tableItemRowAs8List.buffer)));
//   //     print("modeOfPayment  ===== ${element.modeOfPayment}");
//   //     print("expectedAmount  ===== ${element.expectedAmount}");
//   //     await Future.delayed(const Duration(milliseconds: 350), () {});
//   //   });
//   //
//   //   // total of postranscation & grand total & net total & vat total
//   //   ByteData StockTotalDetailsAs8List = await createImageFromWidgetNew(
//   //       _printInvoiceElements.StockTotalDetails(closingData),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(StockTotalDetailsAs8List.buffer)));
//   //
//   //   await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
//   //
//   //   // --------------------------------------
//   //   // Closing Params Start
//   //
//   //   // Date of Now :
//   //   String time = DateTime.now().toString();
//   //
//   //   ByteData openDateAs8List = await createImageFromWidgetNew(
//   //       _printInvoiceElements.closeParamsDetails(
//   //           "تاريخ الإفتتاح", openingDetails.periodStartDate.substring(0, 10)),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   ByteData closeDateAs8List = await createImageFromWidgetNew(
//   //       _printInvoiceElements.closeParamsDetails(
//   //           "تاريخ الإغلاق", time.substring(0, 10)),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   ByteData openingNameAs8List = await createImageFromWidgetNew(
//   //       _printInvoiceElements.closeParamsDetails(
//   //           "رقم الإفتتاح", openingDetails.name),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   ByteData userIdAs8List = await createImageFromWidgetNew(
//   //       _printInvoiceElements.closeParamsDetails("اسم الكاشير", user.userId),
//   //       logicalSize: Size(500, 500),
//   //       imageSize: Size(680, 680));
//   //
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(openDateAs8List.buffer)));
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(closeDateAs8List.buffer)));
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(openingNameAs8List.buffer)));
//   //   await SunmiPrinter.image(
//   //       base64.encode(Uint8List.view(userIdAs8List.buffer)));
//   //
//   //   // --------------------------------------
//   //   // Closing Params end
//   //
//   //   await SunmiPrinter.emptyLines(3);
//   //
//   //   // invoice table fotter
//   //   // ByteData invoiceTableFotterByte = await createImageFromWidgetNew(
//   //   //     _printInvoiceElements.ClosingGrandTotal(grandTotal),
//   //   //     logicalSize: Size(500, 500),
//   //   //     imageSize: Size(680, 680));
//   //   // await SunmiPrinter.image(
//   //   //     base64.encode(Uint8List.view(invoiceTableFotterByte.buffer)));
//   //
//   //   await SunmiPrinter.emptyLines(2);
//   //
//   //   // qr code
//   //   // ByteData qrBiteData = await createImageFromWidgetNew(
//   //   //   _printInvoiceElements.qrCode(baseUrl, invoice.offlineInvoice),
//   //   //   logicalSize: Size(500, 500),
//   //   //   imageSize: Size(680, 680),
//   //   // );
//   //
//   //   // String tlvData = _printInvoiceElements.tlvData(
//   //   //   posProfileDetails.company,
//   //   //   posProfileDetails.taxId,
//   //   //   invoice.postingDate,
//   //   //   invoiceTotal,
//   //   // );
//   //
//   //   // qr code
//   //   // ByteData tlvQrBiteData = await createImageFromWidgetNew(
//   //   //   _printInvoiceElements.qrCode(invoice.offlineInvoice, data: tlvData),
//   //   //   logicalSize: Size(500, 500),
//   //   //   imageSize: Size(680, 680),
//   //   // );
//   //
//   //   await SunmiPrinter.emptyLines(3);
//   //
//   //   // await SunmiPrinter.image(base64.encode(Uint8List.view(qrBiteData.buffer)));
//   //
//   //   // await SunmiPrinter.image(
//   //   //     base64.encode(Uint8List.view(tlvQrBiteData.buffer)));
//   //
//   //   await SunmiPrinter.emptyLines(1);
//   //
//   //   await SunmiPrinter.emptyLines(3);
//   //   await SunmiPrinter.cutPaper();
//   // }
//
//   printSunmiKitchen(Accessory device, Invoice invoice) async {
//     try {
//       // customer
//       ByteData customerBiteData = await createImageFromWidgetNew(
//         _printInvoiceElements.customerName(invoice.customer),
//         logicalSize: Size(500, 500),
//         imageSize: Size(680, 680),
//       );
//
//       List<CategoriesAccessories> categoriesAccessories =
//           await DBCategoriesAccessories.getCategoriesOfAccessory(device.id);
//
//       List<ItemsGroups> itemsGroups = [];
//       for (CategoriesAccessories categoryDevice in categoriesAccessories) {
//         ItemsGroups itemsGroup =
//             await DBItemsGroup.getItemGroupsById(categoryDevice.categoryId);
//         itemsGroups.add(itemsGroup);
//       }
//
//       List<Item> categoryItems = [];
//       for (ItemsGroups itemsGroup in itemsGroups) {
//         for (Item item in invoice.items) {
//           if (item.itemGroup == itemsGroup.itemGroup) categoryItems.add(item);
//         }
//         if (categoryItems.length > 0) {
//           await SunmiPrinter.image(
//               base64.encode(Uint8List.view(customerBiteData.buffer)));
//
//           // ref no & order type
//           ByteData refNoAndOrderTypeByte = await createImageFromWidgetNew(
//               _printInvoiceElements.invoiceStatusAndOrderType(
//                   invoice.docStatus, invoice.tableNo),
//               logicalSize: Size(500, 500),
//               imageSize: Size(680, 680));
//           await SunmiPrinter.image(
//               base64.encode(Uint8List.view(refNoAndOrderTypeByte.buffer)));
//
//           // order no
//           ByteData orderNoByte = await createImageFromWidgetNew(
//               _printInvoiceElements.orderNo(invoice.id),
//               logicalSize: Size(500, 500),
//               imageSize: Size(680, 680));
//           await SunmiPrinter.image(
//               base64.encode(Uint8List.view(orderNoByte.buffer)));
//
//           List<ItemOption> itemsOptionsOfInvoice =
//               await DBItemOptions().getItemsOptionsOfInvoice(invoice.id);
//
//           for (var item in categoryItems) {
//             List<ItemOption> itemOptions = itemsOptionsOfInvoice
//                 .where((e) => e.itemUniqueId == item.uniqueId)
//                 .toList();
//
//             // table item row
//             ByteData invoicetableItemRowByte = await createImageFromWidgetNew(
//                 _printInvoiceElements.tableItemRow(item.itemName, item.qty,
//                     itemOptions: itemOptions),
//                 logicalSize: Size(500, 500),
//                 imageSize: Size(680, 680));
//             await SunmiPrinter.image(
//                 base64.encode(Uint8List.view(invoicetableItemRowByte.buffer)));
//           }
//           // empty lines
//           await SunmiPrinter.emptyLines(3);
//           await SunmiPrinter.cutPaper();
//         }
//         categoryItems = [];
//       }
//     } catch (e) {
//       await SunmiPrinter.cutPaper();
//       print(e);
//     }
//   }
//
//   // create image from widget
//   Future<ByteData> createImageFromWidgetNew(Widget widget,
//       {Duration wait, Size logicalSize, Size imageSize}) async {
//     final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
//
//     logicalSize ??= ui.window.physicalSize / ui.window.devicePixelRatio;
//     imageSize ??= ui.window.physicalSize;
//
//     assert(logicalSize.aspectRatio == imageSize.aspectRatio);
//
//     final RenderView renderView = RenderView(
//       window: null,
//       child: RenderPositionedBox(
//           alignment: Alignment.center, child: repaintBoundary),
//       configuration: ViewConfiguration(
//         size: logicalSize,
//         devicePixelRatio: 1.0,
//       ),
//     );
//
//     final PipelineOwner pipelineOwner = PipelineOwner();
//
//     final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
//
//     pipelineOwner.rootNode = renderView;
//     renderView.prepareInitialFrame();
//
//     final RenderObjectToWidgetElement<RenderBox> rootElement =
//         RenderObjectToWidgetAdapter<RenderBox>(
//       container: repaintBoundary,
//       child: Directionality(textDirection: TextDirection.rtl, child: widget),
//     ).attachToRenderTree(buildOwner);
//
//     buildOwner.buildScope(rootElement);
//
//     if (wait != null) {
//       await Future.delayed(wait);
//     }
//
//     buildOwner.buildScope(rootElement);
//     buildOwner.finalizeTree();
//
//     pipelineOwner.flushLayout();
//     pipelineOwner.flushCompositingBits();
//     pipelineOwner.flushPaint();
//
//     final ui.Image image = await repaintBoundary.toImage(
//         pixelRatio: imageSize.width / logicalSize.width);
//     final ByteData byteData =
//         await image.toByteData(format: ui.ImageByteFormat.png);
//
//     return byteData;
//     // return byteData.buffer.asUint8List();
//   }
// }
