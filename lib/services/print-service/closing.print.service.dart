import 'dart:convert';
import 'dart:io';

import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/accessories/models/models.dart';
import 'package:app/modules/auth/models/user.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/modules/closing/models.dart/paymentReconciliation.dart';
import 'package:app/modules/closing/models.dart/pos.transactions.dart';
import 'package:app/modules/invoice/models/models.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.old.dart';
import 'package:app/services/print-service/print.invoice.elements.dart';
import 'package:device_info/device_info.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:flutter_sunmi_printer_t2/flutter_sunmi_printer_t2.dart';
import 'package:image/image.dart' as AnotherImage;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/opening/models/opening.details.dart';
import '../../../core/extensions/time_extension.dart';

class ClosingService {
  PrintInvoiceElements _printInvoiceElements = PrintInvoiceElements();

  printStock(
      Accessory printer,
      ClosingData closingData,
      ProfileDetails posProfileDetails,
      OpeningDetails openingDetails,
      User user,
      {double sizeWidth}) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String baseUrl = prefs.getString('base_url');
    try {
      // List<SalesTaxesDetails> salestaxesDetails =
      //     await DBSalesTaxesDetails().getSalesTaxeDetails();
      // bool includedInPrintRate = false;
      // for (SalesTaxesDetails salesTaxes in salestaxesDetails) {
      //   if (salesTaxes.includedInPrintRate == 1) includedInPrintRate = true;
      // }

      // List<ItemOption> itemsOptionsOfInvoice =
      // await DBItemOptions().getItemsOptionsOfInvoice(invoice.id);
      // await getItemsOptionsOfInvoice(invoiceItems);

      // InvoiceTotal invoiceTotal = InvoiceRepositoryRefactor()
      //     .calculateInvoice(invoice.items, salestaxesDetails);

      const PaperSize paper = PaperSize.mm80;
      final profile = await CapabilityProfile.load();
      final printerService = NetworkPrinter(paper, profile);
      final PosPrintResult res =
          await printerService.connect(printer.ip, port: 9100);
      print(printer.ip);
      if (res == PosPrintResult.success) {
        Widget logo =
            await _printInvoiceElements.logoForPrint(posProfileDetails);
        // print('test print logo $logo');

        // === COMPANY NAME & BRANCH NAME
        Uint8List companyAndBranchNameAs8List = await createImageFromWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                _printInvoiceElements.compnayNameAndBranchName(
                    posProfileDetails.company, posProfileDetails.name),
                //_printInvoiceElements.branchName(posProfileDetails.name),
              ],
            ),
            logicalSize: Size(530, 530),
            imageSize: Size(680, 680));
        print(posProfileDetails.name);
        // logo
        Uint8List logoAs8List = await createImageFromWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                logo,
                SizedBox(height: 20),
                //_printInvoiceElements.branchName(posProfileDetails.name),
              ],
            ),
            logicalSize: Size(530, 530),
            imageSize: Size(680, 680));

        final AnotherImage.Image logoImage =
            AnotherImage.decodeImage(logoAs8List);

        final AnotherImage.Image companyBranchImage =
            AnotherImage.decodeImage(companyAndBranchNameAs8List);
        // table header
        Uint8List tableHeaderAs8List = await createImageFromWidget(
            _printInvoiceElements.StockTableHeader(width: sizeWidth),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        Uint8List stockGroupTableHeaderAs8List = await createImageFromWidget(
            _printInvoiceElements.stockGroupTableHeader(width: sizeWidth),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        // Uint8List qrCodeAs8List = await createImageFromWidget(
        //     _printInvoiceElements.qrCode(invoice.invoiceReference,
        //         baseUrl: baseUrl),
        //     logicalSize: Size(500, 500),
        //     imageSize: Size(680, 680));

        // String tlvData = _printInvoiceElements.tlvData(
        //   posProfileDetails.company,
        //   posProfileDetails.taxId,
        //   invoice.postingDate,
        //   invoiceTotal,
        // );

        // Uint8List tlvQrCodeAs8List = await createImageFromWidget(
        //     _printInvoiceElements.qrCode(invoice.invoiceReference,
        //         data: tlvData),
        //     logicalSize: Size(500, 500),
        //     imageSize: Size(680, 680));

        Uint8List titleAs8List = await createImageFromWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _printInvoiceElements.StockTitle(),
              ],
            ),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        // Uint8List invoiceReferenceAs8List = await createImageFromWidget(
        //     Column(
        //       mainAxisSize: MainAxisSize.min,
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         _printInvoiceElements.invoiceReference(invoice.invoiceReference,
        //             width: 420),
        //       ],
        //     ),
        //     logicalSize: Size(500, 500),
        //     imageSize: Size(680, 680));

        final AnotherImage.Image titleImage =
            AnotherImage.decodeImage(titleAs8List);

        // final AnotherImage.Image invoiceReferenceImage =
        // AnotherImage.decodeImage(invoiceReferenceAs8List);

        final AnotherImage.Image tableHeaderImage =
            AnotherImage.decodeImage(tableHeaderAs8List);
        final AnotherImage.Image stockGroupTableHeaderImage =
            AnotherImage.decodeImage(stockGroupTableHeaderAs8List);
        String time = DateTime.now().toString().modifyFirstHour();
        Uint8List headerAs8List = await createImageFromWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _printInvoiceElements.cashierNameAndPostingDateClosing(
                    user.fullName, time),
                _printInvoiceElements.vatNo(posProfileDetails.taxId),
              ],
            ),
            logicalSize: Size(530, 530),
            imageSize: Size(680, 680));
        final AnotherImage.Image headerImage =
            AnotherImage.decodeImage(headerAs8List);

        // divider
        Uint8List dividerAs8List = await createImageFromWidget(
            _printInvoiceElements.divider(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image dividerImage =
            AnotherImage.decodeImage(dividerAs8List);
        // printerService.image(logoImage);
        // await invoiceLogo(printerService, posProfileDetails);

        Uint8List addressAs8List = await createImageFromWidget(
            _printInvoiceElements.address(posProfileDetails.address),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image addressImage =
            AnotherImage.decodeImage(addressAs8List);

        printerService.image(titleImage);
        // printerService.image(invoiceReferenceImage);
        printerService.image(logoImage);
        printerService.image(companyBranchImage);
        printerService.image(addressImage);
        printerService.image(headerImage);
        printerService.image(dividerImage);
        printerService.image(tableHeaderImage);
        printerService.image(dividerImage);
        int totalOfItems = 0;
        List<AnotherImage.Image> tableRowImages = [];
        for (final item in closingData.closingReportStock?.item ?? []) {
          Uint8List tableItemRowAs8List = await createImageFromWidget(
            _printInvoiceElements.TableStockItem(
                item.itemName, item.qty, item.totalAmount,
                width: sizeWidth),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680),
          );
          final tableItemRowImage =
              AnotherImage.decodeImage(tableItemRowAs8List);
          tableRowImages.add(tableItemRowImage);
          printerService.image(tableItemRowImage);
          await Future.delayed(const Duration(milliseconds: 50), () {});
        }
        List<AnotherImage.Image> tableItemGroupsRowImages = [];
        await Future.delayed(const Duration(milliseconds: 350), () {});
        printerService.emptyLines(3);
        // header of itemGroup Table
        printerService.image(stockGroupTableHeaderImage);
        printerService.image(dividerImage);
        for (final itemGroup
            in closingData.closingReportStock?.itemGroup ?? []) {
          final tableItemGroupRowAs8List = await createImageFromWidget(
            _printInvoiceElements.TableStockItem(
              itemGroup.itemGroup,
              itemGroup.qty,
              itemGroup.totalAmount,
              width: sizeWidth,
            ),
            logicalSize: const Size(500, 500),
            imageSize: const Size(680, 680),
          );
          final tableItemGroupRowImage =
              AnotherImage.decodeImage(tableItemGroupRowAs8List);
          tableItemGroupsRowImages.add(tableItemGroupRowImage);
          printerService.image(tableItemGroupRowImage);
        }

        // PAYMENTS TITLE
        Uint8List PaymentTitleAs8List = await createImageFromWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _printInvoiceElements.PaymentsTitle(),
              ],
            ),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        final AnotherImage.Image PaymentTitleImage =
            AnotherImage.decodeImage(PaymentTitleAs8List);

        printerService.image(dividerImage);
        printerService.image(PaymentTitleImage);

        // TYPES OF PAYMENT WITH ITS AMOUNT
        Uint8List modeOfPaymentHeaderAs8List = await createImageFromWidget(
            _printInvoiceElements.modeOfPaymentTableHeader(width: sizeWidth),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image modeOfPaymentHeaderImage =
            AnotherImage.decodeImage(modeOfPaymentHeaderAs8List);

        // --------------------------------------
        // Closing Params Start
        Uint8List openDateAs8List = await createImageFromWidget(
            _printInvoiceElements.closeParamsDetails("تاريخ الإفتتاح",
                openingDetails.periodStartDate.substring(0, 10),
                width: sizeWidth),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image closeParamsDetailsImage =
            AnotherImage.decodeImage(openDateAs8List);

        Uint8List closeDateAs8List = await createImageFromWidget(
            _printInvoiceElements.closeParamsDetails(
                "تاريخ الإغلاق", time.substring(0, 10),
                width: sizeWidth),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image closeDateImage =
            AnotherImage.decodeImage(closeDateAs8List);

        Uint8List openingNameAs8List = await createImageFromWidget(
            _printInvoiceElements.closeParamsDetails(
                "رقم الإفتتاح", openingDetails.name,
                width: sizeWidth),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image openingNameImage =
            AnotherImage.decodeImage(openingNameAs8List);

        Uint8List userNameAs8List = await createImageFromWidget(
            _printInvoiceElements.closeParamsDetails("اسم الكاشير", user.userId,
                width: sizeWidth),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image userNameImage =
            AnotherImage.decodeImage(userNameAs8List);

        // --------------------------------------
        // Closing Params end

        printerService.image(modeOfPaymentHeaderImage);

        List<AnotherImage.Image> tableRowImagesPayments = [];

        closingData.paymentReconciliations.forEach((element) async {
          Uint8List tableItemRowAs8List = await createImageFromWidget(
              _printInvoiceElements.TableModeOfPaymentsItem(
                  element.modeOfPayment, element.expectedAmount,
                  width: sizeWidth),
              logicalSize: Size(500, 500),
              imageSize: Size(680, 680));
          final AnotherImage.Image paymentItemsRowImage =
              AnotherImage.decodeImage(tableItemRowAs8List);
          tableRowImagesPayments.add(paymentItemsRowImage);
          printerService.image(paymentItemsRowImage);
          print("modeOfPayment  ===== ${element.modeOfPayment}");
          print("expectedAmount  ===== ${element.expectedAmount}");
          await Future.delayed(const Duration(milliseconds: 350), () {});
        });

        Uint8List StockTotalDetailsAs8List = await createImageFromWidget(
            _printInvoiceElements.StockTotalDetails(closingData),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        Uint8List ClosingGrandTotalAs8List = await createImageFromWidget(
            _printInvoiceElements.ClosingGrandTotal(closingData.grandTotal),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        Uint8List closingInvoiceAs8List = await createImageFromWidget(
            _printInvoiceElements.closingInvoice(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        // final AnotherImage.Image invoiceRefAndPrintTimerImage =
        // AnotherImage.decodeImage(invoiceRefAndPrintTimeAs8List);

        final AnotherImage.Image StockTotalDetailsImage =
            AnotherImage.decodeImage(StockTotalDetailsAs8List);

        // closeParamsDetailsImage
        // closeDateImage
        // openingNameImage
        // userNameImage

        final AnotherImage.Image ClosingGrandTotalImage =
            AnotherImage.decodeImage(ClosingGrandTotalAs8List);

        final AnotherImage.Image closingInvoiceAs8ListImage =
            AnotherImage.decodeImage(closingInvoiceAs8List);
        // final AnotherImage.Image qrCodeImage =
        //     AnotherImage.decodeImage(qrCodeAs8List);
        // final AnotherImage.Image tlvQrCodeImage =
        // AnotherImage.decodeImage(tlvQrCodeAs8List);
        printerService.image(dividerImage);
        // printerService.image(tableFotterImage);
        printerService.emptyLines(3);
        // printerService.image(invoiceRefAndPrintTimerImage);
        // printerService.emptyLines(3);
        printerService.image(StockTotalDetailsImage);

        printerService.emptyLines(1);
        printerService.image(dividerImage);
        printerService.emptyLines(1);
        // closing details
        printerService.image(closeParamsDetailsImage);
        printerService.image(closeDateImage);
        printerService.image(openingNameImage);
        printerService.image(userNameImage);
        // printerService.image(ClosingGrandTotalImage);
        // printerService.image(qrCodeImage);
        // printerService.image(closingInvoiceAs8ListImage);
        printerService.emptyLines(3);
        // printerService.image(tlvQrCodeImage);
        printerService.emptyLines(1);
        printerService.feed(1);
        printerService.cut();
        printerService.drawer();
        print(dividerImage);
        printerService.disconnect();
      } else if (res == PosPrintResult.printerNotSelected) {
        print('no printer selected');
      }
      // 192.168.0.196
    } catch (e) {
      print(e);
    }
  }

  // printSunmiClosing(
  //   ClosingData closingData,
  //   ProfileDetails posProfileDetails,
  //   OpeningDetails openingDetails,
  //   User user,
  // ) async {
  //   bool smallPrinter = false;
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     var androidDeviceInfo = await deviceInfo.androidInfo;
  //     if (androidDeviceInfo.model == 'D2mini') smallPrinter = true;
  //   }
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String baseUrl = prefs.getString('base_url');
  //
  //   List<SalesTaxesDetails> salestaxesDetails =
  //       await DBSalesTaxesDetails().getSalesTaxeDetails();
  //   bool includedInPrintRate = false;
  //   for (SalesTaxesDetails salesTaxes in salestaxesDetails) {
  //     if (salesTaxes.includedInPrintRate == 1) includedInPrintRate = true;
  //   }
  //
  //   // List<ItemOption> itemsOptionsOfInvoice =
  //   // await DBItemOptions().getItemsOptionsOfInvoice(invoice.id);
  //   // await getItemsOptionsOfInvoice(invoiceItems);
  //
  //   ProfileDetails posProfileDetails =
  //       await DBProfileDetails().getProfileDetails();
  //   User user = await DBUser().getUser();
  //
  //   double invoiceTotal = closingData.grandTotal;
  //
  //   // divider
  //   ByteData dividerByte = await createImageFromWidgetNew(
  //       _printInvoiceElements.divider(),
  //       logicalSize: Size(500, 500),
  //       imageSize: Size(680, 680));
  //
  //   // invoice header
  //   Widget logo = await _printInvoiceElements.logoForPrint(posProfileDetails);
  //
  //   // تقرير الاصناف او Z report
  //   ByteData titleAs8List = await createImageFromWidgetNew(
  //       Container(
  //         color: Colors.white,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             _printInvoiceElements.StockTitle(),
  //           ],
  //         ),
  //       ),
  //       logicalSize: Size(500, 500),
  //       imageSize: Size(680, 680));
  //
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(titleAs8List.buffer)));
  //
  //   // invoice ref
  //   // ByteData invoiceRefNoAndPrintTimeByte = await createImageFromWidgetNew(
  //   //   Column(
  //   //     mainAxisSize: MainAxisSize.min,
  //   //     mainAxisAlignment: MainAxisAlignment.center,
  //   //     children: [
  //   //       _printInvoiceElements.invoiceReference(invoice.invoiceReference,
  //   //           width: 420),
  //   //     ],
  //   //   ),
  //   //   logicalSize: Size(500, 500),
  //   //   imageSize: Size(680, 680),
  //   // );
  //   // await SunmiPrinter.image(
  //   //     base64.encode(Uint8List.view(invoiceRefNoAndPrintTimeByte.buffer)));
  //
  //   // logo
  //   ByteData invoiceLogoByte = await createImageFromWidgetNew(
  //       Container(
  //         color: Colors.white,
  //         child: logo,
  //       ),
  //       logicalSize: Size(530, 530),
  //       imageSize: Size(680, 680));
  //
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(invoiceLogoByte.buffer)));
  //
  //   // companyAndBranchName
  //   ByteData companyAndBranchNameByte = await createImageFromWidgetNew(
  //       Container(
  //         color: Colors.white,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(height: 20),
  //             _printInvoiceElements.compnayNameAndBranchName(
  //                 posProfileDetails.company, posProfileDetails.name),
  //           ],
  //         ),
  //       ),
  //       logicalSize: Size(530, 530),
  //       imageSize: Size(680, 680));
  //
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(companyAndBranchNameByte.buffer)));
  //
  //   // address
  //   ByteData addressBiteData = await createImageFromWidgetNew(
  //     _printInvoiceElements.address(posProfileDetails.address),
  //     logicalSize: Size(500, 500),
  //     imageSize: Size(680, 680),
  //   );
  //
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(addressBiteData.buffer)));
  //
  //   // تاريخ اصدار التقرير + الضريبة
  //   String time = DateTime.now().toString();
  //   ByteData headerAs8List = await createImageFromWidgetNew(
  //       Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           _printInvoiceElements.cashierNameAndPostingDateClosing(
  //               user.fullName, time),
  //           _printInvoiceElements.vatNo(posProfileDetails.taxId),
  //         ],
  //       ),
  //       logicalSize: Size(530, 530),
  //       imageSize: Size(680, 680));
  //
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(headerAs8List.buffer)));
  //
  //   //await SunmiPrinter.emptyLines(3);
  //
  //   // cashier name
  //   // ByteData cashierNameByte = await createImageFromWidgetNew(
  //   //     _printInvoiceElements.cashierName(user.fullName),
  //   //     logicalSize: Size(500, 500),
  //   //     imageSize: Size(680, 680));
  //   // await SunmiPrinter.image(
  //   //     base64.encode(Uint8List.view(cashierNameByte.buffer)));
  //
  //   await SunmiPrinter.emptyLines(1);
  //
  //   // Stock table header
  //   ByteData tableHeaderAs8List = await createImageFromWidgetNew(
  //       _printInvoiceElements.StockTableHeader(),
  //       logicalSize: Size(500, 500),
  //       imageSize: Size(680, 680));
  //
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(tableHeaderAs8List.buffer)));
  //
  //   await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
  //
  //   for (final element in closingData.closingReportStock?.item ?? []) {
  //     final tableItemRowAs8List = await createImageFromWidget(
  //       _printInvoiceElements.TableStockItem(
  //         element.itemName,
  //         element.qty,
  //         element.totalAmount,
  //       ),
  //       logicalSize: const Size(500, 500),
  //       imageSize: const Size(680, 680),
  //     );
  //
  //     await SunmiPrinter.image(
  //         base64.encode(Uint8List.view(tableItemRowAs8List.buffer)));
  //     await Future.delayed(const Duration(milliseconds: 50), () {});
  //   }
  //
  //   // Stock itemGroup table header //
  //   await SunmiPrinter.emptyLines(3);
  //   await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
  //   ByteData stockGroupTableHeaderAs8List = await createImageFromWidgetNew(
  //       _printInvoiceElements.stockGroupTableHeader(),
  //       logicalSize: Size(500, 500),
  //       imageSize: Size(680, 680));
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(stockGroupTableHeaderAs8List.buffer)));
  //   await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
  //
  //   for (final element in closingData.closingReportStock?.itemGroup ?? []) {
  //     final tableItemRowAs8List = await createImageFromWidget(
  //       _printInvoiceElements.TableStockItem(
  //         element.itemGroup,
  //         element.qty,
  //         element.totalAmount,
  //       ),
  //       logicalSize: const Size(500, 500),
  //       imageSize: const Size(680, 680),
  //     );
  //
  //     await SunmiPrinter.image(
  //         base64.encode(Uint8List.view(tableItemRowAs8List.buffer)));
  //     await Future.delayed(const Duration(milliseconds: 50), () {});
  //   }
  //
  //   // PAYMENTS TITLE
  //   ByteData PaymentTitleAs8List = await createImageFromWidgetNew(
  //       Container(
  //         color: Colors.white,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             _printInvoiceElements.PaymentsTitle(),
  //           ],
  //         ),
  //       ),
  //       logicalSize: Size(500, 500),
  //       imageSize: Size(680, 680));
  //
  //   await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(PaymentTitleAs8List.buffer)));
  //   await SunmiPrinter.emptyLines(3);
  //
  //   // TYPES OF PAYMENT WITH ITS AMOUNT
  //   ByteData modeOfPaymentHeaderAs8List = await createImageFromWidgetNew(
  //       _printInvoiceElements.modeOfPaymentTableHeader(),
  //       logicalSize: Size(500, 500),
  //       imageSize: Size(680, 680));
  //
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(modeOfPaymentHeaderAs8List.buffer)));
  //
  //   closingData.paymentReconciliations.forEach((element) async {
  //     ByteData tableItemRowAs8List = await createImageFromWidgetNew(
  //         _printInvoiceElements.TableModeOfPaymentsItem(
  //             element.modeOfPayment, element.expectedAmount),
  //         logicalSize: Size(500, 500),
  //         imageSize: Size(680, 680));
  //
  //     await SunmiPrinter.image(
  //         base64.encode(Uint8List.view(tableItemRowAs8List.buffer)));
  //     print("modeOfPayment  ===== ${element.modeOfPayment}");
  //     print("expectedAmount  ===== ${element.expectedAmount}");
  //     await Future.delayed(const Duration(milliseconds: 350), () {});
  //   });
  //
  //   // total of postranscation & grand total & net total & vat total
  //   ByteData StockTotalDetailsAs8List = await createImageFromWidgetNew(
  //       _printInvoiceElements.StockTotalDetails(closingData),
  //       logicalSize: Size(500, 500),
  //       imageSize: Size(680, 680));
  //
  //   await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
  //
  //   await SunmiPrinter.image(
  //       base64.encode(Uint8List.view(StockTotalDetailsAs8List.buffer)));
  //
  //   await SunmiPrinter.image(base64.encode(Uint8List.view(dividerByte.buffer)));
  //   await SunmiPrinter.emptyLines(3);
  //
  //   // invoice table fotter
  //   // ByteData invoiceTableFotterByte = await createImageFromWidgetNew(
  //   //     _printInvoiceElements.ClosingGrandTotal(grandTotal),
  //   //     logicalSize: Size(500, 500),
  //   //     imageSize: Size(680, 680));
  //   // await SunmiPrinter.image(
  //   //     base64.encode(Uint8List.view(invoiceTableFotterByte.buffer)));
  //
  //   await SunmiPrinter.emptyLines(2);
  //
  //   // qr code
  //   // ByteData qrBiteData = await createImageFromWidgetNew(
  //   //   _printInvoiceElements.qrCode(baseUrl, invoice.invoiceReference),
  //   //   logicalSize: Size(500, 500),
  //   //   imageSize: Size(680, 680),
  //   // );
  //
  //   // String tlvData = _printInvoiceElements.tlvData(
  //   //   posProfileDetails.company,
  //   //   posProfileDetails.taxId,
  //   //   invoice.postingDate,
  //   //   invoiceTotal,
  //   // );
  //
  //   // qr code
  //   // ByteData tlvQrBiteData = await createImageFromWidgetNew(
  //   //   _printInvoiceElements.qrCode(invoice.invoiceReference, data: tlvData),
  //   //   logicalSize: Size(500, 500),
  //   //   imageSize: Size(680, 680),
  //   // );
  //
  //   await SunmiPrinter.emptyLines(3);
  //
  //   // await SunmiPrinter.image(base64.encode(Uint8List.view(qrBiteData.buffer)));
  //
  //   // await SunmiPrinter.image(
  //   //     base64.encode(Uint8List.view(tlvQrBiteData.buffer)));
  //
  //   await SunmiPrinter.emptyLines(1);
  //
  //   await SunmiPrinter.emptyLines(3);
  //   await SunmiPrinter.cutPaper();
  // }

  Future<Uint8List> createImageFromWidget(Widget widget,
      {Duration wait, Size logicalSize, Size imageSize}) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    logicalSize ??= ui.window.physicalSize / ui.window.devicePixelRatio;
    imageSize ??= ui.window.physicalSize;

    assert(logicalSize.aspectRatio == imageSize.aspectRatio);

    final RenderView renderView = RenderView(
      window: null,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();

    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(textDirection: TextDirection.rtl, child: widget),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    if (wait != null) {
      await Future.delayed(wait);
    }

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
        pixelRatio: imageSize.width / logicalSize.width);
    final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData.buffer.asUint8List();
  }

  // create image from widget
  Future<ByteData> createImageFromWidgetNew(Widget widget,
      {Duration wait, Size logicalSize, Size imageSize}) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    logicalSize ??= ui.window.physicalSize / ui.window.devicePixelRatio;
    imageSize ??= ui.window.physicalSize;

    assert(logicalSize.aspectRatio == imageSize.aspectRatio);

    final RenderView renderView = RenderView(
      window: null,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();

    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(textDirection: TextDirection.rtl, child: widget),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    if (wait != null) {
      await Future.delayed(wait);
    }

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
        pixelRatio: imageSize.width / logicalSize.width);
    final ByteData byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData;
    // return byteData.buffer.asUint8List();
  }
}
