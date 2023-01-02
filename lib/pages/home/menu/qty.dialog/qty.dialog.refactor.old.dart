import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:flutter/material.dart';

class QtyDialogRefactor extends StatefulWidget {
  final ItemOfGroup itemOfGroup;
  QtyDialogRefactor({this.itemOfGroup});

  @override
  _QtyDialogRefactorState createState() => _QtyDialogRefactorState();
}

class _QtyDialogRefactorState extends State<QtyDialogRefactor> {
  List<ItemOption> itemOptionsWith = [];
  Future itemOptionsFuture;

  Future<List<ItemOption>> getItemOptions() async {
    this.itemOptionsWith = await DBItemOptions()
        .getItemOptions(widget.itemOfGroup.itemCode);
    return this.itemOptionsWith;
  }

  @override
  void initState() {
    super.initState();
    this.itemOptionsFuture = getItemOptions();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ItemOption>>(
      future: itemOptionsFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<ItemOption>> snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                itemOptions()],
            ),
            // submit
          ],
        );
      },
    );
  }

  // item options
  itemOptions() {
    return Container(
      padding: EdgeInsets.all(30),
      height: 580,
      width: 493,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'الاضافات',
            style: TextStyle(fontSize: 22),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: itemOptionsWith.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 300,
                  child: Column(
                    children: [option(this.itemOptionsWith[index])],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  option(ItemOption itemOption) {
    return CheckboxListTile(
      title: Text(itemOption.itemName),
      value: itemOption.selected,
      onChanged: (newValue) {
        setState(() {
          itemOption.selected = newValue;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    );
  }
}
