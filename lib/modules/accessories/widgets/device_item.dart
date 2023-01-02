import 'package:app/core/utils/utils.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'add.accessory.dialog.form.dart';
import '../../../core/extensions/widget_extension.dart';
class DeviceItem extends StatelessWidget {
  final Accessory accessory;
  final VoidCallback onDelete;

  const DeviceItem({Key key, @required this.accessory, this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? darkContainerColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                accessory.name ?? "",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        accessory.isSynced == 0 ? darkGreyColor : themeColor),
              ),
              Row(
                children: [
                  Text(accessory.deviceName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color:
                            isDarkMode ? Colors.white70 : Colors.grey.shade700,
                      )),
                  Text(" - ${removeDot(accessory.deviceFor)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.grey,
                      )),
                  Text(" - ${removeDot(accessory.deviceBrand)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.grey,
                      )),
                  Text(" - ${removeDot(accessory.connection)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.grey,
                      )),
                ],
              ),
              Text(
                accessory.ip ?? "0.0.0.0",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => EditAccessoryDialog(device: accessory),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.edit,
                      color: isDarkMode ? Colors.white : Colors.black,
                      size: 30,
                    ),
                  ),
                  radius: 17,
                ),
              ),
              SizedBox(width: 8.0),
              //todo ==========================================
              InkWell(
                onTap: this.onDelete,
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Center(
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                  radius: 17,
                ),
              ),
            ],
          )
        ],
      ).paddingHorizontallyAndVertical(16, 8),
    );
  }
}
