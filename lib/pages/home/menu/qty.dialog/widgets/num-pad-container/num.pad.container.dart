import 'package:app/core/enums/type_mobile.dart';
import 'package:app/models/item.of.group.dart';
import 'package:app/modules/menuItems/widgets/menu.item.dart';
import 'package:app/pages/home/menu/qty.dialog/widgets/num-pad-container/num.pad.dart';
import 'package:app/pages/home/menu/qty.dialog/widgets/num-pad-container/qty.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NumPadContainer extends StatefulWidget {
  final ItemOfGroup itemOfGroup;
  final String localPath;
  NumPadContainer({this.itemOfGroup, this.localPath});

  @override
  _NumPadContainerState createState() => _NumPadContainerState();
}

class _NumPadContainerState extends State<NumPadContainer> {
  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            height: 580,
            width: 380,
            padding: EdgeInsets.only(bottom: 26),
            color: Colors.black12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 222,
                    width: 280,
                    child: Container(
                      alignment: Alignment.center,
                      child: MenuItemm(
                        localPath: widget.localPath,
                        itemOfGroup: widget.itemOfGroup,
                      ),
                    )),
                Qty(),
                SizedBox(height: 10),
                QtyDialogNumPad()
              ],
            ))
// mobile
        : Column(
            children: [
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width - 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // NumPad Image
                      Container(
                        height: 120,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: MenuItemm(
                          localPath: widget.localPath,
                          itemOfGroup: widget.itemOfGroup,
                        ),
                      ),

                      Column(
                        children: [
                          // Order Number
                          Qty(),
                          // Numbers
                          QtyDialogNumPad(),
                          SizedBox(height: 15),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}
