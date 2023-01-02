import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/searchInvioceList/search.invoice.list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import '../../../core/extensions/widget_extension.dart';

class SearchAutoComplete extends StatefulWidget {
  const SearchAutoComplete(
      {Key key, this.searchResultCallback, this.resetDefault})
      : super(key: key);

  final Function(List<Invoice> invoices) searchResultCallback;
  final VoidCallback resetDefault;

  @override
  _SearchAutoCompleteState createState() => _SearchAutoCompleteState();
}

class _SearchAutoCompleteState extends State<SearchAutoComplete> {
  @override
  Widget build(BuildContext context) {
    SearchAutoCompleteProvider model =
        Provider.of<SearchAutoCompleteProvider>(context);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      child: typeMobile == TYPEMOBILE.TABLET
          ? Row(
              children: [
                Expanded(
                  child: TypeAheadField<String>(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: model.textEditingController,
                      autofocus: false,
                      style: TextStyle(
                        color:
                            isDarkMode == false ? Colors.black : Colors.white,
                      ),
                      decoration: _inputDecoration.copyWith(
                        hintText: Localization.of(context).tr('search_by') +
                            " ${Localization.of(context).tr("${model.selectedFilter}")}",
                        fillColor: isDarkMode == false
                            ? Colors.white
                            : searchColorDark,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            model.clear(context);
                            widget.resetDefault();
                          },
                          icon: Icon(Icons.clear),
                        ),
                      ),
                    ),
                    hideOnLoading: true,
                    suggestionsCallback: (pattern) async {
                      model.clearCustomerResult();
                      model.setPatteren(pattern);

                      if (pattern.isEmpty) {
                        Future.delayed(Duration(milliseconds: 300), () {
                          widget.resetDefault();
                        });
                      }

                      if (pattern.isNotEmpty &&
                          model.selectedFilter != 'customer') {
                        List<Invoice> invoices = await model.filter(pattern);

                        widget.searchResultCallback(invoices);
                      }

                      if (pattern.isEmpty ||
                          model.selectedFilter != 'customer') {
                        return Iterable.empty();
                      }

                      return await model.filter(pattern);
                    },
                    noItemsFoundBuilder: (context) {
                      if (model.patteren.isEmpty ||
                          model.customersResult == null) {
                        return SizedBox.shrink();
                      }

                      return Text("No results found.");
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) async {
                      List<Invoice> invoices =
                          await model.getInvoices(suggestion);
                      model.setSearchSuggestion(suggestion);

                      widget.searchResultCallback(invoices);
                    },
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.filter_alt_rounded),
                  onSelected: (String value) {
                    widget.resetDefault();
                    model.setSelectedFilter(value);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'customerName',
                      child: Text(
                          Localization.of(context).tr('search_by_customer')),
                    ),
                    PopupMenuItem(
                      value: 'invoiceNo',
                      child: Text(Localization.of(context)
                          .tr('search_by_invoice_no')),
                    ),
                    PopupMenuItem(
                      value: 'invoiceTotal',
                      child: Text(
                          Localization.of(context).tr('search_by_total')),
                    ),
                    PopupMenuItem(
                      value: 'invoiceTableNo',
                      child: Text(
                          Localization.of(context).tr('search_by_table_no')),
                    ),
                  ],
                )
              ],
            ).paddingHorizontally(8)
          : SizedBox(),
    );
  }

  InputDecoration _inputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: Colors.grey.shade800, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: themeColor, width: 0.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: Colors.grey.shade800, width: 0.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide(color: Colors.red.shade800, width: 0.5),
    ),
  );
}
