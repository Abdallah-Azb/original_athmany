// import 'package:app/core/utils/utils.dart';
// import 'package:app/db-operations/db.operations.dart';
// import 'package:app/localization/localization.dart';
// import 'package:app/models/models.dart';
// import 'package:app/modules/invoice/invoice.dart';
// import 'package:app/modules/menuItems/menu.item.dart';
// import 'package:app/pages/home/num.pad.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class QtyDialog extends StatefulWidget {
//   final ItemOfGroup itemOfGroup;

//   QtyDialog({this.itemOfGroup});

//   @override
//   _QtyDialogState createState() => _QtyDialogState();
// }

// class _QtyDialogState extends State<QtyDialog> {
//   String amount;
//   String defaultAmount = "0";
//   bool clearTotal = true;
//   List<Item> items;
//   bool itemExist = false;
//   String baseUrl;

//   Future itemOptionsFuture;

//   @override
//   void initState() {
//     super.initState();
//     print(widget.itemOfGroup.itemCode);
//     this.itemOptionsFuture =
//         DBItemOptionsWith().getItemOptionsWith(widget.itemOfGroup.itemCode);
//     items = context.read<InvoiceProvider>().currentInvoice.itemsList;
//     if (items.length > 0) {
//       items.forEach((i) {
//         if (widget.itemOfGroup.itemCode == i.itemCode) {
//           this.itemExist = true;
//         }
//         if (this.itemExist) {
//           Item item = items
//               .firstWhere((e) => e.itemCode == widget.itemOfGroup.itemCode);
//           this.amount = item.qty.toString();
//         } else {
//           amount = "1";
//         }
//       });
//     } else {
//       amount = "1";
//     }

//     getBaseUrl();
//   }

//   Future<void> getBaseUrl() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     baseUrl = prefs.getString('base_url');
//     setState(() {});
//   }

//   void setAmount(String newAmount) {
//     defaultAmount = newAmount;
//     amount = newAmount;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<ItemOptionWith>>(
//       future: itemOptionsFuture,
//       builder:
//           (BuildContext context, AsyncSnapshot<List<ItemOptionWith>> snapshot) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 dialogCalculatorContainer(),
//                 itemOptions(snapshot.data)
//                 // dialoginputContainer()
//               ],
//             ),
//             // submit
//             submit()
//           ],
//         );
//       },
//     );
//   }

//   // item options
//   itemOptions(List<ItemOptionWith> itemOptionsWith) {
//     return Container(
//       padding: EdgeInsets.all(30),
//       height: 580,
//       width: 493,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'الاضافات',
//             style: TextStyle(fontSize: 22),
//           ),
//           SizedBox(
//             height: 50,
//           ),
//           Container(
//             height: 230,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: itemOptionsWith.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return Container(
//                   width: 300,
//                   child: Column(
//                     children: [
//                       chessOption(),
//                       halabinoOption(),
//                       picklesOption(),
//                       ketchupOption()
//                       // CheckboxListTile(
//                       //   title: Text(itemOptionsWith[index].itemName),
//                       //   value: false,
//                       //   onChanged: (newValue) {
//                       //     setState(() {
//                       //       // checkedValue = newValue;
//                       //     });
//                       //   },
//                       //   controlAffinity: ListTileControlAffinity
//                       //       .leading, //  <-- leading Checkbox
//                       // ),
//                     ],
//                   ),
//                 );

//                 // return itemGroupTab(index, widget.itemGroups[index].itemGroup);
//               },
//             ),
//           ),
//           // Divider(color: Colors.black45, thickness: 1,),
//           // Container(
//           //   height: 230,
//           //   child: ListView.builder(
//           //     scrollDirection: Axis.horizontal,
//           //     itemCount: itemOptionsWith.length,
//           //     itemBuilder: (BuildContext context, int index) {
//           //       return Container(
//           //         width: 300,
//           //         child: Column(
//           //           children: [
//           //             CheckboxListTile(
//           //               title: Text(itemOptionsWith[index].itemName),
//           //               value: false,
//           //               onChanged: (newValue) {
//           //                 setState(() {
//           //                   // checkedValue = newValue;
//           //                 });
//           //               },
//           //               controlAffinity:
//           //                   ListTileControlAffinity.leading, //  <-- leading Checkbox
//           //             ),
//           //           ],
//           //         ),
//           //       );

//           //       // return itemGroupTab(index, widget.itemGroups[index].itemGroup);
//           //     },
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }

//   bool chess = false;

//   // option
//   chessOption() {
//     return Transform.scale(
//       scale: 1.2,
//       child: CheckboxListTile(
//         title: Text('إضافة شريحتين جبنة'),
//         value: chess,
//         onChanged: (newValue) {
//           setState(() {
//             chess = newValue;
//           });
//         },
//         controlAffinity:
//             ListTileControlAffinity.leading, //  <-- leading Checkbox
//       ),
//     );
//   }

//   bool pickles = false;

//   // option
//   picklesOption() {
//     return Transform.scale(
//       scale: 1.2,
//       child: CheckboxListTile(
//         title: Text('بدون مخلل'),
//         value: pickles,
//         onChanged: (newValue) {
//           setState(() {
//             pickles = newValue;
//           });
//         },
//         controlAffinity:
//             ListTileControlAffinity.leading, //  <-- leading Checkbox
//       ),
//     );
//   }

//   bool kitchup = false;

//   // option
//   ketchupOption() {
//     return Transform.scale(
//       scale: 1.2,
//       child: CheckboxListTile(
//         title: Text('بدون كاتشاب'),
//         value: kitchup,
//         onChanged: (newValue) {
//           setState(() {
//             kitchup = newValue;
//           });
//         },
//         controlAffinity:
//             ListTileControlAffinity.leading, //  <-- leading Checkbox
//       ),
//     );
//   }

//   bool halapinao = false;

//   // option
//   halabinoOption() {
//     return Transform.scale(
//       scale: 1.2,
//       child: CheckboxListTile(
//         title: Text('إضافة هلابينو'),
//         value: halapinao,
//         onChanged: (newValue) {
//           setState(() {
//             halapinao = newValue;
//           });
//         },
//         controlAffinity:
//             ListTileControlAffinity.leading, //  <-- leading Checkbox
//       ),
//     );
//   }

//   // complete order button
//   Widget submit() {
//     return InkWell(
//       child: Container(
//         height: 75,
//         decoration: BoxDecoration(
//             color: this.amount == "0" ? greyColor : themeColor,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(20),
//               bottomRight: Radius.circular(20),
//             )),
//         padding: EdgeInsets.all(8),
//         alignment: Alignment.center,
//         width: double.infinity,
//         child: Text(
//           Localization.of(context).tr('yes'),
//           style: TextStyle(
//               color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ),
//       onTap: this.amount == "0"
//           ? null
//           : () {
//               if (this.itemExist) {
//                 InvoiceProvider invoice =
//                     Provider.of<InvoiceProvider>(context, listen: false);
//                 invoice.updateItemQty(
//                     widget.itemOfGroup.itemCode, int.parse(amount));
//                 Navigator.pop(context);
//               } else {
//                 addInvoiceRow(widget.itemOfGroup);
//                 Navigator.pop(context);
//               }
//             },
//     );
//   }

//   // add invoice row
//   addInvoiceRow(ItemOfGroup itemOfGroup) {
//     InvoiceProvider invoice =
//         Provider.of<InvoiceProvider>(context, listen: false);
//     Item item = Item().createItem(itemOfGroup, qty: int.parse(amount));
//     invoice.addItem(item);
//   }

//   // dialog calculator container
//   Widget dialogCalculatorContainer() {
//     return Container(
//       padding: EdgeInsets.only(left: 38, right: 38),
//       width: 420,
//       height: 580,
//       color: Colors.black12,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           // SizedBox(
//           //   height: 100,
//           // ),
//           Container(
//             height: 230,
//             child: Flexible(
//               child: Container(
//                 alignment: Alignment.center,
//                 child: MenuItem(
//                   baseUrl: baseUrl,
//                   itemOfGroup: widget.itemOfGroup,
//                 ),
//               ),
//             ),
//           ),
//           dialoginputContainer(),
//           // SizedBox(
//           //   height: 50,
//           // ),
//           // digits()
//           // digitsContainer()
//           SizedBox(
//             height: 20,
//           ),
//           Flexible(
//               child: NumPad(
//             initialAmount: defaultAmount,
//             getAmount: (String value) {
//               setAmount(value);
//             },
//           )),
//         ],
//       ),
//     );
//   }

//   List<Widget> digitsList() {
//     List<Widget> list = [];
//     //i<5, pass your dynamic limit as per your requirment
//     for (int i = 0; i < 11; i++) {
//       if (i == 10) {
//         list.add(Container(
//           child: delete(),
//         ));
//       } else
//         list.add(digit(i));
//       //add any Widget in place of Text("Index $i")
//     }
//     return list; // all widget added now retrun the list here
//   }

//   // digit
//   Widget digit(int index) {
//     return InkWell(
//       child: Container(
//         margin: EdgeInsets.all(3),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//             color: Color.fromARGB(250, 230, 230, 230),
//             border: Border.all(color: Colors.black12)),
//         child: Text(
//           index.toString(),
//           style: TextStyle(
//               color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//       ),
//       onTap: () {
//         onDigitTap(index);
//       },
//     );
//   }

//   // on digit tap
//   onDigitTap(int index) {
//     if (clearTotal) {
//       this.amount = "";
//       clearTotal = false;
//       setState(() {});
//     }
//     if (index == 0) {
//       if (amount != "0") {
//         this.amount = "$amount" + "0";
//         setState(() {});
//       }
//     } else if (index != 10) {
//       if (amount == "0") {
//         this.amount = "$index";
//         setState(() {});
//       } else {
//         if (int.parse("$amount$index") < 1000) this.amount = "$amount$index";
//         setState(() {});
//       }
//     } else if (index == 10) {
//       String lastCharcterOfAmount =
//           (amount.substring(amount.length - 1, amount.length));
//       if (lastCharcterOfAmount != "." && !amount.contains('.')) {
//         this.amount = "$amount.";
//         setState(() {});
//       }
//     }
//   }

//   // calculator
//   Widget digitsContainer() {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: Container(
//         height: 210,
//         child: GridView.count(
//             physics: NeverScrollableScrollPhysics(),
//             childAspectRatio: 1.3,
//             crossAxisCount: 4,
//             scrollDirection: Axis.vertical,
//             children: digitsList()),
//       ),
//     );
//   }

//   Widget delete() {
//     return InkWell(
//       child: Container(
//         margin: EdgeInsets.all(2),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//             color: Colors.red, border: Border.all(color: Colors.black12)),
//         child: Icon(
//           Icons.delete,
//           color: Colors.white,
//         ),
//       ),
//       onTap: () {
//         if (amount.length > 1) {
//           amount = amount.substring(0, amount.length - 1);
//           setState(() {});
//         } else {
//           this.amount = "0";
//           setState(() {});
//         }
//       },
//     );
//   }

//   // dialog input container
//   Widget dialoginputContainer() {
//     return Container(
//       width: 493,
//       height: 50,
//       alignment: Alignment.center,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           increaseQtyBtn(),
//           Container(
//             width: 120,
//             alignment: Alignment.center,
//             child: FittedBox(
//               child: Text(
//                 amount,
//                 maxLines: 1,
//                 style: TextStyle(fontSize: 90, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           decreaseQtyBtn()
//         ],
//       ),
//     );
//   }

//   // increase item qty button
//   Widget increaseQtyBtn() {
//     return Container(
//       alignment: Alignment.center,
//       child: TextButton(
//         onPressed: () {
//           int qty = int.parse(amount);
//           qty += 1;
//           this.amount = qty.toString();
//           setState(() {});
//         },
//         style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all(Color(0xffeaeaea))),
//         child: Text(
//           '+',
//           style: TextStyle(
//               fontSize: 32.0,
//               fontWeight: FontWeight.w100,
//               height: 1.14,
//               color: themeColor),
//         ),
//       ),
//     );
//   }

//   // decrease item qty button
//   Widget decreaseQtyBtn() {
//     return Container(
//       alignment: Alignment.center,
//       child: TextButton(
//         onPressed: () {
//           int qty = int.parse(amount);
//           qty -= 1;
//           if (qty > 0) this.amount = qty.toString();
//           setState(() {});
//         },
//         style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all(Color(0xffeaeaea))),
//         child: Text(
//           '-',
//           style: TextStyle(
//               fontSize: 32.0,
//               fontWeight: FontWeight.w100,
//               height: 1.4,
//               color: Colors.orange),
//         ),
//       ),
//     );
//   }
// }
