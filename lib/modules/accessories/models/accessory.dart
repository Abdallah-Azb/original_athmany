import 'package:app/models/items.group.dart';

class Accessory {
  int id;
  String name;
  String serial;
  String deviceName;
  String ip;
  DeviceType deviceType;
  Connection connection;
  DeviceFor deviceFor;
  DeviceBrand deviceBrand;
  int isSynced;
  int deleted;
  List<ItemsGroups> itemsGroups;

  Accessory({
    this.id,
    this.name,
    this.serial,
    this.deviceName,
    this.ip,
    this.connection,
    this.deviceType,
    this.deviceFor,
    this.deviceBrand,
    this.isSynced,
    this.deleted,
  });

  factory Accessory.empty() => Accessory(
        deviceFor: DeviceFor.CASHIER,
        connection: Connection.NETWORK,
        deviceType: DeviceType.PRINTER,
        deviceBrand: DeviceBrand.EPSON,
      );

  // map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'name': this.name,
      'serial': this.serial,
      'device_name': this.deviceName,
      'ip': this.ip ?? "0.0.0.0",
      'device_type': this.deviceType.index,
      'connection': this.connection.index,
      'device_for': this.deviceFor.index,
      'device_brand': this.deviceBrand.index,
      'is_synced': this.isSynced ?? 0,
      'deleted': 0
    };
    return map;
  }

  // get device from sqlite
  Accessory.fromSqlite(Map<String, dynamic> json) {
    this.id = json['id'];
    this.name = json['name'];
    this.serial = json['serial'];
    this.deviceName = json['device_name'].toString();
    this.ip = json['ip'].toString();
    this.connection = Connection.values[json['connection']];
    this.deviceType = DeviceType.values[json['device_type']];
    this.deviceFor = DeviceFor.values[json['device_for']];
    this.deviceBrand = DeviceBrand.values[json['device_brand']];
    this.isSynced = json['is_synced'];
    this.deleted = json['deleted'];
  }

  factory Accessory.fromJson(Map<String, dynamic> json) {
    Accessory accessory = Accessory();

    accessory.name = json['name'];
    accessory.serial = json['device'];
    accessory.deviceName = json['device_name'];
    accessory.ip = json['ip'];
    accessory.deviceType = DeviceType.values.firstWhere((deviceType) =>
        DeviceType.values[deviceType.index].toString().split('.').last ==
        json['device_type']);
    accessory.connection = Connection.values.firstWhere((connection) =>
        Connection.values[connection.index].toString().split('.').last ==
        json['connection']);
    accessory.deviceFor = DeviceFor.values.firstWhere((deviceFor) =>
        DeviceFor.values[deviceFor.index].toString().split('.').last ==
        json['device_for']);
    accessory.deviceBrand = DeviceBrand.values.firstWhere((deviceBrand) =>
        DeviceBrand.values[deviceBrand.index].toString().split('.').last ==
        json['device_brand']);
    accessory.isSynced = 1;
    accessory.itemsGroups = (json['item_groups'] as List)
        .map((e) => ItemsGroups.fromSqlite(e))
        .toList();

    return accessory;
  }

  Accessory copyWith(
      {String serial,
      String deviceName,
      String ip,
      Connection connection,
      DeviceFor deviceFor,
      DeviceType deviceType,
      DeviceBrand deviceBrand,
      int isSynced,
      int deleted}) {
    return Accessory(
      serial: serial ?? this.deviceName,
      deviceName: deviceName ?? this.deviceName,
      ip: ip ?? this.ip,
      connection: connection ?? this.connection,
      deviceFor: deviceFor ?? this.deviceFor,
      deviceType: deviceType ?? this.deviceType,
      deviceBrand: deviceBrand ?? this.deviceBrand,
      isSynced: isSynced ?? this.isSynced,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Accessory &&
        other.id == id &&
        other.deviceName == deviceName &&
        other.ip == ip &&
        other.connection == connection;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        deviceName.hashCode ^
        ip.hashCode ^
        connection.hashCode;
  }
}

enum DeviceType { PRINTER, MONITOR }
enum Connection { NETWORK, BUILTIN }
enum DeviceFor { CASHIER, KITCHEN }
enum DeviceBrand { EPSON, SUNMI, BIXOLON, REGO }
