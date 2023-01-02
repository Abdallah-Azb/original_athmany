import 'dart:async';
import 'dart:io';

import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/invoice/provider/invoice.provider.dart';
import 'package:app/services/accessory.service.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import '../accessories.dart';

class AccessoryModel extends ChangeNotifier {
  List<Accessory> devices = [];
  List<String> supportedDeviceSerials = ["T2mini_s", "T2", "D2mini"];
  List<Connection> connections = Connection.values;
  List<DeviceType> deviceTypes = DeviceType.values;
  bool isBuiltInPrinter = false;
  final formState = GlobalKey<FormState>();
  InvoiceProvider invoiceProvider;
  DeviceInfoPlugin deviceInfoPlugin;
  Accessory device;
  // undo commit 5c5196d
  // bool ipAlreadyExist = false;
  bool submissionInProgress = false;
  AccessoryService _deviceService = AccessoryService();

  AccessoryModel() {
    deviceInfoPlugin = DeviceInfoPlugin();
    isBuiltInPrinterSupported();
    device = Accessory.empty();
  }

  Future getCategories() async {
    List<Accessory> data = await DBAccessory().getAllAccessories();

    if (data == null) devices = [];

    devices = data;
    notifyListeners();
  }

  // undo commit 5c5196d
  // checkIfDeviceAlreadyExist(String deviceIP,BuildContext context){
  //   print("Device ip is : $deviceIP");
  //   for(Accessory accessory in devices) {
  //     if(accessory.ip == deviceIP ) {
  //       ipAlreadyExist = true;
  //       break;
  //   }}
  // }

  // void changeIpAlreadyExistStatus() {
  //   ipAlreadyExist = !ipAlreadyExist;
  //   notifyListeners();
  // }

  Future addAccessory(BuildContext context) async {
    print(context);
    int id;
    String name;
    print("==== device catogery :: ${device.name}");
    try {
      if (formState.currentState.validate()) {
        changeStatus();
        id = await DBAccessory().add(device);
        if (device.deviceType == DeviceType.PRINTER)
          await toast(Localization.of(context).tr('printer_added'), blueColor);
        if (device.deviceType == DeviceType.MONITOR)
          await toast(Localization.of(context).tr('monitor_added'), blueColor);
        name = await _deviceService.addNewDeviceAccessory(device..id = id);
        await Future.delayed(Duration(milliseconds: 500), () {
          toast(Localization.of(context).tr('data_synced_with_server'),
              themeColor);
        });
        devices.add(
          device
            ..id = id
            ..name = name,
        );
        notifyListeners();
        changeStatus();
        devices;
        Navigator.pop(context);
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException || e.error is TimeoutException) {
        await Future.delayed(const Duration(seconds: 2), () {});
        await toast(
            Localization.of(context).tr('check_your_internet_connection'),
            orangeColor);
        devices.add(
          device
            ..id = id
            ..name = name,
        );
        changeStatus();
        Navigator.pop(context);
      } else {
        await toast('DIO ERROR', orangeColor);
        changeStatus();
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
      changeStatus();
      Navigator.pop(context);
    }
  }

  Future deleteAccessory(Accessory accessory) async {
    await DBAccessory().deleteDeviceAndRelatedCategories(accessory.id);
    devices = devices.where((device) => device.id != accessory.id).toList();
    print('${devices.length}');
    await toast('Deleted', blueColor);
    await DBAccessory().isSynced(accessory.id, 0);
    notifyListeners();
    await _deviceService.deleteAccessoryFromServer(accessory);
    await toast('Accessory synced with server', themeColor);
  }

  void changeStatus() {
    submissionInProgress = !submissionInProgress;
    notifyListeners();
  }

  void onName(String deviceName) {
    device = device.copyWith(deviceName: deviceName);
    notifyListeners();
  }

  void onIP(String ip) {
    device = device.copyWith(ip: ip);
    notifyListeners();
  }

  void onDeviceType(DeviceType deviceType) {
    device = device.copyWith(deviceType: deviceType);

    notifyListeners();
  }

  void onConnection(Connection connection) {
    device = device.copyWith(connection: connection);

    if (connection == Connection.BUILTIN) {
      device = device.copyWith(deviceBrand: DeviceBrand.SUNMI);
      deviceTypes = justPrinter();
    } else {
      deviceTypes = DeviceType.values;
    }

    notifyListeners();
  }

  void onDeviceFor(DeviceFor deviceFor) {
    device = device.copyWith(deviceFor: deviceFor);
    notifyListeners();
  }

  void onDeviceBrand(DeviceBrand deviceBrand) {
    device = device.copyWith(deviceBrand: deviceBrand);
    notifyListeners();
  }

  Future isBuiltInPrinterSupported() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidDeviceInfo = await getInfoForAndroid();
      bool isSupported =
          supportedDeviceSerials.contains(androidDeviceInfo.model);

      isBuiltInPrinter = isSupported;
    }

    if (!isBuiltInPrinter) {
      connections = connections
          .where((element) => element != Connection.BUILTIN)
          .toList();
    }

    notifyListeners();
  }

  Future<AndroidDeviceInfo> getInfoForAndroid() async =>
      await deviceInfoPlugin.androidInfo;

  List<DeviceType> justPrinter() => deviceTypes =
      deviceTypes.where((element) => element == DeviceType.PRINTER).toList();

  bool isValid() => device.deviceName != null && device.deviceName.isNotEmpty;

  String nameValidator(String value) {
    if (value != null && value.isNotEmpty) {
      return null;
    }

    return "*Required";
  }

  String ipValidator(String value) {
    if (device.connection != Connection.BUILTIN &&
        value != null &&
        value.isNotEmpty) {
      return null;
    }
    return "*Required";
  }
}
