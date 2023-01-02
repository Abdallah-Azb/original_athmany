import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/opening/models/opening.details.dart';
import 'package:app/modules/opening/widgets/opening.card.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import '../../../providers/type_mobile_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/enums/type_mobile.dart';
import '../../../widget/widget/loading_animation_widget.dart';
import '../../../core/extensions/widget_extension.dart';


class OpeningsListPage extends StatefulWidget {
  final List<OpeningDetails> openingDetailsList;
  final Function setLoadingValue;
  const OpeningsListPage(
      {Key key, this.openingDetailsList, this.setLoadingValue})
      : super(key: key);

  @override
  _OpeningsListPageState createState() => _OpeningsListPageState();
}

class _OpeningsListPageState extends State<OpeningsListPage> {
  bool _pageLoading = false;

  // merge ix , they add initState func
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return LoadingOverlay(
      opacity: 0.3,
      color: themeColor,
      isLoading: _pageLoading,
      progressIndicator: LoadingAnimation(
        typeOfAnimation: "staggeredDotsWave",
        color: themeColor,
        size: 100,
      ),
      child: Scaffold(
          backgroundColor: isDarkMode == false ? Colors.white30 : appBarColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 8,
                  // merge ix , they add sizedBox parent ti listview but i didnt
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.openingDetailsList.length,
                    itemBuilder: (context, index) {
                      return OpeningCard(
                          showLoadingOverlay: showLoadingOverlay,
                          openingDetails: widget.openingDetailsList[index]);
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: TextButton(
                    onPressed: () {
                      // merge ix they user pushNamed only for the following
                      Navigator.pushReplacementNamed(context, '/new-opening',
                          arguments: true);
                    },
                    child: Text(
                        Localization.of(context).tr('create_new_opening'),
                        style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                ),
              ],
            ).paddingHorizontallyAndVertical(50, 10) ,
          )),
    );
  }

  void showLoadingOverlay(bool state) {
    this._pageLoading = state;
    setState(() {});
  }
}
