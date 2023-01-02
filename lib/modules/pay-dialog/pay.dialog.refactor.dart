import 'package:app/core/enums/type_mobile.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/pay-dialog/pay.dialog.provider.dart';
import 'package:app/modules/pay-dialog/widgets/submit.dart';
import 'package:app/modules/pay-dialog/widgets/widgets.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/type_mobile_provider.dart';
import '../../core/utils/const.dart';
import '../../widget/widget/empty_list_widget.dart';
import '../../widget/widget/loading_animation_widget.dart';
import 'models/models.dart';
import '../../core/extensions/widget_extension.dart';

class PayDialogRefactor extends StatefulWidget {
  final double invoiceTotal;
  final String applyDiscountOn;
  final double discountAmount;
  final double totalAfterDiscount;
  final int isReturn;
  const PayDialogRefactor(
      {Key key,
      this.invoiceTotal,
      this.applyDiscountOn,
      this.discountAmount,
      this.totalAfterDiscount,
      this.isReturn})
      : super(key: key);

  @override
  _PayDialogRefactorState createState() => _PayDialogRefactorState();
}

class _PayDialogRefactorState extends State<PayDialogRefactor> {
  Future paymentMethodsFuture;
  DBPaymentMethod _dbPaymentMethod = DBPaymentMethod();
  String localPath;
  PayDialogProvider payDialogProvider;

  Future<List<PaymentMethodRefactor>> _getPaymentMethods() async {
    this.localPath = await CacheItemImageService().localPath;
    return await this
        ._dbPaymentMethod
        .getPaymentMethodsRefactor(isReturn: widget.isReturn);
  }

  @override
  void initState() {
    super.initState();
    this.paymentMethodsFuture = this._getPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return FutureBuilder<List<PaymentMethodRefactor>>(
      future: this.paymentMethodsFuture,
      builder: (BuildContext context,
          AsyncSnapshot<List<PaymentMethodRefactor>> snapshot) {
        if (snapshot.hasError) print(snapshot.error);
        if (snapshot.hasData) {
          List<PaymentMethodRefactor> paymentMethods = snapshot.data;
          return ChangeNotifierProvider<PayDialogProvider>(
            create: (context) => PayDialogProvider(
              paymentMethods: paymentMethods,
              invoiceTotal: widget.invoiceTotal,
              totalAfterDiscount: widget.totalAfterDiscount,
            ),
            child: Consumer<PayDialogProvider>(
              builder: (context, model, child) => typeMobile ==
                      TYPEMOBILE.TABLET
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Column(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                    child: NumPadContainer(
                                        totalAfterDiscount: widget.invoiceTotal,
                                        isReturn: widget.isReturn)),
                                Expanded(
                                    child: Column(
                                  children: [
                                    Expanded(
                                        flex: 2, child: PaidTotalContainer()),
                                    PaymentMethodsList(
                                      localPath: this.localPath,
                                      paymentMethods: paymentMethods,
                                      isReturn: widget.isReturn,
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ),
                          Submit(
                            applyDiscountOn: widget.applyDiscountOn,
                            discountAmount: widget.discountAmount,
                            totalAfterDiscount: widget.invoiceTotal,
                            isReturn: widget.isReturn,
                            payments: paymentMethods,
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Column(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      PaidTotalContainer()..paddingAll(4),
                                      Expanded(
                                        child: PaymentMethodsList(
                                          localPath: this.localPath,
                                          paymentMethods: paymentMethods,
                                          isReturn: widget.isReturn,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: NumPadContainer()),
                              ],
                            ),
                          ),
                          Submit(
                            applyDiscountOn: widget.applyDiscountOn,
                            discountAmount: widget.discountAmount,
                            totalAfterDiscount: widget.totalAfterDiscount,
                            isReturn: widget.isReturn,
                          )
                        ],
                      ),
                    ),
            ),
          );
        }
        return Center(
            child: LoadingAnimation(
          typeOfAnimation: "staggeredDotsWave",
          color: themeColor,
          size: 100,
        ));
      },
    );
  }
}
