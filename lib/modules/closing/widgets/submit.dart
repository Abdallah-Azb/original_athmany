import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/closing/models.dart/closing.data.dart';
import 'package:app/modules/closing/models.dart/closing_report.dart';
import 'package:app/modules/closing/models.dart/pos.transactions.dart';
import 'package:app/modules/closing/pages/closing_and_printClosing.dart';
import 'package:app/modules/closing/provider/provider.dart';
import 'package:app/modules/closing/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../db-operations/db.opening.details.dart';
import '../../../db-operations/db.profile.details.dart';
import '../../../db-operations/db.user.dart';
import '../../../models/profile.details.dart';
import '../../auth/models/user.dart';
import '../../opening/models/opening.details.dart';
import '../../../core/extensions/widget_extension.dart';

class Submit extends StatefulWidget {
  final ClosingData closingData;
  Submit(this.closingData);
  @override
  _SubmitState createState() => _SubmitState();
}

class _SubmitState extends State<Submit> {
  ClosingProvider closingProvider;
  String closingName;
  ClosingRepository _closingRepository = ClosingRepository();
  @override
  Widget build(BuildContext context) {
    closingProvider = Provider.of<ClosingProvider>(context, listen: true);
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      child: TextButton(
        style: widget.closingData.posTransactions.length > 0 &&
                closingProvider.submit
            ? ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
                backgroundColor: MaterialStateProperty.all(themeColor))
            : ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
                backgroundColor: MaterialStateProperty.all(Colors.black38)),
        child: Text(
          Localization.of(context).tr('close'),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: widget.closingData.posTransactions.length > 0 &&
                closingProvider.submit
            ? () async {
                ProfileDetails posProfileDetails =
                    await DBProfileDetails().getProfileDetails();
                OpeningDetails openingDetails =
                    await DBOpeningDetails().getOpeningDetails();
                User user = await DBUser().getUser();
                closingName = await close();
                ClosingReport closingReport;
                // checking the closing name :
                if (!['', null].contains(closingName))
                  closingReport =
                      await _closingRepository.getClosingStock(closingName);

                widget.closingData.closingReportStock = closingReport;
                print("⚡️⚡⚡️⚡⚡️⚡⚡️⚡⚡️⚡⚡️⚡⚡️⚡⚡️⚡⚡️⚡⚡️⚡⚡️⚡");
                print(closingReport.itemGroup?.length);
                print(closingReport.item?.length);
                await printClosingStock(
                    posProfileDetails, openingDetails, user, context);
              }
            : null,
      ),
    ).paddingHorizontally(15);
  }

  printClosingStock(ProfileDetails posProfileDetails,
      OpeningDetails openingDetails, User user, BuildContext context) async {
    print("hello??");
    await ClosingRepository().printStock(
        context, posProfileDetails, openingDetails, user, widget.closingData);
  }

  close() async {
    String closingName;
    closingName =
        await ClosingRepository().saveClosing(context, widget.closingData);
    print("CLOSING NAME ::: $closingName");
    if (closingName != null) {
      ClosingRepository().signout(context);
      return closingName;
    }
    return null;
  }
}
