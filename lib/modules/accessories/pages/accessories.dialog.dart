import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccessoryDialog extends StatefulWidget {
  @override
  _AccessoryDialogState createState() => _AccessoryDialogState();
}

class _AccessoryDialogState extends State<AccessoryDialog> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AccessoryModel>(
      create: (_) => AccessoryModel(),
      child: _Dialog(),
    );
  }
}

class _Dialog extends StatefulWidget {
  const _Dialog({
    Key key,
  }) : super(key: key);

  @override
  __DialogState createState() => __DialogState();
}

class __DialogState extends State<_Dialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<AccessoryModel>().getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Dialog(
      backgroundColor: isDarkMode == false ? Colors.white : appBarColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      child: SizedBox(
        width: typeMobile == TYPEMOBILE.TABLET
            ? MediaQuery.of(context).size.width * 0.7
            : MediaQuery.of(context).size.width,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogHeader(title: Localization.of(context).tr('devices')),
              Subtitle(),
              DeviceList(),
            ],
          ),
        ),
      ),
    );
  }
}
