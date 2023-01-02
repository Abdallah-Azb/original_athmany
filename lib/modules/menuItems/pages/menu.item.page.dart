import 'dart:developer';
import 'package:app/core/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../../core/enums/type_mobile.dart';
import '../../../core/utils/utils.dart';
import '../../../models/models.dart';
import '../../../providers/type_mobile_provider.dart';
import '../../../widget/provider/theme_provider.dart';
import '../../../widget/widget/loading_animation_widget.dart';
import '../../invoice/invoice.dart';
import '../menu.item.dart';

class Menu extends StatefulWidget {
  final String localPath;
  final String baseUrl;
  final List<ItemsGroups> itemGroups;
  const Menu({
    Key key,
    this.itemGroups,
    this.baseUrl,
    this.localPath,
  }) : super(key: key);

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context.read<MenuItemProvider>().selectedItemGroup =
        widget.itemGroups.first.itemGroup;
    context.read<MenuItemProvider>().getLogo();
    context.read<MenuItemProvider>().tabController =
        TabController(vsync: this, length: widget.itemGroups.length);
  }

  void updateSelectedIndex(int index) {
    context.read<MenuItemProvider>().tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<MenuItemProvider>(context);
    final typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    // final deliveryApplicationProvider =
    //     Provider.of<DeliveryApplicationProvider>(context, listen: true);
    final tableName = context
            .watch<DeliveryApplicationProvider>()
            .selectedDeliveryApplication
            ?.name ??
        "default_price_list";
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      color: isDarkMode == false ? greyColor : const Color(0xff1F1F1F),
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: typeMobile == TYPEMOBILE.TABLET
                ? Container(
                    color: isDarkMode == false
                        ? mainBlueColor
                        : const Color(0xff1F1F1F),
                    child: TabBar(
                      controller: model.tabController,
                      isScrollable: true,
                      unselectedLabelColor: Colors.white,
                      labelColor: themeColor,
                      indicatorColor: themeColor,
                      labelPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                      labelStyle:
                          const TextStyle(fontSize: 20, fontFamily: 'Cairo'),
                      tabs: widget.itemGroups
                          .map(
                            (e) => Tab(
                              text: e.itemGroup ?? '',
                            ),
                          )
                          .toList(),
                    ),
                  )
                // mobile
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDarkMode == false
                            ? mainBlueColor
                            : const Color(0xff1F1F1F),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TabBar(
                        controller: model.tabController,
                        isScrollable: true,
                        unselectedLabelColor: Colors.white,
                        labelColor: themeColor,
                        indicatorColor: themeColor,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 20.0),
                        labelStyle:
                            const TextStyle(fontSize: 13, fontFamily: 'Cairo'),
                        tabs: widget.itemGroups
                            .map(
                              (e) => Tab(
                                text: e.itemGroup,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: model.tabController,
              children: widget.itemGroups
                  .map(
                    (e) => _ItemGrounp(
                      itemGroup: e.itemGroup,
                      localPath: widget.localPath,
                      baseUrl: widget.baseUrl,
                      // tableName: tableName,
                      // getItemsOfGroup: model.getItemsOfGroupsAndLogo,
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}

// show qty dialog
showQtyDialog(ItemOfGroup itemOfGroup, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return QtyDialogWidget(
        newItem: true,
        itemOfGroup: itemOfGroup,
      );
    },
  );
}

class _ItemGrounp extends HookWidget {
  const _ItemGrounp({
    this.itemGroup,
    this.localPath,
    this.baseUrl,
    // this.tableName,
    this.getItemsOfGroup,
    Key key,
  }) : super(key: key);

  final String baseUrl, localPath, itemGroup;
  final Future<List<ItemOfGroup>> Function(String itemGroup, String tableName)
      getItemsOfGroup;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MenuItemProvider>();
    final tableName = context
            .watch<DeliveryApplicationProvider>()
            .selectedDeliveryApplication
            ?.name ??
        "default_price_list";
    return FutureBuilder(
      future: provider.getItemsOfGroupsAndLogo(itemGroup, tableName),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) log(snapshot.error.toString());
        if (snapshot.hasData) {
          return Items(
            itemsOfGroup: snapshot.data,
            localPath: localPath,
            baseUrl: baseUrl,
          );
        }
        return const Center(
          child: LoadingAnimation(
            typeOfAnimation: "staggeredDotsWave",
            color: Colors.green,
            size: 70,
          ),
        );
      },
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    Key key,
    this.itemOfGroup,
    this.localPath,
    this.baseUrl,
  }) : super(key: key);
  final ItemOfGroup itemOfGroup;
  final String localPath;
  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return MenuItemm(
      itemOfGroup: itemOfGroup,
      baseUrl: baseUrl,
      localPath: localPath,
      onTap: () async {
        await context
            .read<InvoiceProvider>()
            .addItemOrUpdateItemQty(itemOfGroup);
      },
      onLongPress: () {
        showQtyDialog(itemOfGroup, context);
      },
    );
  }
}

class Items extends StatelessWidget {
  const Items({
    Key key,
    this.itemsOfGroup,
    this.baseUrl,
    this.localPath,
  }) : super(key: key);
  final List<ItemOfGroup> itemsOfGroup;
  final String baseUrl;
  final String localPath;

  @override
  Widget build(BuildContext context) {
    final typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 10 / 9,
            scrollDirection: Axis.vertical,
            children: List.generate(
              itemsOfGroup.length,
              (index) {
                return Center(
                  child: _Item(
                    itemOfGroup: itemsOfGroup[index],
                    localPath: localPath,
                    baseUrl: baseUrl,
                  ),
                );
              },
            ),
          )
        // mobile
        : GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 0.95,
            scrollDirection: Axis.vertical,
            children: List.generate(
              itemsOfGroup.length,
              (index) {
                return _Item(
                  itemOfGroup: itemsOfGroup[index],
                  localPath: localPath,
                  baseUrl: baseUrl,
                );
              },
            ),
          );
  }
}
