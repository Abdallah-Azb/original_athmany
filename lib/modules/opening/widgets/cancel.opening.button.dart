import 'package:app/localization/localization.dart';
import 'package:app/modules/opening/provider/new.opening.provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../../core/extensions/widget_extension.dart';
class CancelOpeningButton extends StatelessWidget {
  const CancelOpeningButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          context.read<NewOpeningProvider>().setLoadingValue(true);
          //await AuthRepositoryRefactor().signOut();
          Navigator.pushNamedAndRemoveUntil(
              context, '/opening-list', (route) => false);
        } catch (e, stackTrace) {
          await Sentry.captureException(
            e,
            stackTrace: stackTrace,
          );
          context.read<NewOpeningProvider>().setLoadingValue(false);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: Localization.of(context).locale == Locale('ar', 'SA')
              ? BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
        ),
        alignment: Alignment.center,
        child: Text(Localization.of(context).tr('cancel'),
            style: TextStyle(color: Colors.white, fontSize: 20)).paddingAll(14),
      ),
    );
  }
}
