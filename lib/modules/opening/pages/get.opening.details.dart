import 'package:app/modules/opening/models/opening.details.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:app/pages/home/home.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/const.dart';
import '../../../widget/widget/loading_animation_widget.dart';
import 'get.openigns.list.dart';

class GetOpeningDetails extends StatefulWidget {
  @override
  _GetOpeningDetailsState createState() => _GetOpeningDetailsState();
}

class _GetOpeningDetailsState extends State<GetOpeningDetails> {
  Future openingDetailsFuture;
  OpeningRepositoryRefactor _openingRepositoryRefactor =
      OpeningRepositoryRefactor();
  @override
  void initState() {
    super.initState();
    openingDetailsFuture = _openingRepositoryRefactor.getOpeningDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<OpeningDetails>(
          future: openingDetailsFuture,
          builder:
              (BuildContext context, AsyncSnapshot<OpeningDetails> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingAnimation(
                typeOfAnimation: "staggeredDotsWave",
                color: themeColor,
                size: 100,
              );
            } else if (snapshot.hasError)
              return Text(snapshot.error.toString());
            if (!snapshot.hasData) return GetOpeningsList();
            if (snapshot.hasData) return Home();
            return LoadingAnimation(
              typeOfAnimation: "staggeredDotsWave",
              color: themeColor,
              size: 100,
            );
          },
        ),
      ),
    );
  }
}
