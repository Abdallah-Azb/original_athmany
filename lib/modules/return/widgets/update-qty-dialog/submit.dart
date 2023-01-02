import 'package:app/core/utils/const.dart';
import 'package:app/modules/return/return.invoice.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Submit extends StatefulWidget {
  const Submit({Key key}) : super(key: key);

  @override
  _SubmitState createState() => _SubmitState();
}

class _SubmitState extends State<Submit> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      color: themeColor,
      child: TextButton(
          onPressed: () async {
            submit();
          },
          child: Text(
            'Submit',
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
    );
  }

  submit() async {
    int returnQty =
        int.parse(context.read<ReturnUpdateDialogProvider>().amount);
    Navigator.pop(context, returnQty);
  }
}
