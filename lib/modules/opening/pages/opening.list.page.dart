// import 'package:app/core/utils/utils.dart';
// import 'package:app/localization/localization.dart';
// import 'package:app/modules/opening/provider/opening.provider.dart';
// import 'package:flutter/material.dart';
// import 'package:loading_overlay/loading_overlay.dart';
// import 'package:provider/provider.dart';

// import '../opening.dart';

// class OpeningListPage extends StatefulWidget {
//   const OpeningListPage({Key key}) : super(key: key);

//   @override
//   _OpeningListPageState createState() => _OpeningListPageState();
// }

// class _OpeningListPageState extends State<OpeningListPage> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<OpeningProvider>().getOpenings();
//   }

//   @override
//   Widget build(BuildContext context) {
//     OpeningProvider openingProvider = Provider.of<OpeningProvider>(context);
//     return Scaffold(
//       body: LoadingOverlay(
//         isLoading: openingProvider.loading,
//         child: Center(
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: 100),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 openingProvider.openignsList.length != 0
//                     ? ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: openingProvider.openignsList.length,
//                         itemBuilder: (context, index) {
//                           return OpeningCard(
//                               openingDetails:
//                                   openingProvider.openignsList[index]);
//                         },
//                       )
//                     : const SizedBox.shrink(),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushReplacementNamed(context, '/opening',
//                         arguments: true);
//                   },
//                   child: Text(Localization.of(context).tr('create_new_opening'),
//                       style: TextStyle(color: themeColor, fontSize: 20)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
