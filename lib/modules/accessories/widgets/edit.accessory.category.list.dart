import 'package:app/core/utils/const.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../accessories.dart';
import '../../../core/extensions/widget_extension.dart';
class EditCategoriesList extends StatefulWidget {
  final List<CategoriesAccessories> categoriesDevices;
  final String deviceId;
  final Function(bool value, CategoriesAccessories categoriesDevices) onSwitch;

  const EditCategoriesList({
    Key key,
    this.deviceId,
    @required this.categoriesDevices,
    this.onSwitch,
  }) : super(key: key);

  @override
  _EditCategoriesListState createState() => _EditCategoriesListState();
}

class _EditCategoriesListState extends State<EditCategoriesList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.categoriesDevices
          .map(
            (category) => EditDeviceListItem(
              title: category.categoryTitle,
              onSwitch: (bool value) {
                widget.onSwitch(value, category);
              },
              isActive: category.isActive,
            ),
          )
          .toList(),
    );
  }
}

class EditDeviceListItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final Function(bool value) onSwitch;

  const EditDeviceListItem({
    Key key,
    this.onSwitch,
    this.title,
    @required this.isActive,
  }) : super(key: key);

  @override
  _EditDeviceListItemState createState() => _EditDeviceListItemState();
}

class _EditDeviceListItemState extends State<EditDeviceListItem> {
  bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive;
  }

  void changeSwitch(bool value) {
    setState(() {
      _isActive = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    return Container(
      decoration: BoxDecoration(
          color: isDarkMode ? darkContainerColor : Colors.white,
          border: Border.all(
              color: isDarkMode ? Colors.white70 : darkContainerColor),
          borderRadius: BorderRadius.circular(5)),
      margin: EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title ?? "",
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.grey.shade700)),
          CupertinoSwitch(
            value: _isActive,
            onChanged: (bool value) {
              changeSwitch(value);
              if (widget.onSwitch != null) widget.onSwitch(value);
            },
          )
        ],
      ).paddingAll(16)
    );
  }
}
