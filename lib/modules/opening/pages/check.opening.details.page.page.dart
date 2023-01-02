import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/opening/models/opening.details.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/pages/home/home.dart';
import 'package:flutter/material.dart';

import 'get.openigns.list.dart';

class CheckOpeningDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<OpeningDetails>(
          future: DBOpeningDetails().getOpeningDetails(),
          builder:
              (BuildContext context, AsyncSnapshot<OpeningDetails> snapshot) {
            if (snapshot.hasError) return const SizedBox.shrink();
            OpeningDetails openingDetails = snapshot.data;
            if (openingDetails == null) {
              print("======== details =========");
              return GetOpeningsList();
            }
            if (openingDetails != null) {
              print("======== details 1 =========");
              return Home();
            }
            return Container(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LinearProgressIndicator(),
                  Text("التحقق من وجود نقطة بيع"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
