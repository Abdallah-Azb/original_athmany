import 'package:app/models/models.dart';
import 'package:app/pages/home/menu/qty.dialog/qty.dialog.refactor.dart';
import 'package:flutter/material.dart';

import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:provider/provider.dart';

class QtyDialogWidget extends StatelessWidget {
  final newItem;
  final ItemOfGroup itemOfGroup;

  const QtyDialogWidget({
    Key key,
    this.newItem,
    this.itemOfGroup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)), //this right here
      child: Container(
        width: typeMobile == TYPEMOBILE.TABLET
            ? 913
            : MediaQuery.of(context).size.width,
        height: typeMobile == TYPEMOBILE.TABLET
            ? 655
            : MediaQuery.of(context).size.height,
        child: QtyDialogRefactor(
          newItem: newItem,
          itemOfGroup: itemOfGroup,
        ),
        // child: QtyDialog(
        //   itemOfGroup: itemOfGroup,
        // ),
      ),
    );
  }
}
