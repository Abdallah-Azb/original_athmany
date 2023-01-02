import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/core/utils/toas.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/services/print-service/new_service_print/printer_service_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';

import '../../../localization/localization.dart';
import '../accessories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewAccessoryDialog extends StatefulWidget {
  @override
  _NewAccessoryDialogState createState() => _NewAccessoryDialogState();
}

class _NewAccessoryDialogState extends State<NewAccessoryDialog> {
  @override
  Widget build(BuildContext context) {
    var model = Provider.of<AccessoryModel>(context);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return typeMobile == TYPEMOBILE.TABLET
        ? Dialog(
            backgroundColor: isDarkMode == false ? Colors.white : appBarColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: model.formState,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 15.0, left: 60.0, right: 60.0),
                              child: AddAccessoryDialogForm(),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.0),
                        SizedBox(height: 32.0),
                        AddAccessoryDialogSubmitBtn(
                          onSave: () async {
                            if (model.device.name == null &&
                                model.device.ip == null) {
                              toast("Please fill all data", themeColor);
                            } else {
                              await model.addAccessory(context);
                            }
                          },
                          submissionInProgress: model.submissionInProgress,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )

        // === Mobile ====
        : Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: model.formState,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 12.0, right: 12.0),
                              child: AddAccessoryDialogForm(),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.0),
                        AddAccessoryDialogSubmitBtn(
                          onSave: () async {
                            if (model.device.name == null &&
                                model.device.ip == null) {
                              toast("Please fill all data", themeColor);
                            } else {
                              await model.addAccessory(context);
                            }
                          },
                          submissionInProgress: model.submissionInProgress,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  @override
  void initState() {
    super.initState();
    // === Loading Printers Network ====
    Provider.of<PrinterServicesProvider>(context, listen: false).discover();
  }
}
