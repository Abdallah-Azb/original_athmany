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
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart' as AnotherImage;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/toas.dart';

class EpsonService {
  PrintInvoiceElements _printInvoiceElements = PrintInvoiceElements();

  printEpsonCashier(Accessory printer, Invoice invoice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString('base_url');
    print("epson service cashier");
    try {
      List<SalesTaxesDetails> salestaxesDetails =
          await DBSalesTaxesDetails().getSalesTaxeDetails();
      bool includedInPrintRate = false;
      for (SalesTaxesDetails salesTaxes in salestaxesDetails) {
        if (salesTaxes.includedInPrintRate == 1) includedInPrintRate = true;
      }

      List<ItemOption> itemsOptionsOfInvoice =
          await DBItemOptions().getItemsOptionsOfInvoice(invoice.id);
      // await getItemsOptionsOfInvoice(invoiceItems);

      InvoiceTotal invoiceTotal = InvoiceRepositoryRefactor()
          .calculateInvoice(invoice.items, salestaxesDetails);

      ProfileDetails posProfileDetails =
          await DBProfileDetails().getProfileDetails();
      User user = await DBUser().getUser();
      print('user id =========== ${user.userId} &&& sid ${user.sid}');
      const PaperSize paper = PaperSize.mm80;
      final profile = await CapabilityProfile.load();
      final printerService = NetworkPrinter(paper, profile);
      final PosPrintResult res =
          await printerService.connect(printer.ip, port: 9100);
      print(printer.ip);
      print(
          "status of connect to printer : ${res.value} ====== ${res.msg} ====== ");
      if (res == PosPrintResult.timeout) {
        await toast("Could not connect to the printer ! try again",
            Colors.yellow.shade800);
      } else if (res == PosPrintResult.printerNotSelected) {
        await toast("printer Not Selected !!", Colors.yellow.shade800);
      } else if (res == PosPrintResult.success) {
        Widget logo =
            await _printInvoiceElements.logoForPrint(posProfileDetails);
        // print('test print logo $logo');
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
            _printInvoiceElements.tableHeader(width: 420),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        Uint8List qrCodeAs8List = await createImageFromWidget(
            _printInvoiceElements.qrCode(invoice.offlineInvoice,
                baseUrl: baseUrl),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        print('inv ref ========= ${invoice.offlineInvoice}');
        String tlvData = _printInvoiceElements.tlvData(
          posProfileDetails.company,
          posProfileDetails.taxId,
          invoice.postingDate,
          invoiceTotal,
        );

        Uint8List tlvQrCodeAs8List = await createImageFromWidget(
            _printInvoiceElements.qrCode(invoice.offlineInvoice, data: tlvData),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        Uint8List titleAs8List = await createImageFromWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _printInvoiceElements.title(),
              ],
            ),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        Uint8List offlineInvoiceAs8List = await createImageFromWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _printInvoiceElements.offlineInvoice(invoice.offlineInvoice,
                    width: 420),
              ],
            ),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        final AnotherImage.Image titleImage =
            AnotherImage.decodeImage(titleAs8List);
        final AnotherImage.Image qrCodeAs8ListImage =
            AnotherImage.decodeImage(qrCodeAs8List);

        final AnotherImage.Image offlineInvoiceImage =
            AnotherImage.decodeImage(offlineInvoiceAs8List);

        final AnotherImage.Image tableHeaderImage =
            AnotherImage.decodeImage(tableHeaderAs8List);

        Uint8List headerAs8List = await createImageFromWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _printInvoiceElements.cashierNameAndPostingDate(
                    user.fullName, invoice.postingDate),
                _printInvoiceElements.vatNo(posProfileDetails.taxId),
                _printInvoiceElements.invoiceStatusAndOrderType(
                    invoice.docStatus, invoice.tableNo),
                _printInvoiceElements.customerName(invoice.customer),
                _printInvoiceElements.orderNo(invoice.id),
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

        Uint8List QrdividerAs8List = await createImageFromWidget(
            _printInvoiceElements.QrDivider(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image QrdividerImage =
            AnotherImage.decodeImage(QrdividerAs8List);
        // printerService.image(logoImage);
        // await invoiceLogo(printerService, posProfileDetails);

        Uint8List addressAs8List = await createImageFromWidget(
            _printInvoiceElements.address(posProfileDetails.address),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image addressImage =
            AnotherImage.decodeImage(addressAs8List);

        printerService.image(titleImage);
        printerService.image(offlineInvoiceImage);
        printerService.image(logoImage);
        printerService.image(companyBranchImage);
        printerService.image(addressImage);
        printerService.image(headerImage);
        printerService.image(tableHeaderImage);
        printerService.image(dividerImage);
        int totalOfItems = 0;
        List<AnotherImage.Image> tableRowImages = [];
        for (Item item in invoice.items) {
          List<ItemOption> itemOptions = itemsOptionsOfInvoice
              .where((e) => e.itemUniqueId == item.uniqueId)
              .toList();
          double itemOptionsTotal = 0;
          for (ItemOption itemOption
              in itemOptions.where((e) => e.optionWith == 1).toList()) {
            itemOptionsTotal += itemOption.priceListRate * item.qty;
          }

          totalOfItems += item.qty;
          // table item row
          Uint8List tableItemRowAs8List = await createImageFromWidget(
              _printInvoiceElements.tableItemRow(item.itemName, item.qty,
                  // price: (item.rate * item.qty)),
                  price: ((item.rate * item.qty) + itemOptionsTotal),
                  itemOptions: itemOptions,
                  width: 420),
              logicalSize: Size(500, 500),
              imageSize: Size(680, 680));
          final AnotherImage.Image tableItemRowImage =
              AnotherImage.decodeImage(tableItemRowAs8List);
          tableRowImages.add(tableItemRowImage);
          printerService.image(tableItemRowImage);
          await Future.delayed(const Duration(milliseconds: 30), () {});
        }

        // table fotter
        Uint8List tableFotterRowAs8List = await createImageFromWidget(
            _printInvoiceElements.tableFotter(
                includedInPrintRate, invoiceTotal, totalOfItems,
                width: 420),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image tableFotterImage =
            AnotherImage.decodeImage(tableFotterRowAs8List);
        // invoice ref & print time
        Uint8List invoiceRefAndPrintTimeAs8List = await createImageFromWidget(
            _printInvoiceElements
                .referenceNoAndPrintTime(invoice.offlineInvoice),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        Uint8List cashierNameAs8List = await createImageFromWidget(
            _printInvoiceElements.cashierName(user.fullName),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        Uint8List closingInvoiceAs8List = await createImageFromWidget(
            _printInvoiceElements.closingInvoice(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        Uint8List eInvoiceAs8List = await createImageFromWidget(
            _printInvoiceElements.eInvoice(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        Uint8List RateTitleArAs8List = await createImageFromWidget(
            _printInvoiceElements.RateTitleAR(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        Uint8List RateTitleEnAs8List = await createImageFromWidget(
            _printInvoiceElements.RateTitleEN(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));

        final AnotherImage.Image invoiceRefAndPrintTimerImage =
            AnotherImage.decodeImage(invoiceRefAndPrintTimeAs8List);

        final AnotherImage.Image cashierNameImage =
            AnotherImage.decodeImage(cashierNameAs8List);

        final AnotherImage.Image closingInvoiceAs8ListImage =
            AnotherImage.decodeImage(closingInvoiceAs8List);

        final AnotherImage.Image eInvoiceAs8ListImage =
            AnotherImage.decodeImage(eInvoiceAs8List);
        final AnotherImage.Image RateArTitleImage =
            AnotherImage.decodeImage(RateTitleArAs8List);

        final AnotherImage.Image RateEnTitleImage =
            AnotherImage.decodeImage(RateTitleEnAs8List);
        // final AnotherImage.Image qrCodeImage =
        //     AnotherImage.decodeImage(qrCodeAs8List);
        final AnotherImage.Image tlvQrCodeImage =
            AnotherImage.decodeImage(tlvQrCodeAs8List);
        printerService.image(dividerImage);
        printerService.image(tableFotterImage);
        printerService.emptyLines(3);
        printerService.image(invoiceRefAndPrintTimerImage);
        // printerService.emptyLines(3);
        printerService.image(cashierNameImage);

        // printerService.image(qrCodeImage);
        // printerService.image(closingInvoiceAs8ListImage);
        // printerService.emptyLines(2);
        printerService.image(tlvQrCodeImage);
        printerService.emptyLines(2);
        String ratingQrInvoice = prefs.getString('rating_qr_invoice');
        if (ratingQrInvoice == '1') {
          printerService.image(QrdividerImage);
          printerService.emptyLines(5);
          printerService.image(RateArTitleImage);
          printerService.image(RateEnTitleImage);
          printerService.image(qrCodeAs8ListImage);
        }
        printerService.emptyLines(1);

        printerService.feed(1);
        printerService.cut();
        printerService.image(dividerImage);
        printerService.drawer();
        print(dividerImage);
        printerService.disconnect();
      } else if (res == PosPrintResult.printerNotSelected) {
        print('no printer selected');
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  printEpsonKitchen(Accessory printer, Invoice invoice) async {
    try {
      const PaperSize paper = PaperSize.mm80;
      final profile = await CapabilityProfile.load();
      final printerService = NetworkPrinter(paper, profile);
      final PosPrintResult res =
          await printerService.connect(printer.ip, port: 9100);
      if (res == PosPrintResult.success) {
        print("KITCHEN SUCCESS");
        User user = await DBUser().getUser();
        Uint8List customerAs8List = await createImageFromWidget(
            _printInvoiceElements.customerName(invoice.customer),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image customerImage =
            AnotherImage.decodeImage(customerAs8List);
        List<CategoriesAccessories> categoriesAccessories =
            await DBCategoriesAccessories.getCategoriesOfAccessory(printer.id);
        List<ItemsGroups> itemsGroups = [];
        for (CategoriesAccessories categoryDevice in categoriesAccessories) {
          ItemsGroups itemsGroup =
              await DBItemsGroup.getItemGroupsById(categoryDevice.categoryId);
          itemsGroups.add(itemsGroup);
        }
        List<Item> categoryItems = [];
        for (ItemsGroups itemsGroup in itemsGroups) {
          for (Item item in invoice.items) {
            if (item.itemGroup == itemsGroup.itemGroup) categoryItems.add(item);
          }
          if (categoryItems.length > 0) {
            printerService.image(customerImage);

            Uint8List heaaderNoAs8List = await createImageFromWidget(
                Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _printInvoiceElements.invoiceStatusAndOrderType(
                          invoice.docStatus, invoice.tableNo),
                      _printInvoiceElements.kitchenNameAndPostingDate(
                          user.fullName, invoice.postingDate),
                      _printInvoiceElements.orderNo(invoice.id),
                    ],
                  ),
                ),
                logicalSize: Size(500, 500),
                imageSize: Size(680, 680));

            final AnotherImage.Image heaaderImage =
                AnotherImage.decodeImage(heaaderNoAs8List);
            printerService.image(heaaderImage);

            List<ItemOption> itemsOptionsOfInvoice =
                await DBItemOptions().getItemsOptionsOfInvoice(invoice.id);

            for (var item in categoryItems) {
              List<ItemOption> itemOptions = itemsOptionsOfInvoice
                  .where((e) => e.itemUniqueId == item.uniqueId)
                  .toList();

              Uint8List tableItemRowAs8List = await createImageFromWidget(
                  _printInvoiceElements.tableItemRow(item.itemName, item.qty,
                      itemOptions: itemOptions, width: 420),
                  logicalSize: Size(500, 500),
                  imageSize: Size(680, 680));
              final AnotherImage.Image logoImage =
                  AnotherImage.decodeImage(tableItemRowAs8List);
              printerService.image(logoImage);
            }

            printerService.emptyLines(1);
            printerService.feed(1);
            printerService.cut();
            print("huh?");
            print(categoryItems);
          }
          categoryItems = [];
        }
        printerService.disconnect();
      }
    } catch (e) {
      print(e);
    }
  }

  // create image from widget
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
}
