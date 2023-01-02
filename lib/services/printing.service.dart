import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:image/image.dart' as AnotherImage;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:app/core/extensions/widget_extension.dart';

class PrintingService {
  // logo
  Widget logo() {
    return Container(
      child: Image.asset(
        'assets/pos-black-logo.jpg',
        color: Colors.black,
        scale: 0.6,
      ).paddingVertical(10) ,
    );
  }

  // company name
  Widget compnayName() {
    return Text('ALQ',
        style: TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold));
  }

  // branch name
  Widget branchName() {
    return Text('فرع الازدهار',
        style: TextStyle(
            color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold));
  }

  // vat no
  Widget vatNo() {
    return Text('VAT No.: 34343434443434',
        style: TextStyle(color: Colors.black, fontSize: 18));
  }

  // order no
  Widget orderNo() {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 10),
      width: 200,
      height: 50,
      padding: EdgeInsets.all(6),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black, width: 2)),
      child: Text('#210',
          style: TextStyle(
              color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold)),
    );
  }

  // cashier name & posting date
  Widget cashierNameAndPostingDate() {
    return Container(
      padding: EdgeInsets.all(6),
      child: Text('Pos Pos | 25-05-2012 13:52:12',
          style: TextStyle(color: Colors.black, fontSize: 18)),
    );
  }

  // invoice status & order type
  Widget invoiceStatusAndOrderType() {
    return Container(
      padding: EdgeInsets.all(6),
      child: Text('Paid | Takeaway',
          style: TextStyle(color: Colors.black, fontSize: 18)),
    );
  }

  // table header
  Widget tableHeader() {
    return Container(
      width: 420,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              flex: 2,
              child: Text('الكمية',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))),
          Flexible(
            flex: 6,
            fit: FlexFit.tight,
            child: Text(
              'الصنف',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              maxLines: 10,
              textAlign: TextAlign.start,
            ),
          ),
          Flexible(
              flex: 2,
              child: Text(
                'السعر',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  // table item row
  Widget tableItemRow() {
    return Container(
      // padding: EdgeInsets.symmetric(vertical: 6),
      width: 420,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              flex: 2,
              child: Text('300',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))),
          Flexible(
            flex: 6,
            fit: FlexFit.tight,
            child: Text('عصير مانجا',
                maxLines: 10,
                textAlign: TextAlign.justify,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
          Flexible(
              flex: 2,
              child: Text('50000',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // table fotter
  Widget tableFotter() {
    return Container(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  flex: 2,
                  child: Text('الضريبة',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
              Flexible(
                flex: 6,
                fit: FlexFit.tight,
                child: Text(
                  '',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  maxLines: 10,
                  textAlign: TextAlign.start,
                ),
              ),
              Flexible(
                  flex: 2,
                  child: Text(
                    '150',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  flex: 2,
                  child: Text('الاجمالي',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
              Flexible(
                flex: 6,
                fit: FlexFit.tight,
                child: Text(
                  '',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  maxLines: 10,
                  textAlign: TextAlign.start,
                ),
              ),
              Flexible(
                  flex: 2,
                  child: Text(
                    '2000',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  // invoice refernce no
  Widget referenceNoAndPrintTime() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(' POS354635403 | 334345434',
            style: TextStyle(color: Colors.black, fontSize: 18)),
        Text('25-05-2012 13:52:12',
            style: TextStyle(color: Colors.black, fontSize: 18)),
      ],
    );
  }

  // divider
  Widget divider() {
    return Container(
      width: 420,
      height: 10,
      child: Divider(
        thickness: 1.5,
        color: Colors.black,
      ),
    );
  }

  printTest() async {
    try {
      const PaperSize paper = PaperSize.mm80;
      final profile = await CapabilityProfile.load();
      final printerService = NetworkPrinter(paper, profile);
      final PosPrintResult res =
          await printerService.connect('192.168.8.109', port: 9100);
      if (res == PosPrintResult.success) {
        // logo
        // Uint8List logoAs8List = await createImageFromWidget(logo(),
        //     logicalSize: Size(500, 500), imageSize: Size(680, 680));
        // final AnotherImage.Image logoImage =
        //     AnotherImage.decodeImage(logoAs8List);
        // company name
        Uint8List companyNameAs8List = await createImageFromWidget(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                compnayName(),
                branchName(),
                vatNo(),
                cashierNameAndPostingDate(),
                invoiceStatusAndOrderType(),
                orderNo(),
              ],
            ),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image companyNameImage =
            AnotherImage.decodeImage(companyNameAs8List);
        // table header
        Uint8List tableHeaderAs8List = await createImageFromWidget(
            tableHeader(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image tableHeaderImage =
            AnotherImage.decodeImage(tableHeaderAs8List);
        // divider
        Uint8List dividerAs8List = await createImageFromWidget(divider(),
            logicalSize: Size(500, 500), imageSize: Size(680, 680));
        final AnotherImage.Image dividerImage =
            AnotherImage.decodeImage(dividerAs8List);
        // table item row
        Uint8List tableItemRowAs8List = await createImageFromWidget(
            tableItemRow(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image tableItemRowImage =
            AnotherImage.decodeImage(tableItemRowAs8List);
        // table fotter
        Uint8List tableFotterRowAs8List = await createImageFromWidget(
            tableFotter(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image tableFotterImage =
            AnotherImage.decodeImage(tableFotterRowAs8List);
        // invoice ref & print time
        Uint8List invoiceRefAndPrintTimeAs8List = await createImageFromWidget(
            referenceNoAndPrintTime(),
            logicalSize: Size(500, 500),
            imageSize: Size(680, 680));
        final AnotherImage.Image invoiceRefAndPrintTimerImage =
            AnotherImage.decodeImage(invoiceRefAndPrintTimeAs8List);
        // printerService.image(logoImage);
        printerService.image(companyNameImage);
        printerService.image(tableHeaderImage);
        printerService.image(dividerImage);
        printerService.image(tableItemRowImage);
        printerService.image(tableItemRowImage);
        printerService.image(tableItemRowImage);
        printerService.image(dividerImage);
        printerService.image(tableFotterImage);
        printerService.emptyLines(3);
        printerService.image(invoiceRefAndPrintTimerImage);
        printerService.feed(1);
        printerService.cut();
        printerService.disconnect();
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }
}

Future<Uint8List> createImageFromWidget(Widget widget,
    {Duration wait, Size logicalSize, Size imageSize}) async {
  // Size logicalSize: const Size(1300, 1300),
  // Size imageSize: const Size(1800, 1800)}) async {
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
