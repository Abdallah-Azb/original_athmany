import 'package:app/core/utils/const.dart';
import 'package:app/core/utils/toas.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:wifi/wifi.dart';

class PrinterServicesProvider extends ChangeNotifier {
  String localIp = '';
  List<String> devices = [];
  bool isDiscovering = false;
  int found = -1;

  // ==== Search for Printers ======
  discover({String portController = '9100'}) async {
    isDiscovering = true;
    devices.clear();
    found = -1;
    selectedPrinter = '';
    successConnect = false;
    String ip;
    try {
      ip = await Wifi.ip;
      print(':::::: local ip ::::::\t$ip');
    } catch (e) {
      print(" ::::: Catch error When get WIFI IF ::::::\t" + e.toString());
    }
    localIp = ip;

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    int port = 9100;
    try {
      port = int.parse(portController);
    } catch (e) {
      portController = port.toString();
    }
    print('subnet:\t$subnet, port:\t$port');

    final stream = NetworkAnalyzer.discover2(subnet, port);

    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        print('Found device: ${addr.ip}');
        devices.add(addr.ip);
        found = devices.length;
        notifyListeners();
      }
    })
      ..onDone(() {
        isDiscovering = false;
        found = devices.length;
        notifyListeners();
      })
      ..onError((dynamic e) {
        print(" ::::: Catch error When listing to Network Printers ::::::\t" +
            e.toString());
      });
    notifyListeners();
  }

  // ==== Set Printer Device ====

  var selectedPrinter;
  bool successConnect = false;
  NetworkPrinter printer;
  setDeviceConnect(int index, {port = 9100}) async {
    selectedPrinter = devices[index];

    // === connect to Printer =====
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    try {
      printer = NetworkPrinter(paper, profile);
      final PosPrintResult res =
          await printer.connect(selectedPrinter, port: port ?? 9100);
      if (res == PosPrintResult.success) {
        // Fluttertoast.showToast(msg: "Success To Connect Device $selectedPrinter");
        successConnect = true;
        notifyListeners();
      } else if (res == PosPrintResult.printerNotSelected) {
        // Fluttertoast.showToast(msg: "printer Not Selected $selectedPrinter");
      } else if (res == PosPrintResult.printInProgress) {
        // Fluttertoast.showToast(msg: "print In Progress $selectedPrinter");
      } else {
        // Fluttertoast.showToast(msg: "failed TO Connect $selectedPrinter");
      }
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future<void> testReceipt(NetworkPrinter printer) async {
    printer.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: PosStyles(codeTable: 'CP1252'));
    printer.text('Special 2: blåbærgrød',
        styles: PosStyles(codeTable: 'CP1252'));

    printer.text('Bold text', styles: PosStyles(bold: true));
    printer.text('Reverse text', styles: PosStyles(reverse: true));
    printer.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    printer.text('Align left', styles: PosStyles(align: PosAlign.left));
    printer.text('Align center', styles: PosStyles(align: PosAlign.center));
    printer.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    printer.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    printer.text('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    printer.feed(2);
    printer.cut();
  }

  printText() {
    if (successConnect == true && selectedPrinter != '' && printer != null) {
      testReceipt(printer);
      print("Success");
      toast("Success To Printer", themeColor);
    } else {
      print("can't print ");
      toast("No Device Saved", themeColor);
    }
  }
}
