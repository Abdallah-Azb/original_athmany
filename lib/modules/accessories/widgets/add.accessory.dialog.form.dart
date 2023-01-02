import 'package:app/core/enums/type_mobile.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/services/print-service/new_service_print/printer_service_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/const.dart';
import '../../../core/extensions/widget_extension.dart';

class AddAccessoryDialogForm extends StatelessWidget {
  const AddAccessoryDialogForm({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Header(),
        _FormFields(),
      ],
    );
  }
}

class _FormFields extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<AccessoryModel>(context);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;

    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DialogTextField(
                title: Localization.of(context).tr('device_name'),
                hintText: Localization.of(context).tr('device_name'),
                onChange: model.onName,
                validator: model.nameValidator,
                width: size.width / 2,
              ),
              DialogTextFieldWithDropDown(
                width: size.width / 2,
                title: Localization.of(context).tr('ip'),
                hintText: Localization.of(context).tr('ip'),
                // controller:controller ,
                onChange: model.onIP,
                validator: model.ipValidator,
              ),
            ],
          ),
          typeMobile == TYPEMOBILE.TABLET
              ? SizedBox(height: 16.0)
              : SizedBox(height: 2.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SelectDropdown<DeviceType>(
                width: size.width / 2,
                title: Localization.of(context).tr('device_type'),
                values: model.deviceTypes,
                defaultValue: model.device.deviceType,
                onTap: model.onDeviceType,
              ),
              _SelectDropdown<DeviceFor>(
                width: size.width / 2,
                title: Localization.of(context).tr('device_for'),
                values: DeviceFor.values,
                defaultValue: model.device.deviceFor,
                onTap: model.onDeviceFor,
              ),
            ],
          ),
          typeMobile == TYPEMOBILE.TABLET
              ? SizedBox(height: 16.0)
              : SizedBox(height: 2.0),
          Visibility(
            visible: model.device.connection != Connection.BUILTIN,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SelectDropdown<DeviceBrand>(
                  width: size.width / 2,
                  title: Localization.of(context).tr('brand'),
                  values: DeviceBrand.values.toList(),
                  defaultValue: model.device.deviceBrand,
                  onTap: model.onDeviceBrand,
                ),
                _SelectDropdown<Connection>(
                  width: size.width / 2,
                  title: Localization.of(context).tr('connection'),
                  values: model.connections,
                  defaultValue: model.device.connection,
                  onTap: model.onConnection,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

class _SelectDropdown<T> extends StatelessWidget {
  final List<T> values;
  final T defaultValue;
  final String title;
  final String hintText;
  final double width;
  final Function(T value) onTap;

  const _SelectDropdown({
    Key key,
    this.title,
    this.hintText,
    this.values,
    this.defaultValue,
    this.onTap,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            width: width / 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title ?? "",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: Colors.grey.shade700)),
                SizedBox(height: 16.0),
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.5,
                        color: isDarkMode ? Colors.white : Colors.grey.shade800,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: DropdownButton<T>(
                      value: defaultValue,
                      underline: SizedBox.shrink(),
                      isExpanded: true,
                      icon: Transform.rotate(
                        origin: Offset(0, 0),
                        angle: 4.7,
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: isDarkMode == false
                              ? Colors.black54
                              : Colors.white70,
                        ),
                      ),
                      onChanged: onTap,
                      items: values
                          .map(
                            (e) => DropdownMenuItem(
                              child: Text("${removeDot(e)}"),
                              value: e,
                            ),
                          )
                          .toList(),
                    ).paddingHorizontallyAndVertical(16, 8)),
              ],
            ),
          )
        // === Mobile ===
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? "",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: themeColor,
                      fontSize: 14,
                    ),
              ),
              SizedBox(height: 4.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: isDarkMode == false
                        ? Colors.grey.shade800
                        : Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: DropdownButton<T>(
                  value: defaultValue,
                  underline: SizedBox.shrink(),
                  isExpanded: true,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.black, fontSize: 14),
                  icon:
                      // Transform.rotate(
                      //   origin: Offset(0, 0),
                      //   angle: 4.7,
                      //   child:
                      Icon(
                    Icons.keyboard_arrow_down,
                    size: 26,
                    color:
                        isDarkMode == false ? Colors.black54 : Colors.white70,
                    // ),
                  ),
                  onChanged: onTap,
                  items: values
                      .map(
                        (e) => DropdownMenuItem(
                          child: Text(
                            "${removeDot(e)}",
                            style: TextStyle(
                              color: isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          value: e,
                        ),
                      )
                      .toList(),
                ).paddingHorizontally(16),
              ),
            ],
          );
  }
}

class DialogTextField extends StatelessWidget {
  final String initialValue;
  final String title;
  final String hintText;
  final double width;
  final Function(String value) onChange;
  final Function(String value) validator;
  final TextEditingController textEditingController;

  const DialogTextField({
    Key key,
    this.initialValue,
    @required this.title,
    this.textEditingController,
    this.hintText,
    this.onChange,
    this.validator,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    var size = MediaQuery.of(context).size;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            width: width / 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: themeColor,
                      ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  // TextField(
                  initialValue: initialValue,
                  validator: validator,
                  controller: textEditingController,
                  onChanged: onChange,
                  decoration: _inputDecoration.copyWith(
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: isDarkMode == false
                          ? Colors.grey.shade800
                          : Colors.white,
                    )),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: isDarkMode == false
                          ? Colors.grey.shade800
                          : Colors.white,
                    )),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.red,
                    )),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: isDarkMode == false ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        // === Mobile ===
        : Container(
            height: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: themeColor,
                        fontSize: 14,
                      ),
                ),
                SizedBox(height: 4.0),
                TextFormField(
                  // TextField(
                  initialValue: initialValue,
                  validator: validator,
                  onChanged: onChange,
                  decoration: _inputDecoration.copyWith(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: isDarkMode == false
                            ? Colors.grey.shade800
                            : Colors.white,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: isDarkMode == false
                            ? Colors.grey.shade800
                            : Colors.white,
                        width: 1,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: isDarkMode == false ? Colors.black : Colors.white,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  ),
                )
              ],
            ),
          );
  }
}

class DialogTextFieldWithDropDown extends StatefulWidget {
  final String initialValue;
  final String title;
  final String hintText;
  final double width;
  final Function(String value) onChange;
  final Function(String value) validator;
// final TextEditingController  controller;
  const DialogTextFieldWithDropDown({
    Key key,
    this.initialValue,
    @required this.title,
    this.hintText,
    this.onChange,
    this.validator,
    this.width,
    // this.controller
  }) : super(key: key);

  @override
  State<DialogTextFieldWithDropDown> createState() =>
      _DialogTextFieldWithDropDownState();
}

class _DialogTextFieldWithDropDownState
    extends State<DialogTextFieldWithDropDown> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<AccessoryModel>(context);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    List<String> devicesNetworkPrinter =
        Provider.of<PrinterServicesProvider>(context).devices;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            width: widget.width / 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? "",
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        color: themeColor,
                      ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  // TextField(
                  initialValue: widget.initialValue,
                  validator: widget.validator,
                  controller: controller,
                  onChanged: widget.onChange,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: isDarkMode == false ? Colors.black : Colors.white,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDarkMode == false
                            ? Colors.grey.shade800
                            : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDarkMode == false
                            ? Colors.grey.shade800
                            : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 17.5,
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        // Provider.of<PrinterServicesProvider>(context,listen: false).discover();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              elevation: 2,
                              child: Container(
                                height: 400,
                                width: 250,
                                color: isDarkMode == false
                                    ? Colors.white
                                    : darkContainerColor,
                                padding: EdgeInsets.only(top: 20),
                                child: Provider.of<PrinterServicesProvider>(
                                            context,
                                            listen: false)
                                        .devices
                                        .isNotEmpty
                                    ? ListView.separated(
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: 16.0),
                                        padding: EdgeInsets.only(bottom: 16.0),
                                        itemBuilder: (context, index) =>
                                            InkWell(
                                          onTap: () {
                                            Provider.of<PrinterServicesProvider>(
                                                    context,
                                                    listen: false)
                                                .setDeviceConnect(index);
                                            Navigator.pop(context);
                                            setState(() {
                                              controller.text = Provider.of<
                                                          PrinterServicesProvider>(
                                                      context,
                                                      listen: false)
                                                  .selectedPrinter
                                                  .toString();
                                              print("kjsfikfdlkasdpasjfi" +
                                                  controller.text);
                                            });
                                            model.device.ip = controller.text;
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDarkMode == false
                                                  ? Colors.white
                                                  : darkContainerColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: themeColor,
                                                width: Provider.of<PrinterServicesProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedPrinter ==
                                                        Provider.of<PrinterServicesProvider>(
                                                                context,
                                                                listen: false)
                                                            .devices[index]
                                                    ? 3
                                                    : 1,
                                              ),
                                            ),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            padding: EdgeInsets.only(left: 10),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.print,
                                                  color: isDarkMode == false
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '${Provider.of<PrinterServicesProvider>(context, listen: false).devices[index]}',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: isDarkMode ==
                                                                  false
                                                              ? Colors.black54
                                                              : Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Click to print a test receipt',
                                                        style: TextStyle(
                                                          color: isDarkMode ==
                                                                  false
                                                              ? Colors.grey[700]
                                                              : Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.chevron_right,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        itemCount: Provider.of<
                                                    PrinterServicesProvider>(
                                                context,
                                                listen: false)
                                            .devices
                                            .length,
                                      )
                                    : Center(
                                        child: Text(
                                            'There is no devices connected to the router')),
                              ),
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.search,
                        size: 26,
                        color: isDarkMode == false
                            ? Colors.black54
                            : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        // === Mobile ===
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title ?? "",
                style: Theme.of(context).textTheme.headline6.copyWith(
                      color: themeColor,
                      fontSize: 14,
                    ),
              ),
              SizedBox(height: 4.0),
              Container(
                height: MediaQuery.of(context).size.height / 16,
                child: TextFormField(
                  // child: TextField(
                  initialValue: widget.initialValue,
                  validator: widget.validator,
                  controller: controller,
                  onChanged: widget.onChange,

                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: isDarkMode == false ? Colors.black : Colors.white,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: isDarkMode == false
                            ? Colors.grey.shade800
                            : Colors.white,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: isDarkMode == false
                            ? Colors.grey.shade800
                            : Colors.white,
                        width: 1,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        // Provider.of<PrinterServicesProvider>(context,listen: false).discover();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              elevation: 2,
                              child: Container(
                                height: 400,
                                width: 250,
                                color: isDarkMode == false
                                    ? Colors.white
                                    : darkContainerColor,
                                padding: EdgeInsets.only(top: 20),
                                child: Provider.of<PrinterServicesProvider>(
                                            context,
                                            listen: false)
                                        .devices
                                        .isNotEmpty
                                    ? ListView.separated(
                                        separatorBuilder: (_, __) =>
                                            SizedBox(height: 16.0),
                                        padding: EdgeInsets.only(bottom: 16.0),
                                        itemBuilder: (context, index) =>
                                            InkWell(
                                          onTap: () {
                                            Provider.of<PrinterServicesProvider>(
                                                    context,
                                                    listen: false)
                                                .setDeviceConnect(index);
                                            Navigator.pop(context);
                                            setState(() {
                                              controller.text = Provider.of<
                                                          PrinterServicesProvider>(
                                                      context,
                                                      listen: false)
                                                  .selectedPrinter
                                                  .toString();

                                              print("kjsfikfdlkasdpasjfi" +
                                                  controller.text);
                                            });
                                            model.device.ip = controller.text;
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDarkMode == false
                                                  ? Colors.white
                                                  : darkContainerColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: themeColor,
                                                width: Provider.of<PrinterServicesProvider>(
                                                                context,
                                                                listen: false)
                                                            .selectedPrinter ==
                                                        Provider.of<PrinterServicesProvider>(
                                                                context,
                                                                listen: false)
                                                            .devices[index]
                                                    ? 3
                                                    : 1,
                                              ),
                                            ),
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 15),
                                            padding: EdgeInsets.only(left: 10),
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.print,
                                                  color: isDarkMode == false
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                                SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        '${Provider.of<PrinterServicesProvider>(context, listen: false).devices[index]}',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: isDarkMode ==
                                                                  false
                                                              ? Colors.black54
                                                              : Colors.white,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Click to print a test receipt',
                                                        style: TextStyle(
                                                          color: isDarkMode ==
                                                                  false
                                                              ? Colors.grey[700]
                                                              : Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.chevron_right,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        itemCount: Provider.of<
                                                    PrinterServicesProvider>(
                                                context,
                                                listen: false)
                                            .devices
                                            .length,
                                      )
                                    : Center(child: Text('No thing ')),
                              ),
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 26,
                        color: isDarkMode == false
                            ? Colors.black54
                            : Colors.white70,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            Localization.of(context).tr('new_device'),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(color: themeColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration = InputDecoration(
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(color: Colors.grey.shade800, width: 0.5),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(color: themeColor, width: 0.5),
  ),
  disabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(color: Colors.grey.shade800, width: 0.5),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0),
    borderSide: BorderSide(color: Colors.red.shade800, width: 0.5),
  ),
);

String removeDot(value) {
  value = value.toString();

  return value.substring(value.indexOf('.') + 1, value.length);
}
