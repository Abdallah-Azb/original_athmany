import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../widget/provider/theme_provider.dart';

class SyncConfirmDialog extends StatefulWidget {
  const SyncConfirmDialog({Key key}) : super(key: key);

  @override
  _SyncConfirmDialogState createState() => _SyncConfirmDialogState();
}

class _SyncConfirmDialogState extends State<SyncConfirmDialog> {
  bool syncWithImages = false;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            padding: EdgeInsets.only(top: 30),
            width: MediaQuery.of(context).size.width * 0.5,
            color: isDarkMode ? appBarColor : Colors.white,
            child: Card(
              margin: EdgeInsets.all(0),
              child: Column(
                children: [
                  Container(
                    color: isDarkMode ? appBarColor : Colors.white,
                    height: 180,
                    child: Column(
                      children: [
                        Image.asset("assets/sync.png"),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          Localization.of(context).tr('sync_confim'),
                          style: TextStyle(fontSize: 24),
                        ),
                        CheckboxListTile(
                          title: Text(
                              Localization.of(context).tr('sync_with_images')),
                          value: syncWithImages,
                          onChanged: (state) {
                            syncWithImages = state;
                            setState(() {});
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Confirm(
                        syncWithImages: syncWithImages,
                      ),
                      Cancel(),
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class Confirm extends StatelessWidget {
  final bool syncWithImages;
  const Confirm({
    Key key,
    this.syncWithImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            Localization.of(context).tr('sync_now'),
            style: TextStyle(color: Colors.white),
          ),
          height: 56,
          width: double.infinity,
          color: themeColor,
        ),
        onTap: () {
          Navigator.pop(context, [true, syncWithImages]);
        },
      ),
    );
  }
}

class Cancel extends StatelessWidget {
  const Cancel({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        child: Container(
          alignment: Alignment.center,
          child: Text(
            Localization.of(context).tr('cancel'),
            style: TextStyle(color: Colors.white),
          ),
          height: 56,
          width: double.infinity,
          color: Colors.black38,
        ),
        onTap: () {
          Navigator.pop(context, [false, false]);
        },
      ),
    );
  }
}
