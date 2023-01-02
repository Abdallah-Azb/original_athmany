import 'dart:developer';
import 'dart:io';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/item.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/modules/accessories/models/accessory.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/modules/closing/models.dart/paymentReconciliation.dart';
import 'package:app/modules/closing/models.dart/pos.transactions.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/services/print-service/bixolon_service.dart';
import 'package:app/services/print-service/closing.print.service.dart';
import 'package:app/services/print-service/epson.service.dart';
import 'package:app/services/print-service/rego_service.dart';
import 'package:app/services/print-service/sunmi.service.dart';
import 'package:device_info/device_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../kitchen_config.dart';
import '../../models/profile.details.dart';
import '../../modules/auth/models/user.dart';
import '../../modules/opening/models/opening.details.dart';
import '../db.service.dart';

class PrintService {
  // SunmiService _sunmiService = SunmiService();
  EpsonService _epsonService = EpsonService();
  BixolonService _bixolonService = BixolonService();
  RegoService _regoService = RegoService();
  ClosingService _closingService = ClosingService();

  Future getAllDevices() async {
    try {
      List<Accessory> devices = await DBAccessory().getAllAccessories();
      List<String> ips = devices
          .where((e) => e.deviceFor.index == 0)
          .map((e) => e.ip)
          .toSet()
          .toList();

      List<Accessory> cashierPrinters = [];
      List<Accessory> kitchenPrinters = [];

      for (int i = 0; i < ips.length; i++) {
        var result = devices.where((device) => device.ip == ips[i]).toList();
        result.sort(
            (a, b) => a.deviceFor.toString().compareTo(b.deviceFor.toString()));

        cashierPrinters.addAll(result);
      }

      kitchenPrinters = devices
          .where((element) => !cashierPrinters.contains(element))
          .toList();

      cashierPrinters.addAll(kitchenPrinters);

      print("123456789123456789123456789123456789123456789");
      return cashierPrinters;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  Future printStock(ClosingData closingData, ProfileDetails posProfileDetails,
      OpeningDetails openingDetails, User user) async {
    print("Stock service ");
    print("printStock func in print Services === ${closingData.stockItems}");
    try {
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;

        if (androidDeviceInfo.brand == "SUNMI") {
          // Todo # add new params to following function
          // _sunmiService.printSunmiClosing(
          //     closingData, posProfileDetails, openingDetails, user);
        }
      }
      List<Accessory> printers = await getAllDevices();
      print(printers.length);
      // for (var printer in printers) {
      //   print("H $printer");
      //   await printStockForm(
      //       printer, stockItem, posTransaction, grandTotal, netTotal, payments);
      // }
      printers.forEach((printer) async {
        print("H ${printer.deviceName}");
        await printStockForm(
            printer, closingData, posProfileDetails, openingDetails, user);
      });
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  printStockForm(
    Accessory printer,
    ClosingData closingData,
    ProfileDetails posProfileDetails,
    OpeningDetails openingDetails,
    User user,
  ) async {
    try {
      print("☎️☎️☎️☎️ printStockForm called ☎️☎️☎️☎️");
      print(printer.deviceName + printer.deviceFor.toString() + '  fffff');
      if (printer.deviceBrand == DeviceBrand.EPSON) {
        if (printer.deviceFor == DeviceFor.CASHIER) {
          print("CLOSING PRINT");
          await _closingService.printStock(
              printer, closingData, posProfileDetails, openingDetails, user,
              sizeWidth: 420);
        }
      }

      if (printer.deviceBrand == DeviceBrand.BIXOLON) {
        if (printer.deviceFor == DeviceFor.CASHIER) {
          print("CASHIER ${printer.deviceFor}");
          await _closingService.printStock(
              printer, closingData, posProfileDetails, openingDetails, user,
              sizeWidth: 370);
        }
      }

      if (printer.deviceBrand == DeviceBrand.REGO) {
        if (printer.deviceFor == DeviceFor.CASHIER) {
          print("CASHIER REGO  ${printer.deviceFor}");
          await _closingService.printStock(
              printer, closingData, posProfileDetails, openingDetails, user,
              sizeWidth: 420);
        }
      }

      if (printer.deviceBrand == DeviceBrand.SUNMI) {
        if (printer.deviceFor == DeviceFor.CASHIER) {
          // _closingService.printSunmiClosing(
          //     closingData, posProfileDetails, openingDetails, user);
        }
      }

      // dropAccessoriesTables
      await DBService().dropAccessoriesTables(db);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  Future printInvoice(int invoiceId, {bool kitchen: true}) async {
    print("Cashier service ");
    try {
      Invoice invoice =
          await DBInvoiceRefactor().getCompleteInvoice(id: invoiceId);
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;

        if (androidDeviceInfo.brand == "SUNMI") {
          // await _sunmiService.printSunmiCashier(invoice);
        }
      }
      List<Accessory> printers = await getAllDevices();
      print(printers.length);
      for (var printer in printers) {
        print("printers :::::::::::::::: ${printer.ip}");
        await printForm(printer, invoice, kitchen: kitchen);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  // print invoice
  Future sendDataToKitchenService(
      Invoice invoice, List<Map<String, dynamic>> data,
      {bool kitchen}) async {
    log("Kitchen Monitor service === ${data}");
    try {
      // if (Platform.isAndroid) {
      //   DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      //   AndroidDeviceInfo androidDeviceInfo =
      //       await deviceInfoPlugin.androidInfo;
      //
      //   if (androidDeviceInfo.brand == "SUNMI") {
      //     await _sunmiService.printSunmiCashier(invoice,'bandar1');
      //   }
      // }
      List<Accessory> printers = await getAllDevices();
      print(printers.length);

      printers.forEach((printer) {
        if (printer.deviceFor == DeviceFor.KITCHEN &&
            printer.deviceType == DeviceType.MONITOR) {
          print('🤖🤖🤖🤖🤖🤖kitchen ip = ${printer.ip} 🤖🤖🤖🤖🤖🤖');
          log("🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖🤖 kitchen1 🤖🤖🤖🤖🤖🤖🤖🤖🤖");
          print("========== ${invoice.status}");
          kitchenConfig(ip: printer.ip, data: {
            "customer": "${invoice.customer ?? 'Customer'}",
            "table_number": "${invoice.tableNo.toString() ?? '0'}",
            "pos_opening": "POS-OPE-2021-00608",
            "casher": "${invoice.name ?? "Casher"}",
            "order_status": invoice.docStatus.toString(),
            "status": invoice.status,
            "time": DateTime.now().toString(),
            "order_number": invoice.id.toString(),
            "items": data
          }).then((_value) {});
        }
      });
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  Future printInvoiceKitchen(int invoiceId, {bool kitchen: true}) async {
    print("GGGGG");
    try {
      Invoice invoice =
          await DBInvoiceRefactor().getCompleteInvoice(id: invoiceId);
      if (Platform.isAndroid) {
        DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        AndroidDeviceInfo androidDeviceInfo =
            await deviceInfoPlugin.androidInfo;

        if (androidDeviceInfo.brand == "SUNMI") {
          // await _sunmiService.printSunmiCashier(invoice);
        }
      }

      List<Accessory> printers = await getAllDevices();
      for (var printer in printers)
        if (printer.deviceFor == DeviceFor.KITCHEN)
          await printForm(printer, invoice, kitchen: kitchen);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
    }
  }

  printForm(Accessory printer, Invoice invoice, {bool kitchen: true}) async {
    try {
      print(printer.deviceName + printer.deviceFor.toString() + '  fffff');
      if (printer.deviceBrand == DeviceBrand.EPSON) {
        if (printer.deviceFor == DeviceFor.CASHIER) {
          print("CASHIER");
          await _epsonService.printEpsonCashier(printer, invoice);
        } else {
          print("Kit");
          if (kitchen) {
            print("Kitchen");
            await _epsonService.printEpsonKitchen(printer, invoice);
          }
        }
      }

      if (printer.deviceBrand == DeviceBrand.BIXOLON) {
        if (printer.deviceFor == DeviceFor.CASHIER) {
          print("CASHIER ${printer.deviceFor}");
          await _bixolonService.printBixolonCashier(printer, invoice);
        } else {
          print("Kit");
          if (kitchen) {
            print("Kitchen");
            await _bixolonService.printBixolonKitchen(printer, invoice);
          }
        }
      }

      if (printer.deviceBrand == DeviceBrand.REGO) {
        if (printer.deviceFor == DeviceFor.CASHIER) {
          print("CASHIER REGO  ${printer.deviceFor}");
          await _regoService.printRegoCashier(printer, invoice);
        } else {
          print("Kit");
          if (kitchen) {
            print("REGO Kitchen");
            await _regoService.printRegoKitchen(printer, invoice);
          }
        }
      }

      if (printer.deviceBrand == DeviceBrand.SUNMI) {
        if (printer.deviceFor == DeviceFor.CASHIER) {
          // _sunmiService.printSunmiCashier(invoice);
        } else {
          if (kitchen) {
            // await _sunmiService.printSunmiKitchen(printer, invoice);
          }
        }
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
