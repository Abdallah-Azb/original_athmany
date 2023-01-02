import 'dart:async';
import 'dart:io';

import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/services/services.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AccessoryService {
  // get device details
  Future<DeviceDetails> getDeviceDetails() async {
    DeviceDetails deviceDetails;
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;

        deviceDetails =
            DeviceDetails(identifier: build.androidId, brand: build.brand);
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;

        deviceDetails =
            DeviceDetails(identifier: data.identifierForVendor, brand: 'Apple');
      }
    } on PlatformException {
      throw Exception('Device info not found');
    }
    return deviceDetails;
  }

  // add new device accessory
  Future<String> addNewDeviceAccessory(
    Accessory accessory,
  ) async {
    String accessoryName;
    DeviceDetails deviceDetails = await getDeviceDetails(); // device => tablet
    final request = {
      "device": deviceDetails.identifier,
      "device_name": accessory.deviceName,
      "ip": accessory.ip == null ? '0.0.0.0' : accessory.ip,
      "device_type": DeviceType.values[accessory.deviceType.index]
          .toString()
          .split('.')
          .last,
      "connection": Connection.values[accessory.connection.index]
          .toString()
          .split('.')
          .last,
      "device_for": DeviceFor.values[accessory.deviceFor.index]
          .toString()
          .split('.')
          .last,
      "device_brand": DeviceBrand.values[accessory.deviceBrand.index]
          .toString()
          .split('.')
          .last,
      "item_groups": []
    };

    var response = await ApiService()
        .dio
        .post('/api/resource/POS Devices Accessories', data: request);
    if (response.statusCode == 200) {
      if (response.data['data']['name'] != null) {
        await DBAccessory().updateDeviceNameFromServer(
          accessory.id,
          response.data['data']['name'],
        );
        await DBAccessory().isSynced(accessory.id, 1);
        accessoryName = response.data['data']['name'];
        return accessoryName;
      }
    }

    return accessoryName;
  }

  // udpate Device Accessory
  Future<void> udpateDeviceAccessory(Accessory accessory) async {
    DeviceDetails deviceDetails = await getDeviceDetails(); // device => tablet
    List<CategoriesAccessories> categories =
        await DBCategoriesAccessories.getCategoriesOfAccessory(accessory.id);

    List<String> categoriesNames =
        categories.map((e) => e.categoryTitle.toString()).toList();

    final request = {
      "device": deviceDetails.identifier,
      "device_name": accessory.deviceName,
      "ip": accessory.ip == null ? '0.0.0.0' : accessory.ip,
      "device_type": DeviceType.values[accessory.deviceType.index]
          .toString()
          .split('.')
          .last,
      "connection": Connection.values[accessory.connection.index]
          .toString()
          .split('.')
          .last,
      "device_for": DeviceFor.values[accessory.deviceFor.index]
          .toString()
          .split('.')
          .last,
      "device_brand": DeviceBrand.values[accessory.deviceBrand.index]
          .toString()
          .split('.')
          .last,
      "item_groups":
          categoriesNames.map((e) => {"item_group": e}).toList() ?? []
    };
    print(request);
    try {
      var response = await ApiService().dio.put(
          '/api/resource/POS Devices Accessories/${accessory.name}',
          data: request);
      if (response.statusCode == 200) {
        await DBAccessory().isSynced(accessory.id, 1);
        // if (response.data['data']['name'] != null) {
        //   // await DBDevice.updateDeviceNameFromServer(
        //   //     device.id, response.data['data']['name']);
        //   await DBDevice.isSynced(device.id, 1);
        // }
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('error');
      print(e);
    }
  }

  // categories devices
  Future<void> categoresDevicesUpdate(Accessory accessory) async {
    DeviceDetails deviceDetails = await getDeviceDetails(); // device => tablet
    final request = {
      "device": deviceDetails.identifier,
      "device_name": accessory.deviceName,
      "ip": accessory.ip == null ? '0.0.0.0' : accessory.ip,
      "device_type": DeviceType.values[accessory.deviceType.index]
          .toString()
          .split('.')
          .last,
      "connection": Connection.values[accessory.connection.index]
          .toString()
          .split('.')
          .last,
      "device_for": DeviceFor.values[accessory.deviceFor.index]
          .toString()
          .split('.')
          .last,
      "device_brand": DeviceBrand.values[accessory.deviceBrand.index]
          .toString()
          .split('.')
          .last,
      "item_groups": []
    };
    try {
      await ApiService()
          .dio
          .put('/api/resource/POS Devices Accessories', data: request);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('error');
      print(e);
    }
  }

  // delete device accessory from server
  // Future<dynamic> deleteDeviceAccessoryFromServer(int id) async {
  //   Accessory device = await DBAccessory().getDevice(id);
  //   dynamic data;

  // var response = await ApiService()
  //     .dio
  //     .delete('/api/resource/POS Devices Accessories/${device.name}');
  //   if (response.statusCode == 202) {
  //     data = response.data['data'];
  //   }

  //   return data;
  // }

  Future<Response> deleteAccessoryFromServer(Accessory accessory) async {
    print("accessory :::::::: ${accessory.name}");
    String api = "/api/resource/POS Devices Accessories/${accessory.name}";
    try {
      return ApiService().dio.delete(api);
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      throw Failure("unexpected_error");
    }
  }

  //
  Future<List<Accessory>> getOrSendDeviceAccessories() async {
    List<Accessory> accessories = [];
    DeviceDetails deviceDetails = await getDeviceDetails(); // device => tablet

    if (await checkIfDeviceSerialExist(deviceDetails.identifier)) {
      accessories = await fetchDeviceAccessories(deviceDetails.identifier);
    } else {
      await sendDeviceIdentifierToServer(
          deviceDetails.identifier, deviceDetails.brand);
    }

    return accessories;
  }

  // check if device serial is exist
  Future<bool> checkIfDeviceSerialExist(String identifier) async {
    bool serialExist;
    final request = {"serial": identifier};
    try {
      var response = await ApiService().dio.post(
          '/api/method/business_layer.pos_business_layer.doctype.pos_devices.pos_devices.device_is_exist',
          data: request);
      if (response.statusCode == 200) {
        serialExist = response.data['message'];
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('error');
      print(e);
    }
    return serialExist;
  }

  // get device accessories from server
  Future<List<Accessory>> fetchDeviceAccessories(String identifier) async {
    List<Accessory> accessories = [];
    final request = {"serial": identifier};
    print(identifier);
    var response = await ApiService().dio.post(
        '/api/method/business_layer.pos_business_layer.doctype.pos_devices.pos_devices.get_devices_accessories',
        data: request);

    if (response.statusCode == 200) {
      var result = response.data['message'];
      if (result.length > 0) {
        accessories =
            (result as List).map((e) => Accessory.fromJson(e)).toList();
      }
    }
    print("accessories : $accessories");
    return accessories;
  }

  // send device identifier to server
  Future<void> sendDeviceIdentifierToServer(
      String identifier, String brand) async {
    final request = {"serial": identifier, "brand": brand};
    try {
      await ApiService().dio.post('/api/resource/POS Devices', data: request);
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print('error');
      print(e);
    }
  }

  Future syncAccessories() async {
    List<Accessory> accessories = await DBAccessory().getAllAccessories();
    for (int x = 0; accessories.length > x; x++) {
      if (accessories[x].isSynced == 0 &&
          accessories[x].deleted == 0 &&
          accessories[x].name == null) {
        await addNewDeviceAccessory(accessories[x]);
        await DBAccessory().isSynced(accessories[x].id, 1);
      }
      if (accessories[x].isSynced == 0 && accessories[x].deleted == 1) {
        // await deleteDeviceAccessoryFromServer(accessories[x].id);
        await DBAccessory().isSynced(accessories[x].id, 1);
      }
    }
  }
}
