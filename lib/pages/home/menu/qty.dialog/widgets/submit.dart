import 'dart:convert';

import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/item.dart';
import 'package:app/models/item.of.group.dart';
import 'package:app/models/item.option.dart';
import 'package:app/modules/invoice/provider/invoice.provider.dart';
import 'package:flutter/material.dart';
import '../qty.dialog.provider.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../../../../core/extensions/widget_extension.dart';
class Submit extends StatefulWidget {
  final bool newItem;
  final ItemOfGroup itemOfGroup;
  Submit({this.newItem, this.itemOfGroup});
  @override
  _SubmitState createState() => _SubmitState();
}

class _SubmitState extends State<Submit> {
  @override
  Widget build(BuildContext context) {
    QtyDialogProvider qtyDialogProvider = context.watch<QtyDialogProvider>();

    return InkWell(
      child: Container(
        height: 75,
        decoration: BoxDecoration(
            color: qtyDialogProvider.amount == "0" ? greyColor : themeColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )),
        alignment: Alignment.center,
        width: double.infinity,
        child: Text(
          Localization.of(context).tr('yes'),
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ).paddingAllNormal(),
      ),
      onTap: qtyDialogProvider.amount == "0"
          ? null
          : () {
              submit();
              Navigator.pop(context);
            },
    );
  }

  submit() {
    if (widget.newItem) {
      List<Item> items =
          context.read<InvoiceProvider>().currentInvoice.itemsList;
      Item item = items.firstWhere(
          (e) =>
              e.itemCode == widget.itemOfGroup.itemCode &&
              DeepCollectionEquality().equals(
                  e.itemOptionsWith?.map((e) => e.toJson())?.toList(),
                  context
                      .read<QtyDialogProvider>()
                      .itemOptionsWith
                      .map((e) => e.toJson())
                      .toList()) &&
              DeepCollectionEquality().equals(
                  e.itemOptionsWithout?.map((e) => e.toJson())?.toList(),
                  context
                      .read<QtyDialogProvider>()
                      .itemOptionsWithout
                      .map((e) => e.toJson())
                      .toList()),
          orElse: () => null);
      if (item != null) {
        // print(JsonEncoder.withIndent('  ').convert(context
        //     .read<QtyDialogProvider>()
        //     .itemOptionsWith
        //     .map((e) => e.toJson())
        //     .toList()));
        // print(context.read<QtyDialogProvider>().itemUniqueId);
        // print(item.uniqueId);
        // if (context.read<QtyDialogProvider>().itemUniqueId != null) {
        //   if (context.read<QtyDialogProvider>().itemUniqueId != item.uniqueId) {
        //     context.read<InvoiceProvider>().removeItem(items.firstWhere(
        //         (e) =>
        //             e.uniqueId ==
        //             context.read<QtyDialogProvider>().itemUniqueId,
        //         orElse: () => null));
        //   }
        // }
        updateInvoiceRow(item);
      } else {
        addNewInvoiceRow();
      }
    } else if (!widget.newItem) {
      List<Item> items =
          context.read<InvoiceProvider>().currentInvoice.itemsList;
      Item item = items.firstWhere(
          (e) =>
              e.itemCode == widget.itemOfGroup.itemCode &&
              DeepCollectionEquality().equals(
                  e.itemOptionsWith?.map((e) => e.toJson())?.toList(),
                  context
                      .read<QtyDialogProvider>()
                      .itemOptionsWith
                      .map((e) => e.toJson())
                      .toList()) &&
              DeepCollectionEquality().equals(
                  e.itemOptionsWithout?.map((e) => e.toJson())?.toList(),
                  context
                      .read<QtyDialogProvider>()
                      .itemOptionsWithout
                      .map((e) => e.toJson())
                      .toList()),
          orElse: () => null);
      if (item != null) {
        if (context.read<QtyDialogProvider>().itemUniqueId != item.uniqueId) {
          context.read<InvoiceProvider>().removeItem(items.firstWhere(
              (e) =>
                  e.uniqueId == context.read<QtyDialogProvider>().itemUniqueId,
              orElse: () => null));
        }
        updateInvoiceRow(item);
      } else {
        InvoiceProvider invoice = context.read<InvoiceProvider>();
        QtyDialogProvider qtyDialogProvider = context.read<QtyDialogProvider>();
        invoice.updateItemQty(
            context.read<QtyDialogProvider>().itemUniqueId,
            qtyDialogProvider.itemOptionsWith,
            qtyDialogProvider.itemOptionsWithout,
            int.parse(context.read<QtyDialogProvider>().amount));
      }
    }

    // if (widget.newItem) addNewInvoiceRow();
    // if (!widget.newItem) updateInvoiceRow();
  }

  addNewInvoiceRow() {
    QtyDialogProvider qtyDialogProvider = context.read<QtyDialogProvider>();
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    bool customizedItem = false;
    for (ItemOption itemOption in qtyDialogProvider.itemOptionsWith) {
      if (itemOption.selected) customizedItem = true;
    }
    for (ItemOption itemOption in qtyDialogProvider.itemOptionsWithout) {
      if (itemOption.selected) customizedItem = true;
    }
    if (!customizedItem) {
      Item existItem = invoice.currentInvoice.itemsList.firstWhere(
          (e) => e.itemCode == widget.itemOfGroup.itemCode,
          orElse: () => null);
      if (existItem == null) {
        Item item = Item().createItem(widget.itemOfGroup,
            itemOptionsWith: qtyDialogProvider.itemOptionsWith,
            itemOptionsWithout: qtyDialogProvider.itemOptionsWithout,
            qty: int.parse(context.read<QtyDialogProvider>().amount));
        invoice.addItem(item);
      } else {}
    } else {
      Item item = Item().createItem(widget.itemOfGroup,
          itemOptionsWith: qtyDialogProvider.itemOptionsWith,
          itemOptionsWithout: qtyDialogProvider.itemOptionsWithout,
          qty: int.parse(context.read<QtyDialogProvider>().amount));
      invoice.addItem(item);
    }
  }

  updateInvoiceRow(Item item) {
    InvoiceProvider invoice = context.read<InvoiceProvider>();
    QtyDialogProvider qtyDialogProvider = context.read<QtyDialogProvider>();
    invoice.updateItemQty(
        item.uniqueId,
        qtyDialogProvider.itemOptionsWith,
        qtyDialogProvider.itemOptionsWithout,
        int.parse(context.read<QtyDialogProvider>().amount));
  }
}
