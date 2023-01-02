import 'package:app/modules/opening/models/opening.details.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/modules/opening/pages/openings.list.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/utils/const.dart';
import '../../../widget/widget/loading_animation_widget.dart';

class GetOpeningsList extends StatefulWidget {
  @override
  _GetOpeningsListState createState() => _GetOpeningsListState();
}

class _GetOpeningsListState extends State<GetOpeningsList> {
  Future openingListFuture;
  OpeningRepositoryRefactor _openingRepositoryRefactor =
      OpeningRepositoryRefactor();

  @override
  void initState() {
    super.initState();
    openingListFuture = _openingRepositoryRefactor.getOpeningList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<OpeningDetails>>(
            future: openingListFuture,
            builder: (BuildContext context,
                AsyncSnapshot<List<OpeningDetails>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingAnimation(
                  typeOfAnimation: "staggeredDotsWave",
                  color: themeColor,
                  size: 100,
                );
              } else if (snapshot.hasError) {
                if (snapshot.error.toString() ==
                    "check_your_internet_connection") {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Please make sure you have internet connection"),
                      TextButton(
                        child: Text("Try Again"),
                        onPressed: () {
                          Phoenix.rebirth(context);
                        },
                      )
                    ],
                  );
                }
                return Text(snapshot.error.toString());
              }
              if (snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  return OpeningsListPage(
                    openingDetailsList: snapshot.data,
                  );
                }
                if (snapshot.data.length == 0) {
                  return NewOpeningPage(false);
                }
              }
              return LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 70,
              );
            }),
      ),
    );
  }
}
