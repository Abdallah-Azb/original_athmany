import 'package:app/localization/localization.dart';
import 'package:app/modules/opening/provider/new.opening.provider.dart';
import 'package:provider/provider.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:flutter/material.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:nil/nil.dart';

class SelectCompany extends StatefulWidget {
  final List<Company> companiesList;
  SelectCompany({this.companiesList});
  @override
  _SelectCompanyState createState() => _SelectCompanyState();
}

class _SelectCompanyState extends State<SelectCompany> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {
          if (widget.companiesList.length == 1)
            context
                .read<NewOpeningProvider>()
                .setSelectedCompany(widget.companiesList[0])
        });
  }

  @override
  Widget build(BuildContext context) {
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
                  Localization.of(context).tr('select_company'),
                  style: TextStyle(fontSize: 20,color: isDarkMode == false
                      ? Colors.black26
                      : Colors.white,),
                ),
              ),
              SizedBox(
                height: 6,
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
                  child: dropDownList()),
            ],
          )

        // ==== Mobile ====
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // label
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  Localization.of(context).tr('select_company'),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                height: 6,
              ),
              // dropdown list
              Container(
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: isDarkMode == false
                              ? Colors.black26
                              : Colors.white),
                      borderRadius: BorderRadius.circular(10)),
                  child: dropDownList()),
            ],
          );
  }

  // dropdown builder
  List<DropdownMenuItem<Company>> buildDropdownMenuItems(List companies) {
    List<DropdownMenuItem<Company>> items = [];
    for (Company company in companies) {
      items.add(
          // DropdownMenuItem(
          //   value: company,
          //   child: Text(company.value),
          // ),
          // ix merge , ix code
          buildItem(value: company, text: company.value));
    }
    return items;
  }

  DropdownMenuItem<Company> buildItem({value, text}) {
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

  // dropdown list
  Widget dropDownList() {
    NewOpeningProvider newOpeningProvider = context.read<NewOpeningProvider>();
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return DropdownButton(
      underline: const SizedBox.shrink(),
      isExpanded: true,
      hint: Text(
        Localization.of(context).tr('choose'),
        style: TextStyle(fontSize: typeMobile == TYPEMOBILE.TABLET ? 17 : 16),
      ),
      value: newOpeningProvider.selectedCompany,
      items: buildDropdownMenuItems(widget?.companiesList ?? []),
      onChanged: (selectedCompany) {
        context.read<NewOpeningProvider>().setLoadingValue(true);
        context.read<NewOpeningProvider>().setSelectedProfile(null);
        context.read<NewOpeningProvider>().setSelectedCompany(selectedCompany);
      },
    );
  }
}
