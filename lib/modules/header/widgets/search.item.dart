import 'dart:async';
import 'package:app/core/utils/const.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/item.of.group.dart';
import 'package:app/modules/invoice/provider/invoice.provider.dart';
import 'package:app/pages/home/num.pad.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class SearchItem extends StatefulWidget {
  @override
  _SearchItemState createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  TextEditingController findItemController = TextEditingController();
  FocusNode findItemFocus;
  Timer _debounce;
  _onSearchChanged(String query) {
    print(query);
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      try {
        if (query.length > 0) {
          ItemOfGroup itemOfGroup =
              await DBItemOfGroup().findItemOfGroup(query);
          if (itemOfGroup != null) {
            // await showQtyDialog(itemOfGroup);
            print(itemOfGroup);
            context.read<InvoiceProvider>().addItemOrUpdateItemQty(itemOfGroup);
            findItemController.text = '';
            findItemFocus.requestFocus();
            print(itemOfGroup.itemName);
          }
        }
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        findItemController.text = '';
        print(e);
        findItemFocus.requestFocus();
        final bool result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmDialog(
                  icon: Image.asset('assets/no-item.png'),
                  bodyText:
                      "${Localization.of(context).tr('item_not_registered_1')} $query ${Localization.of(context).tr('item_not_registered_2')}",
                  onConfirm: () => {Navigator.pop(context, true)});
            });

        if (result == true) {
          showFindItemDialog();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    findItemFocus = FocusNode();
    findItemFocus.requestFocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    findItemFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          color: isDarkMode == true ? darkContainerColor : Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Container(
        width: 360,
        height: 42,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: findItemFocus,
                keyboardType: TextInputType.none,
                // focusNode: AlwaysDisabledFocusNode(),
                controller: findItemController,
                onSubmitted: _onSearchChanged,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: themeColor,
                  ),
                  border: InputBorder.none,
                ),
                cursorHeight: 20,
                cursorColor: themeColor,
                showCursor: false,
                style: TextStyle(
                    height: 1,
                    fontSize: 20,
                    color: isDarkMode == true ? Colors.white : Colors.black),
              ),
            ),
            InkWell(
              child: Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/keyboard.png',
                  color: isDarkMode == false ? Colors.white : themeColor,
                ),
                decoration: BoxDecoration(
                    color: isDarkMode == false ? themeColor : Color(0xff1F1F1F),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                        topRight: Radius.circular(12))),
                height: 54,
                width: 80,
              ),
              onTap: () {
                showFindItemDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  showFindItemDialog() async {
    final String barcode = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: FindItemDialog(),
          );
        });
    if (barcode.length > 0) {
      findItemController.text = barcode;
      _onSearchChanged(barcode);
    }
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class OnScreenKeyboard extends StatefulWidget {
  @override
  _OnScreenKeyboardState createState() => _OnScreenKeyboardState();
}

class _OnScreenKeyboardState extends State<OnScreenKeyboard> {
  String text = '';
  bool shiftEnabled = false;
  bool isNumericMode = false;

  _onKeyPress(VirtualKeyboardKey key) {
    if (key.keyType == VirtualKeyboardKeyType.String) {
      text = text + (shiftEnabled ? key.capsText : key.text);
    } else if (key.keyType == VirtualKeyboardKeyType.Action) {
      switch (key.action) {
        case VirtualKeyboardKeyAction.Backspace:
          if (text.length == 0) return;
          text = text.substring(0, text.length - 1);
          break;
        case VirtualKeyboardKeyAction.Return:
          text = text + '\n';
          break;
        case VirtualKeyboardKeyAction.Space:
          text = text + key.text;
          break;
        case VirtualKeyboardKeyAction.Shift:
          shiftEnabled = !shiftEnabled;
          break;
        default:
      }
    }
    // Update the screen
    setState(() {});
    context.read<FindItemProvider>().setText(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: VirtualKeyboard(
          textColor: Colors.black,
          fontSize: 26,
          // textController: _controllerText,
          //customLayoutKeys: _customLayoutKeys,
          defaultLayouts: [
            VirtualKeyboardDefaultLayouts.English,
            VirtualKeyboardDefaultLayouts.Arabic
          ],
          //reverseLayout :true,
          type: isNumericMode
              ? VirtualKeyboardType.Numeric
              : VirtualKeyboardType.Alphanumeric,
          onKeyPress: _onKeyPress),
    );
  }
}

class FindItemDialog extends StatefulWidget {
  @override
  _FindItemDialogState createState() => _FindItemDialogState();
}

class _FindItemDialogState extends State<FindItemDialog> {
  TextStyle btnTextStyle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

  Expanded _confirmBtn() {
    return Expanded(
      child: Container(
        color: themeColor,
        child: TextButton(
          child: Text(Localization.of(context).tr('yes'), style: btnTextStyle),
          onPressed: () async {
            Navigator.pop(context, context.read<FindItemProvider>().text);
          },
        ),
      ),
    );
  }

  Expanded _cancelBtn(BuildContext context) {
    return Expanded(
      child: Container(
        height: 56,
        color: Colors.grey.withOpacity(0.5),
        child: TextButton(
            child: Text(
              Localization.of(context).tr('cancel'),
              style: btnTextStyle,
            ),
            onPressed: () {
              Navigator.pop(context, "");
            }),
      ),
    );
  }

  String amount = "";
  bool clearAmount = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FindItemProvider>(
      create: (context) => FindItemProvider(),
      child: Consumer<FindItemProvider>(
        builder: (context, model, child) => Container(
            color: Colors.black12,
            width: 913,
            height: 655,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: themeColor, width: 4)),
                  alignment: Alignment.center,
                  height: 68,
                  width: 500,
                  margin: EdgeInsets.only(top: 100),
                  child: Text(
                    context.read<FindItemProvider>().text,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Expanded(child: SizedBox.shrink()),
                // Container(width: 850, child: OnScreenKeyboard()),
                Container(
                  margin: EdgeInsets.all(50),
                  width: 850,
                  child: NumPad(
                    initialAmount: clearAmount ? "" : amount,
                    getAmount: (String newAmount) {
                      clearAmount = false;
                      setState(() {});
                      amount = newAmount;
                      if (newAmount == "0")
                        context.read<FindItemProvider>().setText("");
                      else
                        context.read<FindItemProvider>().setText(newAmount);
                    },
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          color: themeColor,
                          child: TextButton(
                            child: Text(Localization.of(context).tr('yes'),
                                style: btnTextStyle),
                            onPressed: () async {
                              Navigator.pop(context,
                                  context.read<FindItemProvider>().text);
                            },
                          ),
                        ),
                      ),
                      _cancelBtn(context)
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}

class FindItemProvider extends ChangeNotifier {
  String _text = "";
  String get text => _text;

  void setText(String newText) {
    _text = newText;
    notifyListeners();
  }
}
