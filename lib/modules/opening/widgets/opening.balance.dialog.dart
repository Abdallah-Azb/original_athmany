import 'package:app/core/utils/const.dart';
import 'package:app/modules/opening/models/opening.payment.method.dart';
import 'package:app/pages/home/num.pad.dart';
import 'package:flutter/material.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/extensions/widget_extension.dart';
class OpeningBalanceDialog extends StatefulWidget {
  final List<OpeningBalance> openingBalanceList;
  final String baseUrl;
  final int tappedRowIndex;

  const OpeningBalanceDialog(
      {Key key, this.openingBalanceList, this.baseUrl, this.tappedRowIndex})
      : super(key: key);
  @override
  _OpeningBalanceDialogState createState() => _OpeningBalanceDialogState();
}

class _OpeningBalanceDialogState extends State<OpeningBalanceDialog> {
  int selectedRow;
  String amount = "0";
  bool clearAmount = true;
  List<OpeningBalance> openingBalanceList;

  @override
  void initState() {
    super.initState();
    this.openingBalanceList = widget.openingBalanceList;
    initialSelectedRow();
  }

  void initialSelectedRow() {
    this.selectedRow = widget.tappedRowIndex;
    if (widget.openingBalanceList[selectedRow].openingAmount != null) {
      amount = this
          .widget
          .openingBalanceList[selectedRow]
          .openingAmount
          .toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return typeMobile == TYPEMOBILE.TABLET
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode == false
                        ? Colors.white
                        : darkBackGroundColor,
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Row(
                    children: [
                      numPad(),
                      Expanded(
                        child: closingAmountInputs(),
                      ),
                    ],
                  ),
                ),
              ),
              completeButton()
            ],
          )
        // == Mobile ===
        : Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDarkMode != true ? Colors.white : Colors.black12,
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                      children: [
                        Expanded(
                          child: closingAmountInputs(),
                        ),
                        numPad(),
                      ],
                    ),
                  ),
                ),
                completeButton()
              ],
            ),
          );
  }

  Widget completeButton() {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return InkWell(
        child: Container(
          decoration: BoxDecoration(
              color: themeColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12))),
          alignment: Alignment.center,
          height: typeMobile == TYPEMOBILE.TABLET ? 64 : 50,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Text(
            'Complete',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          Navigator.pop(context, this.openingBalanceList);
        });
  }

  Widget numPad() {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            color: isDarkMode == false ? Colors.black12 : searchColorDark,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumPad(
                  initialAmount: clearAmount ? "0" : amount,
                  getAmount: (String newAmount) {
                    clearAmount = false;
                    setState(() {});
                    setAmount(newAmount);
                  },
                ),
              ],
            ).paddingHorizontallyAndVertical(40, 80),
          )
        // === Mobile ===
        : Container(
            color: Colors.black12,
            // padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumPad(
                  initialAmount: clearAmount ? "0" : amount,
                  getAmount: (String newAmount) {
                    clearAmount = false;
                    setState(() {});
                    setAmount(newAmount);
                  },
                ),
              ],
            ),
          );
  }

  void setAmount(String updatedAmount) {
    amount = updatedAmount;
    setState(() {});
  }

  Widget closingAmountInputs() {
    return Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int i = 0; i < widget.openingBalanceList.length; i++) row(i)
        ]).paddingAll(20));
  }

  Widget headerColumn(String title) {
    return Expanded(
      child: Container(
        // decoration: boxDecoration(0),
        alignment: Alignment.center,
        child: Text(title),
      ),
    );
  }

  Widget row(int index) {
    return InkWell(
      child: Row(children: [
        modeOfPayment(index),
        closingAmount(index),
      ]),
      onTap: () {
        this.selectedRow = index;
        clearAmount = true;
        setState(() {});
        if (this.widget.openingBalanceList[selectedRow].openingAmount != null) {
          amount = this
              .widget
              .openingBalanceList[selectedRow]
              .openingAmount
              .toStringAsFixed(2);
        } else {
          amount = "0";
        }
        setState(() {});
      },
    );
  }

  Widget closingAmount(int index) {
    OpeningBalance openingBalance = widget.openingBalanceList[index];
    if (selectedRow == index) {
      if (openingBalance.openingAmount == null) {
        openingBalance.openingAmount = 0;
      } else {
        openingBalance.openingAmount = double.parse(amount);
      }
    }
    return Expanded(
      child: Container(
        decoration: boxDecoration(index),
        height: 50,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
        alignment: Alignment.center,
        child: Text(
          openingBalance.openingAmount == null
              ? ""
              : openingBalance.openingAmount.toStringAsFixed(2),
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget modeOfPayment(int index) {
    OpeningBalance openingBalance = widget.openingBalanceList[index];
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;

    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            decoration: boxDecoration(index),
            width: 80,
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: Alignment.center,
            child: openingBalance.icon != '' && openingBalance.icon != null
                ? Image.network("${widget.baseUrl}/${openingBalance.icon}")
                : Text(openingBalance.modeOfPayment),
          )
        // === Mobile ===
        : Container(
            decoration: boxDecoration(index),
            width: 80,
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            padding: EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: openingBalance.icon != '' && openingBalance.icon != null
                ? Image.network("${widget.baseUrl}/${openingBalance.icon}")
                : Text(
                    openingBalance.modeOfPayment,
                    style: TextStyle(fontSize: 13),
                  ),
          );
  }

  BoxDecoration boxDecoration(int rowIndex, {Color color}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return BoxDecoration(
        border: selectedRow == rowIndex
            ? Border.all(color: themeColor, width: 2)
            : Border.all(color: Colors.grey, width: 2),
        color: color == null
            ? isDarkMode == true
                ? darkContainerColor
                : Colors.white
            : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12));
  }
}
