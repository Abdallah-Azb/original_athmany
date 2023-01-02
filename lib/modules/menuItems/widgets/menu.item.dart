import 'dart:io';

import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/enums/doc.status.dart';
import '../../../core/enums/type_mobile.dart';
import '../../../core/utils/const.dart';
import '../../../models/item.of.group.dart';
import '../../../models/models.dart';
import '../../../providers/type_mobile_provider.dart';
import '../../../res.dart';
import '../../invoice/invoice.dart';
import '../../../core/extensions/widget_extension.dart';
class MenuItemm extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ItemOfGroup itemOfGroup;
  final String baseUrl;
  final String localPath;

  MenuItemm(
      {this.itemOfGroup,
      this.onTap,
      this.onLongPress,
      this.baseUrl,
      this.localPath});

  @override
  _MenuItemmState createState() => _MenuItemmState();
}

class _MenuItemmState extends State<MenuItemm> with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 80),
      value: 1.0,
      lowerBound: 1.0,
      upperBound: 1.1,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  void _anmiateItem() {
    _animationController.forward().then((value) {
      _animationController.reverse().then((value) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return menuItemContainer();
  }

  // menu item container
  Widget menuItemContainer() {
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: true);
    bool itemExist = false;

    invoice.currentInvoice.itemsList.forEach((i) {
      if (widget.itemOfGroup.itemCode == i.itemCode) {
        itemExist = true;
      }
    });
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return typeMobile == TYPEMOBILE.TABLET
        ? ScaleTransition(
            scale: _animationController,
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: itemExist
                            ? themeColor
                            : isDarkMode == false
                                ? Colors.white
                                : darkContainerColor,
                        width: itemExist ? 5 : 5),
                    color:
                        isDarkMode == false ? Colors.white : darkContainerColor,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode == false
                            ? Colors.grey.withOpacity(0.5)
                            : Color(0xff1F1F1F),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(16.0)),
                margin: EdgeInsets.all(20),
                // width: 220,
                // height: 192,
                child: Column(
                  children: [
                    // item image
                    Expanded(child: image()),
                    Row(
                      children: [
                        // item name
                        name(),
                        SizedBox(
                          width: 3,
                        ),
                        // item price
                        price()
                      ],
                    ).paddingAll(6),
                  ],
                ),
              ),
              onTap: widget.onTap != null &&
                      invoice.currentInvoice.docStatus != DOCSTATUS.PAID
                  ? () {
                      _anmiateItem();
                      widget.onTap();
                    }
                  : null,
              onLongPress: invoice.currentInvoice.docStatus != DOCSTATUS.PAID
                  ? widget.onLongPress
                  : () {},
            ),
          )
        // mobile
        : ScaleTransition(
            scale: _animationController,
            child: InkWell(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: itemExist
                        ? themeColor
                        : isDarkMode == false
                            ? Colors.white
                            : darkContainerColor,
                    width: itemExist ? 3 : 3,
                  ),
                  color:
                      isDarkMode == false ? Colors.white : darkContainerColor,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode == false
                          ? Colors.grey.withOpacity(0.5)
                          : Color(0xff1F1F1F),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                margin: EdgeInsets.all(4),
                child: Column(
                  children: [
                    // item image
                    Expanded(child: image()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // item name
                        name(size: 12.0),
                        // item price
                        price(size: 12.0),
                      ],
                    ).paddingHorizontally(7.5)
                  ],
                ),
              ),
              onTap: widget.onTap != null &&
                      invoice.currentInvoice.docStatus != DOCSTATUS.PAID
                  ? () {
                      _anmiateItem();
                      widget.onTap();
                    }
                  : null,
              onLongPress: invoice.currentInvoice.docStatus != DOCSTATUS.PAID
                  ? widget.onLongPress
                  : () {},
            ),
          );
  }

  // item image
  Widget image() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
        image: DecorationImage(
            fit: BoxFit.fill,
            image: widget.itemOfGroup.itemImage == 'null' ||
                    widget.itemOfGroup.itemImage == ''
                ? AssetImage(
                    'assets/no-image.png',
                  )
                : FileImage(File(
                    '${widget.localPath}/${widget.itemOfGroup.itemCode}.png'))
            // Image.file(
            //     File('${widget.localPath}/${widget.itemOfGroup.itemImage}'),
            //     // scale: 1,
            //     width: 320,
            //     // height: 200,
            //   )
            //     : CachedNetworkImageProvider(
            //         "${widget.baseUrl}/" + widget.itemOfGroup.itemImage),
            // fit: BoxFit.fill,
            // fit: widget.item.imageLocalPath == "" ? BoxFit.contain : BoxFit.fill,
            ),
      ),
      // child: image == null ? noImage() : Image.network(image),
      // height: 134,
    );
  }

  // item name
  Widget name({size = 16.0}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Expanded(
        // item name
        child: Text(
      widget.itemOfGroup.itemName,
      maxLines: 1,
      style: TextStyle(
        fontSize: 16,
        color: isDarkMode == false ? darkContainerColor : Colors.white,
      ),
    ));
  }

  // item price
  Widget price({size = 16.0}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Text(
      widget.itemOfGroup.priceListRate.toString(),
      style: TextStyle(
        fontSize: 16,
        color: isDarkMode == false ? darkContainerColor : Colors.white,
      ),
    );
  }
}
