import 'package:app/core/utils/utils.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/menuItems/menu.item.dart';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ItemGroupsContainer extends StatefulWidget {
  final List<ItemsGroups> itemGroups;

  ItemGroupsContainer({Key key, this.itemGroups}) : super(key: key);

  @override
  ItemGroupsContainerState createState() => ItemGroupsContainerState();
}

class ItemGroupsContainerState extends State<ItemGroupsContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      color: mainBlueColor,
      child: itemGroupsBuilder(),
    );
  }

  // item groups builder
  ListView itemGroupsBuilder() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.itemGroups.length,
      itemBuilder: (BuildContext context, int index) {
        return itemGroupTab(index, widget.itemGroups[index].itemGroup);
      },
    );
  }

  // item groups tab
  Widget itemGroupTab(num index, String tabTitle) {
    MenuItemProvider menuItemProvider = Provider.of<MenuItemProvider>(context);

    return InkWell(
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 20, right: 20),
        child: Text(tabTitle,
            style: TextStyle(
              fontSize: 20,
              color: index == menuItemProvider.selectedItemGroupIndex
                  ? themeColor
                  : Colors.white,
            )),
      ),
      onTap: () {
        getItemsOfGroup(index);
      },
    );
  }

  getItemsOfGroup(int index) {
    MenuItemProvider menuItemProvider =
        Provider.of<MenuItemProvider>(context, listen: false);

    menuItemProvider.getItemsOfGroup(index);

    menuItemProvider.updateMainWidget(
        widget.itemGroups[menuItemProvider.selectedItemGroupIndex].itemGroup);
  }
}
