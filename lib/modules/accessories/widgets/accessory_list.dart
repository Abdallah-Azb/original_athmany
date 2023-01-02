import 'package:app/core/utils/utils.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/modules/accessories/widgets/device_item.dart';
import 'package:app/services/accessory.service.dart';
import 'package:app/services/auth.service.dart';
import 'package:app/services/print-service/new_service_print/printer_service_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../widget/widget/empty_list_widget.dart';
import 'add.accessory.dialog.form.dart';

class DeviceList extends StatefulWidget {
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  @override
  Widget build(BuildContext context) {
    List<Accessory> devices = context.watch<AccessoryModel>().devices;
    AccessoryModel accessoryProvider = Provider.of<AccessoryModel>(context);
    // is it nessecory ? maybe i can delete it without effect the app
    List<String> devicesNetworkPrinter =
        context.watch<PrinterServicesProvider>().devices;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    return Expanded(
      child: devices.isNotEmpty
          ? Container(
              color: isDarkMode == false ? Colors.black12 : appBarColor,
              child: ListView.separated(
                separatorBuilder: (_, __) => SizedBox(height: 16.0),
                padding: EdgeInsets.only(bottom: 16.0),
                itemBuilder: (context, index) => DeviceItem(
                  accessory: devices[index],
                  onDelete: () => removeItem(devices[index]),
                ),
                itemCount: devices.length,
              ))
          : EmptyList(),
    );
  }

  void removeItem(Accessory accessory) async {
    AccessoryModel accessoryProvider =
        Provider.of<AccessoryModel>(context, listen: false);
    try {
      print('try');
      accessoryProvider.deleteAccessory(accessory);
    } on Failure catch (e) {
      toast(e.toString(), Colors.red);
    }
  }
}
