import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/item.of.group.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../widget/widget/loading_animation_widget.dart';
import '../../core/extensions/widget_extension.dart';

class StockPage extends StatefulWidget {
  final String baseUrl;
  StockPage({this.baseUrl});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  DBItemOfGroup _dbItemOfGroup = DBItemOfGroup();
  Future itemsFuture;

  @override
  void initState() {
    super.initState();
    this.itemsFuture = this._dbItemOfGroup.getAllItems();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    return FutureBuilder<List<ItemOfGroup>>(
      future: this.itemsFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<ItemOfGroup>> snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (snapshot.hasData) {
          return Container(
              color: isDarkMode == false ? mainBlueColor : Color(0xff1F1F1F),
              child: items(snapshot.data));
        }
        return Center(
          child: LoadingAnimation(
            typeOfAnimation: "staggeredDotsWave",
            color: themeColor,
            size: 100,
          ),
        );
      },
    );
  }

  // items menu
  Widget items(List<ItemOfGroup> itemsOfGroup) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? GridView.count(
            crossAxisCount: 5,
            childAspectRatio: 10 / 10,
            scrollDirection: Axis.vertical,
            children: List.generate(itemsOfGroup.length, (index) {
              return Center(
                child: item(itemsOfGroup[index]),
              );
            }),
          )

        // === Mobile ===
        : GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 7 / 10, // 10/ 10
            scrollDirection: Axis.vertical,
            children: List.generate(itemsOfGroup.length, (index) {
              return Center(
                child: item(itemsOfGroup[index]),
              );
            }),
          );
  }

  Widget item(ItemOfGroup itemOfGroup) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? Colors.red.withOpacity(0.4) : Colors.red,
          ),
          color: isDarkMode == false ? Colors.white : darkBackGroundColor,
          borderRadius: BorderRadius.circular(16.0)),
      margin: typeMobile == TYPEMOBILE.TABLET
          ? EdgeInsets.all(20)
          : EdgeInsets.all(8),
      // width: 220,
      // height: 192,
      child: Column(
        children: [
          // item image
          Expanded(child: image(itemOfGroup)),
          Column(
            children: [
              Row(
                children: [
                  // item name
                  name(itemOfGroup),
                  SizedBox(
                    width: typeMobile == TYPEMOBILE.TABLET ? 3 : 0,
                  ),
                  // item price
                  price(itemOfGroup)
                ],
              ),
              Row(
                children: [
                  // item name
                  Expanded(child: Text(Localization.of(context).tr('qty'))),
                  SizedBox(
                    width: typeMobile == TYPEMOBILE.TABLET ? 3 : 0,
                  ),
                  // item price
                  Text(
                    itemOfGroup.actualQty.toString(),
                    style: TextStyle(
                      color: itemOfGroup.actualQty < 0
                          ? Colors.red
                          : Colors.black,
                    ),
                  )
                ],
              ),
            ],
          ).paddingAll(typeMobile == TYPEMOBILE.TABLET ? 10 : 3)
        ],
      ),
    );
  }

  // item image
  Widget image(ItemOfGroup itemOfGroup) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        image: DecorationImage(
          image: itemOfGroup.itemImage == 'null' || itemOfGroup.itemImage == ''
              ? AssetImage(
                  'assets/no-image.png',
                )
              : CachedNetworkImageProvider(
                  "${widget.baseUrl}/" + itemOfGroup.itemImage),
          fit: BoxFit.fill,
          // fit: widget.item.imageLocalPath == "" ? BoxFit.contain : BoxFit.fill,
        ),
      ),
      // child: image == null ? noImage() : Image.network(image),
      // height: 134,
    );
  }

  // item name
  Widget name(ItemOfGroup itemOfGroup) {
    return Expanded(
        // item name
        child: Text(
      itemOfGroup.itemName,
      maxLines: 1,
      style: TextStyle(fontSize: 16),
    ));
  }

  // item price
  Widget price(ItemOfGroup itemOfGroup) {
    return Text(
      itemOfGroup.priceListRate.toString(),
      style: TextStyle(fontSize: 16),
    );
  }
}

// import 'package:app/core/utils/const.dart';
// import 'package:app/models/item.of.group.dart';
// import 'package:app/models/items.group.dart';
// import 'package:app/modules/menuItems/widgets/menu.item.dart';
// import 'package:flutter/material.dart';

// class StockPage extends StatefulWidget {
//   final List<ItemsGroups> itemGroups;

//   StockPage({Key key, this.itemGroups}) : super(key: key);

//   @override
//   _StockPageState createState() => _StockPageState();
// }

// class _StockPageState extends State<StockPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: greyColor,
//       child: CustomScrollView(
//         physics: NeverScrollableScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: Container(
//               color: mainBlueColor,
//               child: TabBar(
//                 controller: model.tabController,
//                 isScrollable: true,
//                 unselectedLabelColor: Colors.white,
//                 labelColor: themeColor,
//                 indicatorColor: themeColor,
//                 labelPadding: EdgeInsets.symmetric(horizontal: 20.0),
//                 labelStyle: TextStyle(fontSize: 20, fontFamily: 'Cairo'),
//                 tabs: widget.itemGroups
//                     .map(
//                       (e) => Tab(
//                         text: e.itemGroup,
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ),
//           SliverFillRemaining(
//             child: TabBarView(
//               children: widget.itemGroups
//                   .map((e) => FutureBuilder(
//                         future: model.getItemsOfGroupsAndLogo(
//                             e.itemGroup, tableName),
//                         builder:
//                             (BuildContext context, AsyncSnapshot snapshot) {
//                           if (snapshot.hasError)
//                             print(snapshot.error.toString());
//                           if (snapshot.hasData) return items(snapshot.data);
//                           return Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         },
//                       ))
//                   .toList(),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   // items menu
//   Widget items(List<ItemOfGroup> itemsOfGroup) {
//     return GridView.count(
//       crossAxisCount: 3,
//       childAspectRatio: 10 / 9,
//       scrollDirection: Axis.vertical,
//       children: List.generate(itemsOfGroup.length, (index) {
//         return Center(
//           child: item(itemsOfGroup[index]),
//         );
//       }),
//     );
//   }

//   // item container
//   Widget item(ItemOfGroup itemOfGroup) {
//     return MenuItem(
//       itemOfGroup: itemOfGroup,
//       baseUrl: widget.baseUrl,
//     );
//   }
// }
