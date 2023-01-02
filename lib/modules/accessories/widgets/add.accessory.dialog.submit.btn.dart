import 'package:app/core/enums/type_mobile.dart';
import 'package:app/localization/localization.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/utils/const.dart';
import '../../../widget/widget/loading_animation_widget.dart';

class AddAccessoryDialogSubmitBtn extends StatelessWidget {
  final VoidCallback onSave;
  final bool submissionInProgress;

  const AddAccessoryDialogSubmitBtn({
    Key key,
    this.onSave,
    this.submissionInProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 60.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                        ),
                      ),
                    ),
                    onPressed: onSave,
                    child: submissionInProgress
                        ? LoadingAnimation(
                            typeOfAnimation: "horizontalRotatingDots",
                            color: Colors.white,
                            size: 70,
                          )
                        : Text(Localization.of(context).tr('save'),
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 60.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(15.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(Localization.of(context).tr('cancel'),
                        style: Theme.of(context).textTheme.headline5.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          )
        // === Mobile ===
        : Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15.0),
                        ),
                      ),
                    ),
                    onPressed: onSave,
                    child: submissionInProgress
                        ? LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.white,
                            size: 70,
                          )
                        : Text(
                            Localization.of(context).tr('save'),
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: 50.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(15.0),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(Localization.of(context).tr('cancel'),
                        style: Theme.of(context).textTheme.headline5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ),
              ),
            ],
          );
  }
}
