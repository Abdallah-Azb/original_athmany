import 'package:app/core/utils/const.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/customer-refactor/models/models.dart';
import 'package:app/providers/home.provider.dart';
import 'package:app/services/customer.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:app/core/enums/type_mobile.dart';
import '../../../core/extensions/widget_extension.dart';

class CustomerSearch extends StatefulWidget {
  final Function updateCustomersPageState;
  CustomerSearch(this.updateCustomersPageState);

  @override
  _CustomerSearchState createState() => _CustomerSearchState();
}

class _CustomerSearchState extends State<CustomerSearch> {
  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode;

  bool searchByName = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: typeMobile == TYPEMOBILE.TABLET ? 60 : 50,
            decoration: BoxDecoration(
                color: isDarkMode == false ? Colors.white : darkContainerColor,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: TypeAheadField<Customer>(
                    hideSuggestionsOnKeyboardHide: false,
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: textEditingController,
                      focusNode: focusNode,
                      style: TextStyle(
                        color:
                            isDarkMode == false ? Colors.black : Colors.white,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color:
                              isDarkMode == false ? Colors.black : Colors.white,
                        ),
                        border: InputBorder.none,
                        hintText:
                            Localization.of(context).tr('customer_search_hint'),
                        // merge check the following TextStyle was not in our code
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    suggestionsCallback: searchCallBack,
                    // suggestionsCallback: searchByName
                    //     ? CustomerService().getCustomerSuggestionsName
                    //     : CustomerService().getCustomerSuggestions,
                    itemBuilder: (context, Customer suggestion) {
                      final customer = suggestion;
                      return typeMobile == TYPEMOBILE.TABLET
                          ? ListTile(
                              title: Text(
                                  "${customer.defaultMobile ?? "No mobileNumber"} - ${customer.customerName}"),
                              //subtitle: Text("${customer.customerName}"),
                            )
                          // mobile
                          : Card(
                              elevation: 3,
                              child: ListTile(
                                title: Text(
                                  "${customer.defaultMobile ?? "No Number"} -\n ${customer.customerName}",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                  ),
                                ),
                                //subtitle: Text("${customer.customerName}"),
                              ),
                            );
                    },
                    noItemsFoundBuilder: (context) => Container(
                      height: 50,
                      child: Text(
                        'No Customers Found.',
                        style: TextStyle(
                            fontSize:
                                typeMobile == TYPEMOBILE.TABLET ? 18 : 12),
                      ),
                    ),
                    onSuggestionSelected: (Customer suggestion) async {
                      final customer = suggestion;
                      await DBCustomer().add(customer);
                      widget.updateCustomersPageState();
                    },
                  ),
                ),
                IconButton(
                    onPressed: () {
                      focusNode.unfocus();
                      textEditingController.text = '';
                    },
                    icon: Icon(
                      Icons.cancel,
                      color:
                          isDarkMode == false ? Colors.black26 : Colors.white,
                    ))
              ],
            ).paddingAll(4),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        addCustomerButon()
      ],
    );
  }

  // add custoemr button
  Widget addCustomerButon() {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? InkWell(
            child: Container(
              alignment: Alignment.center,
              width: 140,
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: themeColor),
              child: Text(
                Localization.of(context).tr('add_customer'),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            onTap: () {
              context.read<HomeProvider>().setMainIndex(5);
            },
          )
        : InkWell(
            child: Container(
              alignment: Alignment.center,
              width: 140,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: themeColor),
              child: Text(
                Localization.of(context).tr('add_customer'),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            onTap: () {
              context.read<HomeProvider>().setMainIndex(5);
            },
          );
  }

  Future<List<Customer>> searchCallBack(String query) async {
    if (query.length > 0) if (double.parse(query[0], (e) => null) != null) {
      return CustomerService().getCustomerSuggestions(query);
    }
    return CustomerService().getCustomerSuggestionsName(query);
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    bool isNumber = double.parse(s, (e) => null) != null;
    print(isNumber);
    return isNumber;
  }
}
