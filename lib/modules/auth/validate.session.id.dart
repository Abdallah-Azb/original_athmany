import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/auth/repositories/auth.repository.refactor.dart';
import 'package:app/modules/opening/pages/get.opening.details.dart';
import 'package:flutter/material.dart';

import '../../core/utils/const.dart';
import '../../widget/widget/loading_animation_widget.dart';

class ValidateSessionId extends StatefulWidget {
  @override
  _ValidateSessionIdState createState() => _ValidateSessionIdState();
}

class _ValidateSessionIdState extends State<ValidateSessionId> {
  AuthRepositoryRefactor _authRepositoryRefactor = AuthRepositoryRefactor();
  Future validateSessionIdFuture;

  @override
  void initState() {
    super.initState();
    validateSessionIdFuture = _authRepositoryRefactor.validateSessionId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<String>(
          future: validateSessionIdFuture,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return LoadingAnimation(
                typeOfAnimation: "staggeredDotsWave",
                color: themeColor,
                size: 100,
              );
            else if (snapshot.hasError) if (snapshot.error.toString() ==
                "check_your_internet_connection")
              return GetOpeningDetails();
            else
              return LoginPage();
            else if (snapshot.hasData) {
              if (snapshot.data == '')
                return LoginPage();
              else
                return GetOpeningDetails();
            } else
              return LoginPage();
          },
        ),
      ),
    );
  }
}
