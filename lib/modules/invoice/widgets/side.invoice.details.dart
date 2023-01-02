import 'package:app/core/enums/doc.status.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/menuItems/menu.item.dart';
import 'package:app/pages/home/menu/qty.dialog/qty.dialog.provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/models/models.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../invoice.dart';

class SideInvoiceDetails extends StatefulWidget {
  SideInvoiceDetails({Key key}) : super(key: key);
  @override
  SideInvoiceDetailsState createState() => SideInvoiceDetailsState();
}

class SideInvoiceDetailsState extends State<SideInvoiceDetails> {
  final scrollDirection = Axis.vertical;
  AutoScrollController controller;

  @override
  void initState() {
    controller = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: scrollDirection,
    );

    super.initState();
  }

  Future scrollToIndex(int index) async {
    await controller.scrollToIndex(index,
        preferPosition: AutoScrollPosition.begin);
  }

  Future highlightToIndex(int index) async {
    await controller.highlight(index);
  }

  @override
  Widget build(BuildContext context) {
    return invoiceDetails();
  }

  // invoice details
  Widget invoiceDetails() {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: true);
    MenuItemProvider menuItemProvider =
        Provider.of<MenuItemProvider>(context, listen: false);
    DeliveryApplicationProvider deliveryApplicationProvider =
        Provider.of<DeliveryApplicationProvider>(context);

    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Expanded(
        child: Container(
      color: isDarkMode == false ? Colors.white : darkContainerColor,
      child: invoice.currentInvoice?.docStatus != DOCSTATUS.PAID
          ? ListView(
              controller: controller,
              children: invoice.currentInvoice.itemsList.reversed
                  .toList()
                  .asMap()
                  .entries
                  .map((invoiceItem) => GestureDetector(
                        onTap: () async {
                          print("fgdgdfgdfgdfgdfg");
                          int index = await menuItemProvider
                              .getItemGroupIndex(invoiceItem.value.itemGroup);
                          if (index != -1)
                            menuItemProvider.updateSelectedIndex(index);
                        },
                        onLongPress: () async {
                          context
                              .read<QtyDialogProvider>()
                              .setItemUniqueId(invoiceItem.value.uniqueId);
                          String tableName = deliveryApplicationProvider
                                      .selectedDeliveryApplication ==
                                  null
                              ? 'default_price_list'
                              : deliveryApplicationProvider
                                  .selectedDeliveryApplication.name;

                          ItemOfGroup itemOfGroup =
                              await menuItemProvider.getItemGroup(
                                  invoiceItem.value.itemName, tableName);

                          if (itemOfGroup != null)
                            showDialog(
                              context: context,
                              builder: (context) => QtyDialogWidget(
                                newItem: false,
                                itemOfGroup: itemOfGroup,
                              ),
                            );
                        },
                        child: Dismissible(
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            // margin: EdgeInsets.only(bottom: 6),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(left: 20),
                            color: Colors.red,
                            child: Icon(
                              Icons.delete_forever_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          onDismissed: (direction) {
                            invoice.removeItem(invoiceItem.value);
                          },
                          key: Key(UniqueKey().toString()),
                          child: itemsRows(invoiceItem, context, controller,
                              context.read<InvoiceProvider>()),
                        ),
                      ))
                  .toList(),
            )
          : ListView(
              controller: controller,
              children: invoice.currentInvoice.itemsList?.reversed
                  ?.map((invoiceItem) => Column(children: [
                        Container(
                            color: invoiceItem.itemOptionsWith != null
                                ? invoiceItem.itemOptionsWith.firstWhere(
                                                (e) => e.selected,
                                                orElse: () => null) !=
                                            null ||
                                        invoiceItem.itemOptionsWithout
                                                .firstWhere((e) => e.selected,
                                                    orElse: () => null) !=
                                            null
                                    ? Color.fromARGB(100, 255, 209, 117)
                                    : Colors.black12
                                : Colors.black12,
                            child: ItemRow(item: invoiceItem)),
                        SizedBox(height: 6.0),
                        invoiceItem.showOptions
                            ? Container(
                                height: (invoiceItem.itemOptionsWith
                                            .where((e) => e.selected == true)
                                            .length *
                                        26)
                                    .toDouble(),
                                child: ListView.builder(
                                  itemCount: invoiceItem.itemOptionsWith.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      width: 300,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          invoiceItem.itemOptionsWith[index]
                                                  .selected
                                              ? Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                          "- ${Localization.of(context).tr('with_option')} ${invoiceItem.itemOptionsWith[index].itemName}"),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                            "(${invoiceItem.itemOptionsWith[index].priceListRate}) "),
                                                        Text((invoiceItem
                                                                    .itemOptionsWith[
                                                                        index]
                                                                    .priceListRate *
                                                                invoiceItem.qty)
                                                            .toStringAsFixed(2))
                                                      ],
                                                    )
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(),
                        invoiceItem.showOptions
                            ? Container(
                                height: (invoiceItem.itemOptionsWithout
                                            .where((e) => e.selected == true)
                                            .length *
                                        26)
                                    .toDouble(),
                                child: ListView.builder(
                                  itemCount:
                                      invoiceItem.itemOptionsWithout.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      width: 300,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          invoiceItem.itemOptionsWithout[index]
                                                  .selected
                                              ? Text(
                                                  "- ${Localization.of(context).tr('without_option')} ${invoiceItem.itemOptionsWithout[index].itemName}")
                                              : Container(),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(),
                        SizedBox(height: 4.0),
                      ]))
                  ?.toList(),
            ),
    ));
  }
}

// items rows
itemsRows(MapEntry<int, Item> invoiceItem, context, controller,
    InvoiceProvider invoiceProvider) {
  return Column(
    children: [
      Container(
        color: invoiceItem.value.itemOptionsWith != null
            ? invoiceItem.value.itemOptionsWith.firstWhere((e) => e.selected,
                            orElse: () => null) !=
                        null ||
                    invoiceItem.value.itemOptionsWithout.firstWhere(
                            (e) => e.selected,
                            orElse: () => null) !=
                        null
                ? Color.fromARGB(100, 255, 209, 117)
                : Colors.black12
            : Colors.black12,
        child: AutoScrollTag(
          key: ValueKey(invoiceItem.key),
          index: invoiceItem.key,
          controller: controller,
          highlightColor: themeColor.withOpacity(0.5),
          child: ItemRow(
            item: invoiceItem.value,
          ),
        ),
      ),
      invoiceItem.value.showOptions
          ? Container(
              height: (invoiceItem.value.itemOptionsWith
                          .where((e) => e.selected == true)
                          .length *
                      26)
                  .toDouble(),
              child: ListView.builder(
                itemCount: invoiceItem.value.itemOptionsWith.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        invoiceItem.value.itemOptionsWith[index].selected
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                        "- ${Localization.of(context).tr('with_option')} ${invoiceItem.value.itemOptionsWith[index].itemName}"),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          "(${invoiceItem.value.itemOptionsWith[index].priceListRate}) "),
                                      Text((invoiceItem
                                                  .value
                                                  .itemOptionsWith[index]
                                                  .priceListRate *
                                              invoiceItem.value.qty)
                                          .toStringAsFixed(2))
                                    ],
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  );
                },
              ),
            )
          : Container(),
      invoiceItem.value.showOptions
          ? Container(
              height: (invoiceItem.value.itemOptionsWithout
                          .where((e) => e.selected == true)
                          .length *
                      26)
                  .toDouble(),
              child: ListView.builder(
                itemCount: invoiceItem.value.itemOptionsWithout.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        invoiceItem.value.itemOptionsWithout[index].selected
                            ? Text(
                                "- ${Localization.of(context).tr('without_option')} ${invoiceItem.value.itemOptionsWithout[index].itemName}")
                            : Container(),
                      ],
                    ),
                  );
                },
              ),
            )
          : Container(),
      SizedBox(height: 4.0),
    ],
  );
}

class ItemRow extends StatefulWidget {
  final Item item;

  const ItemRow({
    Key key,
    @required this.item,
  }) : super(key: key);

  @override
  ItemRowState createState() => ItemRowState();
}

class ItemRowState extends State<ItemRow> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          itemName(widget.item.itemName),
          itemQtyAndActoins(widget.item),
          total(widget.item)
          // deleteBtn(index)
        ],
      ),
      onTap: () {
        updateShowOptionsState(widget.item);
      },
    );
  }

  updateShowOptionsState(Item item) {
    print(item.uniqueId);
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    invoice.updateShowItemOptionsState(
        item.uniqueId, item.showOptions == true ? false : true);
  }

  // item name
  Widget itemName(String name) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        alignment: Alignment.center,
        // height: 46,
        child: FittedBox(
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // total
  Widget total(Item item) {
    double itemOptionsTotal = 0;
    for (ItemOption itemOption
        in item.itemOptionsWith.where((e) => e.selected)) {
      itemOptionsTotal += itemOption.priceListRate;
    }
    double total = item.rate * item.qty;
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        height: 46,
        child: Text((total + (itemOptionsTotal * item.qty)).toStringAsFixed(2),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // item qty and actions
  Widget itemQtyAndActoins(Item item) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    return Expanded(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: invoice.currentInvoice.docStatus != DOCSTATUS.PAID
                ? decreaseQtyBtn(item)
                : Container(height: 44)),
        Expanded(
            child: Text(item.qty.toString().toString(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        Expanded(
            child: invoice.currentInvoice.docStatus != DOCSTATUS.PAID
                ? increaseQtyBtn(item)
                : Container(height: 44)),
      ],
    ));
  }

  // decrease item qty button
  Widget decreaseQtyBtn(Item item) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    return IconButton(
        icon: Icon(
          invoice.deleteItem,
          color: Colors.orange,
          size: 24,
        ),
        onPressed: () async {
          await invoice.decreaseItemQty(item.uniqueId);
        });
  }

  // delete item button
  Widget deleteBtn(num index) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    return IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          invoice.removeItem(index);
        });
  }

  // increase item qty button
  Widget increaseQtyBtn(Item item) {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    return IconButton(
        icon: Icon(
          Icons.add,
          color: themeColor,
          size: 24,
        ),
        onPressed: () async {
          await invoice.increaseItemsFromPlus(item.uniqueId);
        });
  }
}
