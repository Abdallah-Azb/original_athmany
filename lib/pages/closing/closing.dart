// import 'dart:async';
// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_overlay/loading_overlay.dart';
// import 'package:provider/provider.dart';

// import 'package:app/core/utils/utils.dart';
// import 'package:app/db-operations/db.opening.details.dart';
// import 'package:app/db-operations/db.operations.dart';
// import 'package:app/localization/localization.dart';
// import 'package:app/models/models.dart';
// import 'package:app/models/payment.method.dart';
// import 'package:app/modules/auth/auth.dart';
// import 'package:app/modules/header/provider/header.provider.dart';
// import 'package:app/modules/opening/opening.dart';
// import 'package:app/services/api.service.dart';
// import 'package:app/services/cache.item.image.service.dart';

// //  String responseData = 'check in this response message';
// // responseData.contains(new RegExp(r'your-substring', caseSensitive: false));

// // print(responseData.contains(new RegExp(r'response message', caseSensitive: false)));

// class ClosingEntry extends StatefulWidget {
//   @override
//   _ClosingEntryState createState() => _ClosingEntryState();
// }

// class _ClosingEntryState extends State<ClosingEntry> {
//   Future dataFuture;
//   List<PaymentMethod> paymentMethods = [];
//   List<double> paymentMethodsTotalAmounts = [];
//   Future getInvoicesFuture;
//   Session _session = Session();
//   String localPath;
//   GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   List<ModeOfPaymentEntry> enteredValues = [];
//   User user;
//   OpeningDetails openingDetails;
//   ProfileDetails posProfileDetails;
//   dynamic closingData;
//   List<dynamic> updatedPaymentReconciliation = [];
//   TextEditingController _textEditingController = TextEditingController();

//   Future<bool> getData() async {
//     this.user = await DBUser().getSignedInUser();
//     this.openingDetails = await DBOpeningDetails().getOpeningDetails();
//     this.posProfileDetails = await DBProfileDetails().getProfileDetails();
//     this.closingData = await ApiService().getColosingInvoice();

//     this.updatedPaymentReconciliation =
//         this.closingData['payment_reconciliation'];

//     this.updatedPaymentReconciliation.forEach((p) {
//       enteredValues.add(
//         ModeOfPaymentEntry(name: p['mode_of_payment'], value: ''),
//       );
//       p['closing_amount'] = 0.0;
//       p['difference'] = 0.0;
//     });
//     return true;
//   }

//   @override
//   void initState() {
//     this.dataFuture = getData();
//     super.initState();
//     CacheItemImageService().localPath.then((value) => this.localPath = value);
//   }

//   bool pageLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return LoadingOverlay(
//       opacity: 0.3,
//       color: themeColor,
//       isLoading: pageLoading,
//       progressIndicator: CircularProgressIndicator(
//         valueColor: new AlwaysStoppedAnimation<Color>(themeColor),
//         backgroundColor: Colors.white,
//       ),
//       child: Scaffold(
//         backgroundColor: greyColor,
//         body: FutureBuilder<bool>(
//           future: this.dataFuture,
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.hasError) return Container();
//             if (snapshot.hasData) {
//               if (snapshot.data == true) {
//                 return Form(
//                   key: _formKey,
//                   child: page(),
//                 );
//               } else {
//                 return Container();
//               }
//             }
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // page
//   Widget page() {
//     return Column(
//       children: [
//         closing(),
//         Expanded(
//           child: Container(
//             padding: EdgeInsets.all(20),
//             child: ListView(
//               shrinkWrap: true,
//               children: [
//                 firstRow(),
//                 secnodRow(),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 thirdRow(),
//                 fourthRow(),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 fifthRow(),
//                 sixthRow(),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 // invoices table
//                 invoicesTable(),
//                 SizedBox(
//                   height: 30,
//                 ),
//                 // payments table
//                 paymentsTable()
//               ],
//             ),
//           ),
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: SafeArea(
//                   child: TextButton(
//                     style: TextButton.styleFrom(
//                       backgroundColor: themeColor,
//                     ),
//                     child: Text(
//                       Localization.of(context).tr('close'),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onPressed: isBtnValid()
//                         ? () async {
//                             if (_formKey.currentState.validate()) {
//                               await saveClosing();
//                             }
//                           }
//                         : null,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }

//   Future saveClosing() async {
//     if (this.closingData['pos_transactions'].length > 0) {
//       pageLoading = true;
//       setState(() {});
//       Map<String, dynamic> map = {
//         "docstatus": 0,
//         "period_start_date": this.openingDetails.periodStartDate,
//         "period_end_date": DateTime.now().toString(),
//         "posting_date": DateTime.now().toString(),
//         "pos_opening_entry": this.openingDetails.name,
//         "company": this.posProfileDetails.company,
//         "pos_profile": this.posProfileDetails.name,
//         "user": this.user.email,
//         "pos_transactions": closingData['pos_transactions'],
//         "payment_reconciliation": this.updatedPaymentReconciliation,
//         "taxes": closingData['taxes'],
//         "grand_total": closingData['grand_total'],
//         "net_total": closingData['net_total'],
//         "total_quantity": closingData['total_quantity'],
//       };

//       try {
//         OpeningDetails openingDetails =
//             await DBOpeningDetails().getOpeningDetails();
//         if (openingDetails.closingEntryName == null) {
//           dynamic data = await ApiService().saveClosingApi(map);
//           if (data['name'] != null) {
//             await DBOpeningDetails()
//                 .updateClosingEntryName(openingDetails.name, data['name']);
//             await postClosing(data['name']);
//           }
//         } else {
//           await postClosing(openingDetails.closingEntryName);
//         }
//       } on DioError catch (e) {
//         print(e.response.statusCode);
//         print(e.response.data['_error_message']);
//         if (e.error is SocketException || e.error is TimeoutException) {
//           print('check your internet connection');
//         }
//         this.pageLoading = false;
//         setState(() {});
//         if (e.response.statusCode == 403) {
//           showDialog(
//             barrierDismissible: false,
//             context: context,
//             builder: (BuildContext context) {
//               return ConfirmDialog(
//                 showCancelBtn: false,
//                 bodyText: e.response.data['_error_message'],
//                 opengingWarningDialog: false,
//                 onConfirm: () async {
//                   Navigator.pop(context);
//                   pageLoading = false;
//                   setState(() {});
//                 },
//               );
//             },
//           );
//         }
//       } catch (e) {
//         print(e);
//         this.pageLoading = false;
//         setState(() {});
//         toast('Error occured', Colors.red);
//       }
//     }
//   }

//   Future postClosing(String name) async {
//     Map<String, dynamic> map = {
//       "docstatus": 1,
//       "period_start_date": this.openingDetails.periodStartDate,
//       "period_end_date": DateTime.now().toString(),
//       "posting_date": DateTime.now().toString(),
//       "pos_opening_entry": this.openingDetails.name,
//       "company": this.posProfileDetails.company,
//       "pos_profile": this.posProfileDetails.name,
//       "user": this.user.email,
//       "pos_transactions": closingData['pos_transactions'],
//       "payment_reconciliation": this.updatedPaymentReconciliation,
//       "taxes": closingData['taxes'],
//       "grand_total": closingData['grand_total'],
//       "net_total": closingData['net_total'],
//       "total_quantity": closingData['total_quantity'],
//     };

//     try {
//       dynamic data = await ApiService().postClosing(map, name);
//       if (data['name'] != null) {
//         await signout(context);
//         this.pageLoading = false;
//         setState(() {});
//       }
//     } on DioError catch (e) {
//       print(e.response.statusCode);
//       print(e.response.data['_error_message']);
//       print(e.response.data['exc_type']);
//       if (e.error is SocketException || e.error is TimeoutException) {
//         print('check your internet connection');
//       }
//       this.pageLoading = false;
//       setState(() {});
//       if (e.response.statusCode == 403) {
//         showDialog(
//           barrierDismissible: false,
//           context: context,
//           builder: (BuildContext context) {
//             return ConfirmDialog(
//               showCancelBtn: false,
//               bodyText: e.response.data['_error_message'],
//               opengingWarningDialog: false,
//               onConfirm: () async {
//                 Navigator.pop(context);
//                 pageLoading = false;
//                 setState(() {});
//               },
//             );
//           },
//         );
//       }
//       if (e.response.statusCode == 417) {
//         // print(json.decode(e.response.data['_server_messages']));
//         String errorMessage = e.response.data['_server_messages'];
//         bool isValuationRate = errorMessage.contains(
//             new RegExp(r'Valuation Rate for the Item', caseSensitive: false));

//         showDialog(
//           barrierDismissible: false,
//           context: context,
//           builder: (BuildContext context) {
//             return ConfirmDialog(
//               showCancelBtn: false,
//               bodyText: isValuationRate
//                   ? '- Valuation Rate for the Item is missing, \n- Mention Valuation Rate in the Item master.'
//                   // ? e.response.data['_server_messages']
//                   : e.response.data['exc_type'],
//               opengingWarningDialog: false,
//               onConfirm: () async {
//                 Navigator.pop(context);
//                 pageLoading = false;
//                 setState(() {});
//               },
//             );
//           },
//         );
//       }
//     } catch (e) {
//       print(e);
//       this.pageLoading = false;
//       setState(() {});
//       toast('Error occured', Colors.red);
//     }
//   }

//   Future signout(context) async {
//     HeaderProvider headerProvider =
//         Provider.of<HeaderProvider>(context, listen: false);

//     await headerProvider.signout(context);
//   }

//   // first row
//   Widget firstRow() {
//     return Row(
//       children: [
//         title(Localization.of(context).tr('start_date')),
//         title(Localization.of(context).tr('closing_date'))
//       ],
//     );
//   }

//   // second row
//   Widget secnodRow() {
//     DateTime periodStartDate =
//         DateTime.parse(this.openingDetails.periodStartDate);
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         dataContainer(DateFormat('yyyy-MM-dd – kk:mm').format(periodStartDate)),
//         dataContainer(DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()))
//       ],
//     );
//   }

//   // third row
//   Widget thirdRow() {
//     return Row(
//       children: [
//         title(Localization.of(context).tr('publish_date')),
//         title(Localization.of(context).tr('sales_point_closing_date'))
//       ],
//     );
//   }

//   // fourth row
//   Widget fourthRow() {
//     DateTime periodStartDate =
//         DateTime.parse(this.openingDetails.periodStartDate);
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         dataContainer(DateFormat('yyyy-MM-dd – kk:mm').format(periodStartDate)),
//         dataContainer(DateFormat('yyyy-MM-dd – kk:mm').format(periodStartDate))
//       ],
//     );
//   }

//   // fifth row
//   Widget fifthRow() {
//     return Row(
//       children: [
//         title(Localization.of(context).tr('company')),
//         title(Localization.of(context).tr('branch')),
//         title(Localization.of(context).tr('cashier'))
//       ],
//     );
//   }

//   // sixth row
//   Widget sixthRow() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         dataContainer(this.posProfileDetails.company),
//         dataContainer(this.posProfileDetails.name),
//         dataContainer(this.user.fullName)
//       ],
//     );
//   }

//   // title
//   Widget title(String title) {
//     return Expanded(
//       child: Container(
//         margin: EdgeInsets.only(right: 20, left: 20),
//         child: Text(
//           title,
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }

//   // data container
//   Widget dataContainer(String data) {
//     return Expanded(
//         child: Container(
//       alignment: Alignment.center,
//       margin: EdgeInsets.all(6),
//       height: 50,
//       decoration: decoration(),
//       child: Text(
//         data,
//         style: TextStyle(fontSize: 18),
//       ),
//     ));
//   }

//   // closing
//   Widget closing() {
//     return Container(
//         height: 60,
//         alignment: Alignment.center,
//         width: double.infinity,
//         color: Colors.white,
//         child: Text(
//           Localization.of(context).tr('close_sales_point'),
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ));
//   }

//   // opening date text row
//   Widget openingDate() {
//     return Expanded(
//       child: Container(
//           child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             Localization.of(context).tr('start_date'),
//             style: TextStyle(fontSize: 20),
//           ),
//           SizedBox(
//             height: 12,
//           ),
//           Container(
//             padding: EdgeInsets.all(10),
//             decoration: decoration(),
//             child: Text('afddsf'),
//           )
//         ],
//       )),
//     );
//   }

//   // closing date
//   Widget closingDate() {
//     return Expanded(
//       child: Container(
//           child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             Localization.of(context).tr('start_date'),
//             style: TextStyle(fontSize: 20),
//           ),
//           Container(
//             width: 500,
//             padding: EdgeInsets.all(10),
//             decoration: decoration(),
//             child: Text('afddsf'),
//           )
//         ],
//       )),
//     );
//   }

//   BoxDecoration decoration() {
//     return BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.all(Radius.circular(10)));
//   }

//   /////////////////////////////////
//   ///
//   ///
//   /// invoices table
//   Widget invoicesTable() {
//     List<dynamic> invoicesData = this.closingData['pos_transactions'].reversed.toList();
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(width: 1),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10.0),
//         child: Table(
//           columnWidths: {
//             0: FlexColumnWidth(0.2),
//             1: FlexColumnWidth(1),
//             2: FlexColumnWidth(1),
//             3: FlexColumnWidth(1),
//             4: FlexColumnWidth(1),
//           },
//           defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//           children: <TableRow>[
//             TableRow(
//               children: <Widget>[
//                 cell(Localization.of(context).tr('no'), true),
//                 cell(Localization.of(context).tr('invoice'), true),
//                 cell(Localization.of(context).tr('customer'), true),
//                 cell(Localization.of(context).tr('date'), true),
//                 cell(Localization.of(context).tr('amount'), true),
//               ],
//             ),
//             for (int i = 0; i < invoicesData.length; i++)
//               TableRow(
//                 children: <Widget>[
//                   cell((i + 1).toString(), false),
//                   cell(invoicesData[i]['pos_invoice'], false),
//                   cell(invoicesData[i]['customer'], false),
//                   cell(invoicesData[i]['posting_date'], false),
//                   cell(invoicesData[i]['grand_total'].toString(), false),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   /////////////////////////////////
//   ///
//   ///
//   /// payments table
//   Widget paymentsTable() {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border.all(width: 1),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10.0),
//         child: Table(
//           columnWidths: {
//             0: FlexColumnWidth(0.2),
//             1: FlexColumnWidth(1),
//             2: FlexColumnWidth(1),
//             3: FlexColumnWidth(1),
//             4: FlexColumnWidth(1),
//           },
//           defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//           children: <TableRow>[
//             TableRow(
//               children: <Widget>[
//                 cell(Localization.of(context).tr('no'), true),
//                 cell(Localization.of(context).tr('payment_method'), true),
//                 cell(Localization.of(context).tr('amount'), true),
//                 cell(Localization.of(context).tr('closing_amount'), true),
//                 cell(Localization.of(context).tr('different'), true),
//               ],
//             ),
//             for (int i = 0; i < updatedPaymentReconciliation.length; i++)
//               TableRow(
//                 children: <Widget>[
//                   cell((i + 1).toString(), false),
//                   cell(
//                     updatedPaymentReconciliation[i]['mode_of_payment'],
//                     false,
//                     paymentIcon: updatedPaymentReconciliation[i]
//                         ['mode_of_payment'],
//                   ),
//                   cell(
//                       updatedPaymentReconciliation[i]['expected_amount']
//                           .toString(),
//                       false),
//                   cell(
//                     '',
//                     false,
//                     textFormField: textFormField(
//                       updatedPaymentReconciliation[i]['mode_of_payment'],
//                       updatedPaymentReconciliation[i]['expected_amount'],
//                     ),
//                   ),
//                   // cell(updatedPaymentReconciliation[i]['closing_amount'].toString(),
//                   //     false),
//                   cell(
//                       updatedPaymentReconciliation[i]['closing_amount'] == null
//                           ? updatedPaymentReconciliation[i]['expected_amount']
//                               .toString()
//                           : (updatedPaymentReconciliation[i]
//                                       ['expected_amount'] -
//                                   updatedPaymentReconciliation[i]
//                                       ['closing_amount'])
//                               .toString(),
//                       false,
//                       color: differentColor(
//                           updatedPaymentReconciliation[i]['expected_amount'],
//                           updatedPaymentReconciliation[i]['closing_amount'])),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // get differnt color
//   Color differentColor(double expectedAmount, double closingAmount) {
//     if (expectedAmount > closingAmount) {
//       return Colors.red;
//     }
//     if (expectedAmount < closingAmount) {
//       return Colors.blue;
//     }
//     return themeColor;
//   }

//   // table column header
//   Widget cell(String title, bool isHeader,
//       {TextFormField textFormField, String paymentIcon, Color color}) {
//     return TableCell(
//       verticalAlignment: TableCellVerticalAlignment.middle,
//       child: Container(
//         alignment: Alignment.center,
//         height: 55,
//         color: isHeader ? blueGrayColor : Colors.white,
//         child: paymentIcon != null
//             ? Image.file(
//                 File(
//                   '${this.localPath}/${paymentIcon.replaceAll(new RegExp(r"\s+\b|\b\s"), "")}.png',
//                 ),
//                 scale: 10)
//             : textFormField == null
//                 ? text(title, isHeader, color: color == null ? null : color)
//                 : SizedBox(height: 40, child: textFormField),
//       ),
//     );
//   }

//   TextFormField textFormField(String modeOfPayment, double initValue) {
//     return TextFormField(
//       validator: (String value) {
//         if (value != null && value.isNotEmpty) {
//           return null;
//         }

//         return "";
//       },
//       decoration: InputDecoration(
//         hintText: Localization.of(context).tr('enter_closing_amount'),
//         alignLabelWithHint: true,
//         errorStyle: TextStyle(height: 0),
//         contentPadding:
//             EdgeInsets.only(left: 15, bottom: 10, top: 11, right: 15),
//       ),
//       keyboardType: TextInputType.number,
//       inputFormatters: <TextInputFormatter>[
//         FilteringTextInputFormatter.digitsOnly
//       ],
//       textAlign: TextAlign.center,
//       onChanged: (value) {
//         value = value == "" ? "0" : value;
//         Map<String, dynamic> paymentReconciliation = this
//             .updatedPaymentReconciliation
//             .firstWhere((e) => e['mode_of_payment'] == modeOfPayment);
//         paymentReconciliation['closing_amount'] =
//             value.length == 0 ? 0 : double.parse(value);
//         paymentReconciliation['difference'] =
//             paymentReconciliation['expected_amount'] - double.parse(value);
//         ModeOfPaymentEntry entry = enteredValues.firstWhere(
//             (element) => element.name == modeOfPayment,
//             orElse: () => null);

//         if (entry != null) entry.value = value;
//         setState(() {});
//       },
//     );
//   }

//   InputDecoration inputDecoration() {
//     return InputDecoration(
//         border: InputBorder.none,
//         focusedBorder: InputBorder.none,
//         enabledBorder: InputBorder.none,
//         errorBorder: InputBorder.none,
//         disabledBorder: InputBorder.none,
//         contentPadding:
//             EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
//         hintText: "0.0",
//         hintStyle: TextStyle(fontSize: 24, height: 1.1));
//   }

//   Text text(String title, bool isHeader, {Color color}) {
//     return Text(
//       title,
//       style: TextStyle(
//           color: isHeader
//               ? Colors.white
//               : color == null
//                   ? Colors.black
//                   : color,
//           fontSize: 16),
//     );
//   }

//   bool isBtnValid() {
//     List<ModeOfPaymentEntry> modeOfPayment =
//         enteredValues.where((element) => element.value.isEmpty).toList();

//     return modeOfPayment.length == 0;
//   }
// }

// class ModeOfPaymentEntry {
//   String name;
//   String value;

//   ModeOfPaymentEntry({
//     this.name,
//     this.value,
//   });
// }
