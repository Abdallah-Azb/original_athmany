import 'package:app/core/enums/type_mobile.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/invoice/provider/invoice.provider.dart';
import 'package:app/pages/home/menu/qty.dialog/qty.dialog.provider.dart';
import 'package:app/pages/home/menu/qty.dialog/widgets/item.options.list.widget.dart';
import 'package:app/pages/home/menu/qty.dialog/widgets/submit.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/const.dart';
import '../../../../widget/widget/loading_animation_widget.dart';
import 'widgets/num-pad-container/num.pad.container.dart';

class QtyDialogRefactor extends StatefulWidget {
  final bool newItem;
  final ItemOfGroup itemOfGroup;
  QtyDialogRefactor({this.newItem, this.itemOfGroup});

  @override
  _QtyDialogRefactorState createState() => _QtyDialogRefactorState();
}

class _QtyDialogRefactorState extends State<QtyDialogRefactor> {
  Future itemOptionsFuture;
  Item item;
  String localPath;

  Future getItemOptions() async {
    this.localPath = await CacheItemImageService().localPath;
    List<ItemOption> itemOptions =
        await DBItemOptions().getItemOptions(widget.itemOfGroup.itemCode);
    context.read<QtyDialogProvider>().initItemOptions(itemOptions);
    if (!widget.newItem) {
      if (context.read<InvoiceProvider>().currentInvoice.itemsList.length > 0) {
        if (this.item != null) {
          for (ItemOption itemOption in this.item.itemOptionsWith) {
            context
                .read<QtyDialogProvider>()
                .updateItemOptionWithStatus(itemOption, itemOption.selected);
          }
          for (ItemOption itemOption in this.item.itemOptionsWithout) {
            context
                .read<QtyDialogProvider>()
                .updateItemOptionWithoutStatus(itemOption, itemOption.selected);
          }
        }
      }
    }
    if (widget.newItem)
      context.read<QtyDialogProvider>().setAmount('1');
    else
      context.read<QtyDialogProvider>().setAmount(item.qty.toString());
  }

  @override
  void initState() {
    super.initState();
    this.item = context
        .read<InvoiceProvider>()
        .currentInvoice
        .itemsList
        .firstWhere(
            (e) => e.uniqueId == context.read<QtyDialogProvider>().itemUniqueId,
            orElse: () => null);
    context.read<QtyDialogProvider>().clear();
    this.itemOptionsFuture = getItemOptions();
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return FutureBuilder(
      future: itemOptionsFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasError) {
          return typeMobile == TYPEMOBILE.TABLET
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        NumPadContainer(
                          localPath: this.localPath,
                          itemOfGroup: widget.itemOfGroup,
                        ),
                        ItemOptionsListWidget()
                      ],
                    ),
                    Submit(
                      newItem: widget.newItem,
                      itemOfGroup: widget.itemOfGroup,
                    )
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          NumPadContainer(
                            localPath: this.localPath,
                            itemOfGroup: widget.itemOfGroup,
                          ),
                          Positioned(
                            top: 120,
                            left: 10,
                            right: 10,
                            child: ItemOptionsListWidget(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 15,
                      child: Submit(
                        newItem: widget.newItem,
                        itemOfGroup: widget.itemOfGroup,
                      ),
                    )
                  ],
                );
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
}
