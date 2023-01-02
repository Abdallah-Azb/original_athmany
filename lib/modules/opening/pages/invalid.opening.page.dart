import 'package:app/localization/localization.dart';
import 'package:app/modules/auth/repositories/auth.repository.refactor.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:app/modules/opening/repositories/repositories.dart';
import 'package:flutter/material.dart';
import '../../../core/extensions/widget_extension.dart';

class InvalidOpeningPage extends StatelessWidget {
  final InvalidOpeningDetails invalidOpeningDetails;
  const InvalidOpeningPage({Key key, this.invalidOpeningDetails})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(invalidOpeningDetails.profile),
          actions: [
            TextButton(
                onPressed: () async {
                  await AuthRepositoryRefactor().signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                },
                child: Text(
                  Localization.of(context).tr('signout'),
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: Column(
          children: [
            Text(Localization.of(context).tr('failed_opening_message')),
            Expanded(
              child: ListView(
                children: [
                  invalidData(),
                  invalidOpeningDetails.salesTaxesDetails.length > 0
                      ? Text("invalid sales taxes details")
                      : SizedBox.shrink()
                ],
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, "/opening-list", (route) => false);
                },
                child: Text(Localization.of(context).tr('try_again')))
          ],
        ).paddingAll(40));
  }

  Column invalidData() {
    return Column(
      children: [
        for (int i = 0; i < invalidOpeningDetails.invalidData.length; i++)
          invalidOpeningDetails.invalidData[i].invalidItems.length > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invalidOpeningDetails.invalidData[i].title,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    for (int x = 0;
                        x <
                            invalidOpeningDetails
                                .invalidData[i].invalidItems.length;
                        x++)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Text(
                            invalidOpeningDetails.invalidData[i].invalidItems[x],
                            style: TextStyle(fontSize: 20, height: 1.5),
                          ),
                        ],
                      ).paddingHorizontally(8)
                  ],
                )
              : SizedBox.shrink()
      ],
    );
  }
}
