// import 'package:app/core/enums/enums.dart';
// import 'package:app/db-operations/db.operations.dart';
// import 'package:app/models/profile.details.dart';
// import 'package:app/services/print-service/print.invoice.elements.dart';
// import 'package:flutter/material.dart';

// import '../cache.item.image.service.dart';

// class PrintPage extends StatefulWidget {
//   @override
//   _PrintPageState createState() => _PrintPageState();
// }

// class _PrintPageState extends State<PrintPage> {
//   Future proifleDestailsFuture;
//   ProfileDetails profileDetails;
//   String localPath;

//   Future getData() async {
//     this.profileDetails = await DBProfileDetails().getProfileDetails();
//     this.localPath = await CacheItemImageService().localPath;
//   }

//   @override
//   void initState() {
//     super.initState();
//     this.proifleDestailsFuture = DBProfileDetails().getProfileDetails();
//   }

//   @override
//   Widget build(BuildContext context) {
//     PrintInvoiceElements _printInvoiceElements = PrintInvoiceElements();
//     return Scaffold(
//       body: Center(
//         child: FutureBuilder(
//           future: getData(),
//           builder:
//               (BuildContext context, AsyncSnapshot snapshot) {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
                
//                 _printInvoiceElements.logo(this.profileDetails.posLogo),
//                 _printInvoiceElements.compnayName('COMAPNY NAME'),
//                 _printInvoiceElements.branchName('BRANCH NAME'),
//                 _printInvoiceElements.vatNo('VAT NO'),
//                 _printInvoiceElements.cashierNameAndPostingDate(
//                     'CASHIER NAME', '2021-04-05 10:34:12.885755'),
//                 _printInvoiceElements.invoiceStatusAndOrderType(
//                     DOCSTATUS.PAID, 7),
//                 _printInvoiceElements.customerName('CUSTOMER NAME'),
//                 _printInvoiceElements.orderNo(15),
//                 _printInvoiceElements.tableFotter(true, 15, 100, 1),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
