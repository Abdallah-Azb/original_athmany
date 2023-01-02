import 'package:app/core/utils/const.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/extensions/widget_extension.dart';
class EditAccessoryDialog extends StatefulWidget {
  final Accessory device;

  const EditAccessoryDialog({Key key, @required this.device}) : super(key: key);

  @override
  _EditAccessoryDialogState createState() => _EditAccessoryDialogState();
}

class _EditAccessoryDialogState extends State<EditAccessoryDialog> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AccessoryModel>(
          create: (_) => AccessoryModel(),
        ),
        ChangeNotifierProvider<EditAccessoryProvider>(
          create: (_) => EditAccessoryProvider(),
        )
      ],
      child: _Dialog(device: widget.device),
    );
  }
}

class _Dialog extends StatefulWidget {
  final Accessory device;

  const _Dialog({
    Key key,
    @required this.device,
  }) : super(key: key);

  @override
  __DialogState createState() => __DialogState();
}

class __DialogState extends State<_Dialog> {
  List<ItemsGroups> itemCategories = [];

  @override
  void initState() {
    super.initState();
    context.read<EditAccessoryProvider>().getCategories(widget.device.id);
    context.read<EditAccessoryProvider>()
      ..accessory = widget.device
      ..accessoryName = widget.device.deviceName
      ..accessoryIp = widget.device.ip;
  }

  @override
  Widget build(BuildContext context) {
    EditAccessoryProvider model = Provider.of<EditAccessoryProvider>(context);
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    var size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: isDarkMode ? darkBackGroundColor : Color(0xffF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: LayoutBuilder(
            builder: (context, constraint) => SingleChildScrollView(
              primary: true,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DialogHeader(
                          title: widget.device.deviceName ?? "Printer Name",
                          subtitle:
                              " - ${removeDot(widget.device.deviceFor)} - ${removeDot(widget.device.deviceBrand)} - ${removeDot(widget.device.connection)}",
                          isTrailing: false),
                      DialogTextField(
                        title: "Device Name",
                        width: size.width/2,
                        initialValue: model.accessoryName ?? "",
                        onChange: model.onAccessoryName,
                      ).paddingAll(16),
                      Visibility(
                        visible: widget.device.connection != Connection.BUILTIN,
                        child: DialogTextField(
                          title: "Device ip",
                          width: size.width/2,
                          initialValue: model.accessoryIp ?? "",
                          onChange: model.onAccessoryIp,
                        ).paddingAll(16),
                      ),
                      Expanded(
                        child: Visibility(
                          visible: widget.device.deviceFor != DeviceFor.CASHIER,
                          child: EditCategoriesList(
                            deviceId: widget.device.id.toString(),
                            categoriesDevices: model.categoriesAccessories,
                            onSwitch: model.onSwitch,
                          ),
                        ),
                      ),
                      AddAccessoryDialogSubmitBtn(
                        submissionInProgress: model.isSave,
                        onSave: model.isFormValid()
                            ? () async {
                                await model.onSaveCategories(context);
                                await model.onSaveAccessory();
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
