import 'package:flutter/material.dart';

class ReturnInvoiceName extends StatelessWidget {
  final name;
  ReturnInvoiceName(this.name);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      alignment: Alignment.center,
      child: Text(
        this.name,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
