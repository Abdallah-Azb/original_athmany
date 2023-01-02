// import 'package:app/utilities/const.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class PayDialog extends StatefulWidget {
//   @override
//   _PayDialogState createState() => _PayDialogState();
// }

// class _PayDialogState extends State<PayDialog> {
//   Future<List<PaymentMethod>> paymentMethodsFuture;
//   List<PaymentMethod> paymentMethos = [];
//   // InvoiceModel invoiceModel;

//   @override
//   void initState() {
//     // invoiceModel = context.read<InvoiceModel>();
//     paymentMethodsFuture = getPaymentMethods();
//     // DatabasePaymentOperations.getAllPaymentMethods()
//     //     .then((value) => {print(value[0].account)});
//     super.initState();
//   }

//   // get payment methods
//   Future<List<PaymentMethod>> getPaymentMethods() async {
//     // this.paymentMethos = await DatabasePaymentOperations.getAllPaymentMethods();
//     // this.paymentMethos.firstWhere((e) => e.defaultPaymentMode == 1).amount =
//     //     Provider.of<InvoiceModel>(context, listen: false).total;
//     // this.paymentMethos.where((e) => e.defaultPaymentMode == 0).forEach((p) {
//     //   p.amount = 0;
//     // });
//     // setState(() {});
//     // return this.paymentMethos;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<PaymentMethod>>(
//         future: paymentMethodsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(child: Text(snapshot.error.toString()));
//           }
//           if (snapshot.hasData) {
//             // print(snapshot.data[1].icon);
//             // return Container();
//             return page(snapshot.data);
//           }
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         });
//   }

//   // page
//   Widget page(List<PaymentMethod> paymentMethods) {
//     // print(paymentMethods);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [dialogCalculatorContainer(), dialoginputContainer()],
//         ),
//         // submit
//         submit()
//       ],
//     );
//   }

//   // dialog input container
//   Widget dialoginputContainer() {
//     return Container(
//       padding: EdgeInsets.only(left: 40, right: 40, top: 80),
//       width: 493,
//       height: 580,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//         topRight: Radius.circular(20),
//       )),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//               child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               paymentMethodsRow(),
//               // SizedBox(height: 12),
//               inputContainer(),
//             ],
//           )),
//           paymentsTable(),
//           SizedBox(
//             height: 23,
//           )
//         ],
//       ),
//     );
//   }

//   // payment methods row
//   Widget paymentMethodsRow() {
//     return Row(
//       children: [
//         for (int i = 0; i < this.paymentMethos.length; i++)
//           paymentMethodButton(i),
//       ],
//     );
//   }

//   // payment method button
//   Widget paymentMethodButton(int i) {
//     return Container(
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(12)),
//           border: paymentMethos[i].defaultPaymentMode == 1
//               ? Border.all(color: themeColor, width: 2)
//               : Border.all(color: Colors.transparent, width: 2)),
//       margin: EdgeInsets.all(6),
//       child: TextButton(
//         style: ButtonStyle(
//             overlayColor: MaterialStateProperty.all<Color>(themeColor),
//             backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
//             shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                 RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.0),
//             ))),
//         child: paymentMethos[i].icon == null
//             ? Text(
//                 paymentMethos[i].modeOfPayment,
//                 style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold),
//               )
//             // : Text('dsfdf'),
//             : Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: NetworkImage(
//                         "http://athmanytec.alfahhad.net/${paymentMethos[i].icon}"),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),
//         onPressed: () {
//           this.amount = "";
//           setState(() {});
//           this
//               .paymentMethos
//               .firstWhere((e) => e.defaultPaymentMode == 1)
//               .defaultPaymentMode = 0;
//           paymentMethos[i].defaultPaymentMode = 1;
//           setState(() {});
//         },
//       ),
//     );
//   }

//   // input container
//   Widget inputContainer() {
//     return Container(
//       padding: EdgeInsets.only(left: 10),
//       alignment: Alignment.centerLeft,
//       width: 390,
//       height: 54,
//       decoration: BoxDecoration(
//           border: Border.all(color: Colors.black38, width: 2),
//           borderRadius: BorderRadius.circular(10)),
//       child: Text(
//         amount == ""
//             ? this
//                 .paymentMethos
//                 .firstWhere((e) => e.defaultPaymentMode == 1)
//                 .amount
//                 .toString()
//             : amount,
//         // amount,
//         style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   // payments table
//   Widget paymentsTable() {
//     return Table(
//       border: TableBorder.all(color: Colors.black26),
//       columnWidths: {0: FlexColumnWidth(0.25)},
//       children: [
//         for (int i = 0; i < this.paymentMethos.length; i++)
//           TableRow(children: [
//             TableCell(
//               verticalAlignment: TableCellVerticalAlignment.middle,
//               // child: Container(
//               //   child: Image.network(
//               //       'https://mostaql.hsoubcdn.com/uploads/199225-gKhkl-1565639861-5d51c4b57d775.jpg'),
//               // ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: paymentMethos[i].icon == null
//                     ? Text(paymentMethos[i].modeOfPayment)
//                     // : Text('asdf'),
//                     : Image.network(
//                         "http://athmanytec.alfahhad.net/${paymentMethos[i].icon}"),
//                 // : Image.asset(paymentMethos[i].icon, height: 22),
//               ),
//             ),
//             TableCell(
//                 verticalAlignment: TableCellVerticalAlignment.middle,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     this.paymentMethos[i].amount.toString(),
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ))
//           ])
//       ],
//     );
//   }

//   //////////////////////////////////////////
//   ///
//   ///
//   ///
//   ///
//   ///
//   ///
//   ///
//   // dialog calculator container
//   Widget dialogCalculatorContainer() {
//     double totalPaid = 0.0;
//     this.paymentMethos.forEach((p) {
//       totalPaid += p.amount;
//     });
//     return Container(
//       padding: EdgeInsets.only(top: 124, left: 38, right: 38),
//       width: 420,
//       height: 580,
//       color: Colors.black12,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // total
//           Row(
//             children: [
//               Container(
//                 width: 143,
//                 child: Text(
//                   'Total',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Container(
//                 width: 20,
//                 child: Text(
//                   ':',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Text(
//                 invoiceModel.total.toString(),
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           // paid
//           Row(
//             children: [
//               Container(
//                 width: 143,
//                 child: Text(
//                   'Paid',
//                   style: TextStyle(fontSize: 24),
//                 ),
//               ),
//               Container(
//                 width: 20,
//                 child: Text(
//                   ':',
//                   style: TextStyle(fontSize: 24),
//                 ),
//               ),
//               Text(
//                 totalPaid.toString(),
//                 style: TextStyle(fontSize: 24),
//               ),
//             ],
//           ),
//           // change
//           Row(
//             children: [
//               Container(
//                 width: 143,
//                 child: Text(
//                   'Change',
//                   style: TextStyle(fontSize: 24),
//                 ),
//               ),
//               Container(
//                 width: 20,
//                 child: Text(
//                   ':',
//                   style: TextStyle(fontSize: 24),
//                 ),
//               ),
//               Text(
//                 ((this.invoiceModel.total - totalPaid).toString()),
//                 style: TextStyle(fontSize: 24),
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 100,
//           ),
//           // digits()
//           digitsContainer()
//         ],
//       ),
//     );
//   }

// /////////////////////////////////
//   ///
//   ///
//   ///
//   List<Widget> digitsList() {
//     List<Widget> list = List();
//     //i<5, pass your dynamic limit as per your requirment
//     for (int i = 0; i < 12; i++) {
//       if (i == 11) {
//         list.add(Container(
//           height: 10,
//           width: 10,
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
//           index == 10 ? '.' : index.toString(),
//           style: TextStyle(
//               color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//       ),
//       onTap: () {
//         onDigitTap(index);
//       },
//     );
//   }

//   bool clearTotal = true;
//   String amount = "";
//   // on digit tap
//   onDigitTap(int index) {
//     if (clearTotal) {
//       amount = "";
//       clearTotal = false;
//       setState(() {});
//     }
//     if (index == 0) {
//       if (amount != "0") {
//         amount = "$amount" + "0";
//         setState(() {});
//       }
//     } else if (index != 10) {
//       if (amount == "0") {
//         amount = "$index";
//         setState(() {});
//       } else {
//         amount = "$amount$index";
//         print(index.toString());
//         setState(() {});
//       }
//     } else if (index == 10) {
//       String lastCharcterOfAmount =
//           (amount.substring(amount.length - 1, amount.length));
//       if (lastCharcterOfAmount != "." && !amount.contains('.')) {
//         amount = "$amount.";
//         setState(() {});
//       }
//     }
//     this.paymentMethos.firstWhere((e) => e.defaultPaymentMode == 1).amount =
//         double.parse(amount);
//     setState(() {});
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

//         this.paymentMethos.firstWhere((e) => e.defaultPaymentMode == 1).amount =
//             double.parse(amount);
//         setState(() {});
//       },
//     );
//   }

//   //////////////////////////////
//   ///
//   ///
//   /// submit
//   // complete order button
//   Widget submit() {
//     return InkWell(
//       child: Container(
//         height: 75,
//         decoration: BoxDecoration(
//             color: themeColor,
//             borderRadius: BorderRadius.only(
//               bottomLeft: Radius.circular(20),
//               bottomRight: Radius.circular(20),
//             )),
//         padding: EdgeInsets.all(8),
//         alignment: Alignment.center,
//         width: double.infinity,
//         child: Text(
//           'Complete order',
//           style: TextStyle(
//               color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ),
//       onTap: () async {
//         await _createInvoice();
//         await sendInvoiceToServer(this.createdInvoiceId);
//         // clear order items
//         Provider.of<ItemsList>(context, listen: false).clear();
//         Navigator.pushReplacementNamed(context, '/invoice');
//       },
//     );
//   }

//   // create invoice
//   _createInvoice() async {
//     await _addInvoice();
//     await _addInvoiceItems();
//     await _addInvoiceTaxes();
//     await _addInvoicePayments();
//   }

// /////////////////////////////////////
//   ///
//   ///
//   ///
//   POSProfileDetails posProfileDetails;
//   int createdInvoiceId;
//   Future<void> _getPOSProfileDetails() async {
//     this.posProfileDetails =
//         await DatabasePOSProfileDetailsOperations.getPOSProfileDetails();
//     setState(() {});
//   }

// //////////////////////////////////////////
//   ///
//   ///
//   ///
//   // add invoice
//   Future _addInvoice() async {
//     List<SalesTaxeDetails> salesTaxeDetailsList =
//         await DatabaseSalesTaxesDetailsOperations.getSalesTaxeDetails();

//     double rate = 0;
//     salesTaxeDetailsList.forEach((e) {
//       rate += e.rate;
//     });

//     await _getPOSProfileDetails();
//     final prefs = await SharedPreferences.getInstance();
//     ItemsList itemsList = Provider.of<ItemsList>(context, listen: false);
//     double total = 0;
//     itemsList.getItems.forEach((item) {
//       double itemTotal = item.price * item.qty;
//       total += itemTotal;
//     });

//     double baseNetTotal = total;
//     double baseGrandTotal = total + (total / 100) * rate;
//     double grandTotal = total + (total / 100) * rate;

//     final InvoiceModel invoiceModel = InvoiceModel(
//         docstatus: 1,
//         namingSeries: 'ACC-PSINV-.YYYY.-',
//         posProfile: this.posProfileDetails.name,
//         customer: this.posProfileDetails.customer,
//         costCenter: this.posProfileDetails.costCenter,
//         isPos: 1,
//         company: this.posProfileDetails.company,
//         postingDate: DateTime.now().toString(),
//         currency: this.posProfileDetails.currency,
//         sellingPriceList: this.posProfileDetails.sellingPriceList,
//         priceListCurrency: this.posProfileDetails.currency,
//         conversionRate: 1,
//         plcConversionRate: 1,
//         baseNetTotal: baseNetTotal,
//         baseGrandTotal: baseGrandTotal,
//         grandTotal: grandTotal,
//         debitTo: prefs.getString('debit_to') // from get company
//         );
//     this.createdInvoiceId =
//         await DatabaseInvoiceOperations.addInvoice(invoiceModel);
//     setState(() {});
//     // print('created invoice id is ${this.createdInvoiceId}');
//   }

//   ///////////////////////////////////////
//   ///
//   ///
//   /// add invoice items
//   Future<void> _addInvoiceItems() async {
//     List<SalesTaxeDetails> salesTaxeDetailsList =
//         await DatabaseSalesTaxesDetailsOperations.getSalesTaxeDetails();

//     double rate = 0;
//     salesTaxeDetailsList.forEach((e) {
//       rate += e.rate;
//     });

//     ItemsList itemsList = Provider.of<ItemsList>(context, listen: false);
//     itemsList.getItems.forEach((i) async {
//       Item item = Item(
//           invoiceId: this.createdInvoiceId,
//           uom: i.uom,
//           stockUom: i.stockUom,
//           code: i.code,
//           name: i.name,
//           conversionFactor: i.conversionFactor,
//           descriptionSection: i.descriptionSection,
//           qty: i.qty,
//           rate: i.rate,
//           amount: ((i.price * i.qty) / 100) * rate,
//           baseRate: i.baseRate,
//           baseAmount: ((i.price * i.qty) / 100) * rate,
//           warehouse: this.posProfileDetails.warehouse,
//           incomeAccount: this.posProfileDetails.incomeAccount,
//           costCenter: this.posProfileDetails.costCenter);

//       print(item.toMap());
//       int createdItemId = await DatabaseItemOperations.addItem(item);
//       print('created createdItemId id is $createdItemId');
//     });
//   }

//   ///////////////////////////////////////
//   ///
//   ///
//   /// add invoice taxes
//   Future<void> _addInvoiceTaxes() async {
//     ItemsList itemsList = Provider.of<ItemsList>(context, listen: false);
//     double total = 0;
//     itemsList.getItems.forEach((item) {
//       double itemTotal = item.price * item.qty;
//       total += itemTotal;
//     });

//     List<SalesTaxeDetails> salesTaxeDetailsList =
//         await DatabaseSalesTaxesDetailsOperations.getSalesTaxeDetails();

//     double rate = 0;
//     salesTaxeDetailsList.forEach((e) {
//       rate += e.rate;
//     });

//     print(rate);

//     Tax tax = Tax(
//         invoiceId: this.createdInvoiceId,
//         chargeType: salesTaxeDetailsList[0].chargeType,
//         accountHead: salesTaxeDetailsList[0].accountHead,
//         description: salesTaxeDetailsList[0].description,
//         rate: rate,
//         taxAmount: (total / 100) * rate,
//         total: total + (total / 100) * rate,
//         taxAmountAfterDiscountAmount: (total / 100) * rate,
//         baseTaxAmount: (total / 100) * rate,
//         baseTotal: total + (total / 100) * rate,
//         baseTaxAmountAfterDiscountAmount: (total / 100) * rate,
//         costCenter: this.posProfileDetails.costCenter);

//     print('tax map is ${tax.toMap()}');

//     int createdTaxId = await DatabaseTaxOperations.addTax(tax);
//     print('created createdTaxId id is $createdTaxId');
//   }

//   ///////////////////////////////////////
//   ///
//   ///
//   /// add invoice payments
//   Future<void> _addInvoicePayments() async {
//     paymentMethos.forEach((p) async {
//       PaymentMethod paymentMethod = PaymentMethod(
//           invoiceId: createdInvoiceId,
//           defaultPaymentMode: p.defaultPaymentMode,
//           modeOfPayment: p.modeOfPayment,
//           amount: p.amount,
//           // TODO: fix account
//           account: p.account,
//           // TODO: fix type
//           type: p.type,
//           baseAmount: p.amount);
//       int createdPaymentId =
//           await DatabasePaymentOperations.addPayment(paymentMethod);
//       print('created createdPaymentId id is $createdPaymentId');
//     });
//   }

//   /////////////////////////////////////////
//   ///
//   ///
//   /// send invoice to server
//   Future<void> sendInvoiceToServer(int invoiceId) async {
//     InvoiceModel invoiceModel =
//         await DatabaseInvoiceOperations.getInvoice(invoiceId);
//     List<Item> invoiceItems =
//         await DatabaseItemOperations.getInvoiceItems(invoiceId);
//     List<Tax> invoiceTaxes =
//         await DatabaseTaxOperations.getInvoiceTaxes(invoiceId);
//     List<PaymentMethod> invoicePayments =
//         await DatabasePaymentOperations.getInvoicePayments(invoiceId);

//     List actualInvoicePayments = [];

//     invoicePayments.forEach((p) {
//       print('this is payment account ${p.account}');
//       dynamic payment = {
//         "default": 1,
//         "mode_of_payment": p.modeOfPayment,
//         "amount": p.amount,
//         // TODO: fix this
//         "account": "Cash - A",
//         // TODO: fix this
//         "type": "Cash",
//         "base_amount": p.baseAmount
//       };
//       actualInvoicePayments.add(payment);
//     });

//     dynamic invoice = {
//       "docstatus": 0,
//       "naming_series": "ACC-PSINV-.YYYY.-",
//       "pos_profile": this.posProfileDetails.name,
//       "customer": this.posProfileDetails.customer,
//       "cost_center": this.posProfileDetails.costCenter,
//       "is_pos": 1,
//       "company": this.posProfileDetails.company,
//       "posting_date": invoiceModel.postingDate,
//       "currency": this.posProfileDetails.currency,
//       "selling_price_list": this.posProfileDetails.sellingPriceList,
//       "price_list_currency": this.posProfileDetails.currency,
//       "conversion_rate": 1,
//       "plc_conversion_rate": 1,
//       "base_net_total": invoiceModel.baseNetTotal,
//       "base_grand_total": invoiceModel.baseGrandTotal,
//       "grand_total": invoiceModel.grandTotal,
//       // TODO: fix this (from company details)
//       "debit_to": "Debtors - A",
//       "items": invoiceItems,
//       "taxes": invoiceTaxes,
//       "payments": actualInvoicePayments
//       // "payments": [
//       //   {
//       //     "default": 1,
//       //     "mode_of_payment": "Cash",
//       //     "amount": 105,
//       //     "account": "Cash - A",
//       //     "type": "Cash",
//       //     "base_amount": 105
//       //   }
//       // ]
//     };
//     print(invoicePayments[0].toJson());
//     dynamic data = await ApiProvider().sendInvoiceToServer(invoice);
//     print(data['name']);
//     await DatabaseInvoiceOperations.updateInvoiceNameFromServer(
//         createdInvoiceId, data['name']);
//   }
// }

// class PaymentMethod {
//   int invoiceId;
//   int defaultPaymentMode;
//   String modeOfPayment;
//   double amount;
//   String account;
//   String type;
//   double baseAmount;
//   String icon;

//   PaymentMethod({
//     this.invoiceId,
//     this.defaultPaymentMode,
//     this.modeOfPayment,
//     this.amount,
//     this.account,
//     this.type,
//     this.baseAmount,
//     this.icon,
//   });

//   Map<String, dynamic> toJson() {
//     var map = <String, dynamic>{
//       'FK_payment_invoice_id': this.invoiceId,
//       'default_payment_mode': this.defaultPaymentMode,
//       'mode_of_payment': this.modeOfPayment,
//       'amount': this.amount,
//       'account': this.account,
//       'type': this.type,
//       'base_amount': this.amount,
//     };
//     return map;
//   }

//   Map<String, dynamic> toMap() {
//     var map = <String, dynamic>{
//       'FK_payment_invoice_id': this.invoiceId,
//       'default_payment_mode': this.defaultPaymentMode,
//       'mode_of_payment': this.modeOfPayment,
//       'amount': this.amount,
//       'account': this.account,
//       'type': this.type,
//       'base_amount': this.baseAmount,
//     };
//     return map;
//   }

//   // from sqlite
//   PaymentMethod.fromJson(Map<String, dynamic> json) {
//     this.defaultPaymentMode = json['default_payment_mode'];
//     this.modeOfPayment = json['mode_of_payment'];
//     this.account = json['account'];
//     this.amount = json['amount'];
//     this.baseAmount = json['base_amount'];
//     this.type = json['type'];
//     this.icon = json['icon'];
//   }
// }
