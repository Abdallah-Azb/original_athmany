import 'package:app/modules/opening/widgets/start.selling.point.title.dart';
import 'package:flutter/material.dart';
import 'package:nil/nil.dart';

import '../../auth/repositories/auth.repository.refactor.dart';

class NewOpeningHeader extends StatelessWidget {
  final bool goBack;

  const NewOpeningHeader({Key key, this.goBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 50,
            child: goBack != null && !goBack ? const Nil() : BackToOpenings()),
        Expanded(child: StartSellingPointTitle()),
        Container(
          width: 50,
          child: LogOutButton(),
        )
      ],
    );
  }
}

class BackToOpenings extends StatelessWidget {
  const BackToOpenings({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const BackButtonIcon(),
      color: Colors.black,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(
            context, '/opening-list', (route) => false);
      },
    );
  }
}

class LogOutButton extends StatelessWidget {
  const LogOutButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.logout_outlined),
      color: Colors.black,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () async {
        await AuthRepositoryRefactor().signOut();
        Navigator.pushNamedAndRemoveUntil(
            context, '/', (route) => false);
      },
    );
  }
}
