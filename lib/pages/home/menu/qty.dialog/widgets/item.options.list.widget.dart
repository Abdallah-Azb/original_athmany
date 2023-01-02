import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/utils/utils.dart';
import '../../../../../localization/localization.dart';
import '../../../../../models/models.dart';
import '../qty.dialog.provider.dart';

class ItemOptionsListWidget extends StatefulWidget {
  const ItemOptionsListWidget({Key key}) : super(key: key);

  @override
  _ItemOptionsListWidgetState createState() => _ItemOptionsListWidgetState();
}

class _ItemOptionsListWidgetState extends State<ItemOptionsListWidget> {
  @override
  Widget build(BuildContext context) {
    QtyDialogProvider qtyDialogProvider = context.read<QtyDialogProvider>();

    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    return typeMobile == TYPEMOBILE.TABLET
        ? /*Container(
            height: 580,
            width: 533,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  optionListTitle(context, 'with_adding'),
                  optionsList(qtyDialogProvider.itemOptionsWith),
                  optionListTitle(context, 'without_adding'),
                  optionsList(qtyDialogProvider.itemOptionsWithout),
                ],
              ),
            ),
          )*/
        DefaultTabController(
            length: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 20, top: 20),
              child: Container(
                  height: MediaQuery.of(context).size.height / 2.3,
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(
                              child: Text(
                            Localization.of(context).tr('with_adding'),
                            style: TextStyle(
                                fontSize: 17,
                                color:
                                    isDarkMode ? Colors.white60 : Colors.black,
                                fontWeight: FontWeight.w800),
                          )),
                          Tab(
                              child: Text(
                            Localization.of(context).tr('without_adding'),
                            style: TextStyle(
                                fontSize: 17,
                                color:
                                    isDarkMode ? Colors.white60 : Colors.black,
                                fontWeight: FontWeight.w800),
                          )),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(children: [
                          ListView(
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 2.3,
                                  child: optionsList(
                                      qtyDialogProvider.itemOptionsWith)),
                            ],
                          ),
                          ListView(
                            children: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 2.3,
                                  child: optionsList(
                                      qtyDialogProvider.itemOptionsWithout)),
                            ],
                          ),
                        ]),
                      )
                    ],
                  )),
            ),
          )
        : DefaultTabController(
            length: 2,
            child: Container(
                height: MediaQuery.of(context).size.height / 3.7,
                width: MediaQuery.of(context).size.width / 1.5,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(
                            child: Text(
                          Localization.of(context).tr('with_adding'),
                          style: TextStyle(
                              fontSize: 17,
                              color: isDarkMode ? Colors.white60 : Colors.black,
                              fontWeight: FontWeight.w800),
                        )),
                        Tab(
                            child: Text(
                          Localization.of(context).tr('without_adding'),
                          style: TextStyle(
                              fontSize: 17,
                              color: isDarkMode ? Colors.white60 : Colors.black,
                              fontWeight: FontWeight.w800),
                        )),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(children: [
                        ListView(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 3.8,
                                child: optionsList(
                                    qtyDialogProvider.itemOptionsWith)),
                          ],
                        ),
                        ListView(
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 3.8,
                                child: optionsList(
                                    qtyDialogProvider.itemOptionsWithout)),
                          ],
                        ),
                      ]),
                    )
                  ],
                )),
          );

    // Container(
    //         height: 230,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           children: [
    //             Padding(
    //               padding: const EdgeInsets.only(left: 15, right: 25),
    //               child: Container(
    //                 width: 300,
    //                 height: 90,
    //                 child: ExpansionTile(
    //                   title: Container(
    //                     alignment: Alignment.center,
    //                     margin: EdgeInsets.only(right: 25, left: 25),
    //                     width: 200,
    //                     height: 30,
    //                     decoration: BoxDecoration(
    //                       color: Colors.black12,
    //                       border: Border.all(
    //                         width: 2,
    //                         color: themeColor,
    //                       ),
    //                       borderRadius: BorderRadius.all(
    //                         Radius.circular(12),
    //                       ),
    //                     ),
    //                     child: Text(
    //                       Localization.of(context).tr('with_adding'),
    //                       style: TextStyle(fontSize: 15),
    //                     ),
    //                   ),
    //                   controlAffinity: ListTileControlAffinity.leading,
    //                   children: <Widget>[
    //                     Container(
    //                       height: 30,
    //                       child: ListView(
    //                         scrollDirection: Axis.vertical,
    //                         children: [
    //                           optionsList(qtyDialogProvider.itemOptionsWith),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.only(right: 25, left: 15),
    //               child: Container(
    //                 width: 300,
    //                 height: 90,
    //                 child: ExpansionTile(
    //                   title: Container(
    //                     alignment: Alignment.center,
    //                     margin: EdgeInsets.only(right: 25, left: 25),
    //                     width: 200,
    //                     height: 30,
    //                     decoration: BoxDecoration(
    //                       color: Colors.black12,
    //                       border: Border.all(
    //                         width: 2,
    //                         color: themeColor,
    //                       ),
    //                       borderRadius: BorderRadius.all(
    //                         Radius.circular(12),
    //                       ),
    //                     ),
    //                     child: Text(
    //                       Localization.of(context).tr('without_adding'),
    //                       style: TextStyle(fontSize: 15),
    //                     ),
    //                   ),
    //                   controlAffinity: ListTileControlAffinity.leading,
    //                   children: <Widget>[
    //                     Container(
    //                       height: 30,
    //                       child: ListView(
    //                         scrollDirection: Axis.vertical,
    //                         children: [
    //                           optionsList(
    //                             (qtyDialogProvider.itemOptionsWithout),
    //                           ),
    //                         ],
    //                       ),
    //                     )
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    // Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 5.0),
    //         child: Container(
    //           // color: isDarkMode == false ? Colors.white : darkContainerColor,
    //           height: MediaQuery.of(context).size.height / 4,
    //           width: MediaQuery.of(context).size.width / 1.3,
    //           child: Center(
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Expanded(
    //                   child: Padding(
    //                     padding: const EdgeInsets.symmetric(horizontal: 2),
    //                     child: Column(
    //                       children: [
    //
    //                         optionListTitle(context, 'with_adding'),
    //                         optionsList(qtyDialogProvider.itemOptionsWith),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //                 // Container(
    //                 //   height: MediaQuery.of(context).size.height / 4.5,
    //                 //   color: themeColor,
    //                 //   width: 1.5,
    //                 //   margin: EdgeInsets.only(top: 50),
    //                 // ),
    //                 Expanded(
    //                   child: Padding(
    //                     padding: const EdgeInsets.symmetric(horizontal: 2),
    //                     child: Column(
    //                       children: [
    //                         optionListTitle(context, 'without_adding'),
    //                         optionsList(qtyDialogProvider.itemOptionsWithout),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       );
  }

  Container optionListTitle(BuildContext context, String title) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(vertical: 6),
            width: 100,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: themeColor,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            child: Text(
              Localization.of(context).tr('$title'),
              style: TextStyle(fontSize: 20),
            ),
          )
        :
        // === Mobile ===
        ///___________________________________________________________________________
//         Container(
//             alignment: Alignment.center,
//             margin: EdgeInsets.symmetric(vertical: 6),
//             width: 160,
//             height: 36,
//             decoration: BoxDecoration(
//                 color: Colors.black12,
//                 border: Border.all(
//                   width: 2,
//                   color: themeColor,
//                 ),
//                 borderRadius: BorderRadius.all(Radius.circular(12))),
//             child: Text(
//               Localization.of(context).tr('$title'),
//               style: TextStyle(fontSize: 15),
//             ));

        Container();
  }

  GridView optionsList(List<ItemOption> itemOptoins) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3,
          mainAxisSpacing: 1,
          childAspectRatio: 2.9),
      // scrollDirection: Axis.vertical,
      // physics: NeverScrollableScrollPhysics(),
      // shrinkWrap: true,
      itemCount: itemOptoins.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: option(itemOptoins[index]),
        );
      },
    );
  }

  ///_____________________________________________________________________________
  option(ItemOption itemOption) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    QtyDialogProvider qtyDialogProvider = context.watch<QtyDialogProvider>();
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool status = false;
    void onChange(status) {
      itemOption.optionWith == 1
          ? qtyDialogProvider.updateItemOptionWithStatus(itemOption, status)
          : qtyDialogProvider.updateItemOptionWithoutStatus(itemOption, status);
    }

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // itemOption.optionWith == 1
          //     ? Padding(
          //         padding: const EdgeInsets.only(bottom: 2, right: 5),
          //         child: Text(
          //           itemOption.priceListRate.toString(),
          //         ),
          //       )
          //     : Container(
          //         width: 20,
          //       ),
          InkWell(
            onTap: () {
              setState(() {
                if (itemOption.selected) {
                  itemOption.selected = false;
                } else {
                  status = !status;
                  onChange(status);
                }
                status = !status;
              });
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: itemOption.selected ? themeColor : Colors.white12,
                  borderRadius: BorderRadius.circular(10),
                  // border: Border.all(
                  //   color: isDarkMode ? Colors.white70 : darkContainerColor,
                  // ),
                ),
                width: typeMobile == TYPEMOBILE.TABLET ? 200 : 120,
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            width: 90,
                            child: AutoSizeText(
                              itemOption.itemName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  // fontSize: 4,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black),
                              minFontSize: 5,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        itemOption.optionWith == 1
                            ? '+' + itemOption.priceListRate.toString()
                            : '',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Container(
          //   width: typeMobile == TYPEMOBILE.TABLET ? 450 : 100,
          //   child: CheckboxListTile(
          //     title: Text(
          //       itemOption.itemName,
          //       style: TextStyle(fontSize: 10),
          //     ),
          //     value: itemOption.selected,
          //     onChanged: (status) {
          //       itemOption.optionWith == 1
          //           ? qtyDialogProvider.updateItemOptionWithStatus(
          //               itemOption, status)
          //           : qtyDialogProvider.updateItemOptionWithoutStatus(
          //               itemOption, status);
          //     },
          //     controlAffinity:
          //         ListTileControlAffinity.leading, //  <-- leading Checkbox
          //   ),
          // ),
        ],
      ),
    );
  }
}
