import 'package:app/core/utils/session.dart';
import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/auth/validate.session.id.dart';
import 'package:flutter/material.dart';

import '../../core/utils/const.dart';
import '../../widget/widget/loading_animation_widget.dart';

class GetSessionId extends StatefulWidget {
  @override
  _GetSessionIdState createState() => _GetSessionIdState();
}

class _GetSessionIdState extends State<GetSessionId> {
  Session _session = Session();
  Future sessionIdFuture;

  @override
  void initState() {
    super.initState();
    sessionIdFuture = _session.getId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<String>(
          future: sessionIdFuture,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return LoadingAnimation(
                typeOfAnimation: "staggeredDotsWave",
                color: themeColor,
                size: 100,
              );
            else if (snapshot.hasError)
              return Text(snapshot.error.toString());
            else if (snapshot.hasData) {
              if (snapshot.data == '')
                return LoginPage();
              else
                return ValidateSessionId();
            } else
              return LoginPage();
          },
        ),
      ),
    );
  }
}
