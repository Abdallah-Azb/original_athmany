import 'dart:async';
import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/opening/pages/invalid.opening.page.dart';
import 'package:app/modules/opening/provider/new.opening.provider.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:app/pages/home/home.dart';
import 'package:app/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../core/extensions/widget_extension.dart';
class CreateOpeningButtion extends StatefulWidget {
  @override
  _CreateOpeningButtionState createState() => _CreateOpeningButtionState();
}

class _CreateOpeningButtionState extends State<CreateOpeningButtion> {
  @override
  Widget build(BuildContext context) {
    return createButton();
  }

  // create button
  Widget createButton() {
    NewOpeningProvider newOpeningProvider = context.read<NewOpeningProvider>();
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: newOpeningProvider.openingBalanceList.length == 0
              ? Colors.black26
              : themeColor,
          borderRadius: Localization.of(context).locale == Locale('ar', 'SA')
              ? BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )
              : BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
        ),
        alignment: Alignment.center,
        child: Text(
          Localization.of(context).tr('create'),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ).paddingAll(14),
      ),
      onTap: newOpeningProvider.selectedProfile == null
          ? null
          : () async {
              newOpeningProvider.setLoadingValue(true);
              submit();
            },
    );
  }

  submit() async {
    NewOpeningProvider newOpeningProvider = context.read<NewOpeningProvider>();
    newOpeningProvider.setLoadingValue(true);
    try {
      await OpeningRepositoryRefactor().createNewOpening(
          newOpeningProvider.selectedCompany,
          newOpeningProvider.selectedProfile,
          newOpeningProvider.openingBalanceList);
      InvalidOpeningDetails invalidOpeningDetails =
          await OpeningRepositoryRefactor()
              .validateOpening(newOpeningProvider.selectedProfile.value);
      if (invalidOpeningDetails.invalidData.firstWhere(
              (e) => e.invalidItems.length > 0,
              orElse: () => null) !=
          null) {
        await DBService().dropTablesForSync(db, deleteOpeningDetails: true);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                InvalidOpeningPage(
                    invalidOpeningDetails: invalidOpeningDetails),
            transitionDuration: Duration.zero,
          ),
        );
      } else
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Home(),
            transitionDuration: Duration.zero,
          ),
        );
    } on Failure catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      toast(e.message, Colors.red);
    } finally {
      newOpeningProvider.setLoadingValue(false);
    }
  }

  // submit() async {
  //   NewOpeningProvider newOpeningProvider = context.read<NewOpeningProvider>();
  //   newOpeningProvider.setLoadingValue(true);
  //   try {
  //     List<String> invalidMessages = await ApiService()
  //         .checkPosProfileDetails(newOpeningProvider.selectedProfile);
  //     if (invalidMessages.length > 0)
  //       showIvnalidMessageDialog(invalidMessages);
  //     else {
  //       OpeningDetails openingDetails = await OpeningService()
  //           .createOpeningVoucher(
  //               newOpeningProvider.selectedCompany,
  //               newOpeningProvider.selectedProfile,
  //               newOpeningProvider.openingBalanceList);
  //       if (openingDetails != null) {
  //         await OpeningService().saveOpeningDetailsToSqlite(openingDetails);
  //         await OpeningRepository().handleOpening(
  //             newOpeningProvider.selectedProfile,
  //             newOpeningProvider.selectedCompany);
  //         newOpeningProvider.setLoadingValue(false);
  //         // await OpeningRepository().validateOpening(openingDetails.profile);
  //         InvalidOpeningDetails invalidOpeningDetails =
  //             await OpeningRepositoryRefactor()
  //                 .validateOpening(openingDetails.profile);
  //         if (invalidOpeningDetails.invalidData.firstWhere(
  //                 (e) => e.invalidItems.length > 0,
  //                 orElse: () => null) !=
  //             null) {
  //           await DBService().dropTablesForSync(db, deleteOpeningDetails: true);
  //           Navigator.pushReplacementNamed(context, '/invalid-opening',
  //               arguments: invalidOpeningDetails);
  //         } else
  //           Navigator.pushNamedAndRemoveUntil(
  //               context, '/home', (route) => false);
  //       }
  //     }
  //   } on Failure catch (e) {
  //     toast(e.message, Colors.red);
  //   } finally {
  //     newOpeningProvider.setLoadingValue(false);
  //   }
  // }

  Future showIvnalidMessageDialog(List<String> invalidMessages) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          showCancelBtn: false,
          opengingWarningDialog: true,
          messages: invalidMessages,
          onConfirm: () async {
            Navigator.pop(context);
            context.read<NewOpeningProvider>().setLoadingValue(false);
            setState(() {});
          },
        );
      },
    );
  }
}
