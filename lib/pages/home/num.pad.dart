import 'package:app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:provider/provider.dart';

BoxDecoration _boxDecoration = BoxDecoration(
    color: lightGrayColor,
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(color: Colors.black26, width: 1),
    boxShadow: [
      // BoxShadow(
      //   color: Colors.grey.withOpacity(0.1),
      //   spreadRadius: 2.0,
      //   blurRadius: 1.0,
      // )
    ]);

class NumPad extends StatefulWidget {
  String initialAmount;
  final void Function(String amount) getAmount;

  NumPad({
    Key key,
    this.initialAmount = "0",
    this.getAmount,
  }) : super(key: key);

  @override
  _NumPadState createState() => _NumPadState();
}

class _NumPadState extends State<NumPad> {
  String amount;

  @override
  void initState() {
    // amount = widget.initialAmount ?? "0";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // value(),
          _PadRow(
            padWidgets: [number(7), number(8), number(9)],
          ),
          _PadRow(
            padWidgets: [number(4), number(5), number(6)],
          ),
          _PadRow(
            padWidgets: [number(1), number(2), number(3)],
          ),
          _PadRow(
            padWidgets: [number(0), dot(), delete()],
          ),
        ],
      ),
    );
  }

  Widget value() {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Container(
      alignment: Alignment.center,
      width: 300,
      height: 60,
      child: Text(
        widget.initialAmount,
        style: typeMobile == TYPEMOBILE.TABLET
            ? TextStyle(fontSize: 30)
            : TextStyle(fontSize: 20),
      ),
      decoration: BoxDecoration(border: Border.all()),
    );
  }

  // number
  Widget number(int number) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? darkContainerColor : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: isDarkMode ? Colors.white70 : Colors.black26, width: 1),
        ),
        margin: EdgeInsets.all(4),
        alignment: Alignment.center,
        width: typeMobile == TYPEMOBILE.TABLET ? 80 : 50,
        height: typeMobile == TYPEMOBILE.TABLET ? 60 : 40,
        child: Text(
          number.toString(),
          style: typeMobile == TYPEMOBILE.TABLET
              ? TextStyle(
                  fontSize: 30,
                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                )
              : TextStyle(
                  fontSize: 20,
                  color: isDarkMode ? Colors.white : Colors.grey.shade800,
                ),
        ),
      ),
      onTap: () {
        _onNumber(number);
        widget.getAmount(widget.initialAmount);
      },
    );
  }

  // dot
  Widget dot() {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? darkContainerColor : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: isDarkMode ? Colors.white70 : Colors.black26, width: 1),
        ),
        margin: EdgeInsets.all(3),
        alignment: Alignment.center,
        width: typeMobile == TYPEMOBILE.TABLET ? 80 : 50,
        height: typeMobile == TYPEMOBILE.TABLET ? 60 : 40,
        child: Text(
          '.',
          style: typeMobile == TYPEMOBILE.TABLET
              ? TextStyle(
                  fontSize: 30,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                )
              : TextStyle(
                  fontSize: 20,
                  color: isDarkMode ? Colors.white70 : Colors.black,
                ),
        ),
      ),
      onTap: onDot,
    );
  }

  // delete
  Widget delete() {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? darkContainerColor : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: isDarkMode ? Colors.white70 : Colors.black26, width: 1),
        ),
        margin: EdgeInsets.all(3),
        alignment: Alignment.center,
        width: typeMobile == TYPEMOBILE.TABLET ? 80 : 50,
        height: typeMobile == TYPEMOBILE.TABLET ? 60 : 40,
        child: Icon(
          Icons.backspace_outlined,
          color: isDarkMode ? Colors.white70 : Colors.black,
        ),
      ),
      onTap: _onDelete,
    );
  }

  void _onNumber(int number) {
    if (number == 0 && widget.initialAmount == "0") {
      return;
    }
    if (widget.initialAmount.length == 1 &&
        number != 0 &&
        widget.initialAmount == "0") {
      widget.initialAmount = number.toString();
    } else {
      widget.initialAmount = "${widget.initialAmount}${number.toString()}";
    }
    setState(() {});
  }

  void onDot() {
    if (!widget.initialAmount.contains('.')) {
      widget.initialAmount = "${widget.initialAmount}.";
      setState(() {});
      widget.getAmount(widget.initialAmount);
    }
  }

  void _onDelete() {
    widget.initialAmount =
        widget.initialAmount.substring(0, widget.initialAmount.length - 1);
    if (widget.initialAmount.length == 0) widget.initialAmount = "0";
    setState(() {});
    widget.getAmount(widget.initialAmount);
  }
}

class _PadRow extends StatelessWidget {
  final List<Widget> padWidgets;

  const _PadRow({
    Key key,
    this.padWidgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: padWidgets,
    );
  }
}
