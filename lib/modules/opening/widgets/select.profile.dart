import 'package:app/core/enums/type_mobile.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/modules/opening/provider/new.opening.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:nil/nil.dart';

class SelectProfile extends StatefulWidget {
  @override
  SelectProfileState createState() => SelectProfileState();
}

class SelectProfileState extends State<SelectProfile> {
  List<DropdownMenuItem<Profile>> buildDropdownMenuItems(List posProfilesList) {
    List<DropdownMenuItem<Profile>> items = [];
    for (Profile posProfile in posProfilesList) {
      items.add(
          // DropdownMenuItem(
          //   value: posProfile,
          //   child: Text(posProfile.value),
          // ),
          buildItem(value: posProfile, text: posProfile.value));
    }
    return items;
  }

  DropdownMenuItem<Profile> buildItem({value, text}) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? DropdownMenuItem(
            value: value,
            child: Text(text),
          )
        // ====== Mobile =====
        : DropdownMenuItem(
            value: value,
            child: Text(
              text,
              style: TextStyle(fontSize: 13),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return salesPointDropDown();
  }

  // sales point name dropdown
  Widget salesPointDropDown() {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;

    return typeMobile == TYPEMOBILE.TABLET
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // label
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  Localization.of(context).tr('select_profile'),
                  style: TextStyle(fontSize: 20),
                ),
              ),
              // dropdown list
              Container(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 4),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: isDarkMode == false
                            ? Colors.black26
                            : Colors.white),
                    borderRadius: BorderRadius.circular(20)),
                child: DropdownButton(
                  underline: const SizedBox.shrink(),
                  hint: Text(
                    Localization.of(context).tr('choose'),
                    style: TextStyle(fontSize: 20,
                        color: isDarkMode == false
                        ? Colors.black26
                        : Colors.white),
                  ),
                  isExpanded: true,
                  value: context.read<NewOpeningProvider>().selectedProfile,
                  items: buildDropdownMenuItems(
                      context.read<NewOpeningProvider>().profilesList),
                  onChanged: (selectedPOSProfile) {
                    context
                        .read<NewOpeningProvider>()
                        .setSelectedProfile(selectedPOSProfile);
                  },
                ),
              ),
            ],
          )
        // ===== Mobile =====
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // label
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  Localization.of(context).tr('select_profile'),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              // dropdown list
              Container(
                padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: isDarkMode == false
                            ? Colors.black26
                            : Colors.white),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButton(
                  underline: const Nil(),
                  hint: Text(
                    Localization.of(context).tr('choose'),
                    style: TextStyle(fontSize: 16),
                  ),
                  isExpanded: true,
                  value: context.read<NewOpeningProvider>().selectedProfile,
                  items: buildDropdownMenuItems(
                      context.read<NewOpeningProvider>().profilesList),
                  onChanged: (selectedPOSProfile) {
                    context
                        .read<NewOpeningProvider>()
                        .setSelectedProfile(selectedPOSProfile);
                  },
                ),
              ),
            ],
          );
  }
}
