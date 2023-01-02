import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/customer/customer.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widget/widget/loading_animation_widget.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../../../core/extensions/widget_extension.dart';
class CustomersPage extends StatefulWidget {
  const CustomersPage({Key key}) : super(key: key);

  @override
  _CustomersPageState createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  Future customersListFuture;
  List<Customer> customers = [];

  getPref() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var l = _prefs.getString('CUSTOMER_GROUPS');
    print('ee :$l');
  }

  @override
  void initState() {
    super.initState();
    getPref();

    // bandar fix
    Future.delayed(Duration.zero, () async {
      context.read<CustomersProvider>().clearEditCustomer();
      this.customersListFuture = DBCustomer().getAll();
      //print(customersListFuture);
    });
    // context.read<CustomersProvider>().clearEditCustomer();
    // this.customersListFuture = DBCustomer().getAll();
  }

  void setStateToupdateCustomersList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      color: isDarkMode == false ? Colors.black12 : appBarColor,
      child: FutureBuilder<List<Customer>>(
        future: DBCustomer().getAll(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Customer>> snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          if (snapshot.hasData) {
            this.customers = snapshot.data;
            return Container(
              child: Column(children: [
                SizedBox(
                  height: 12,
                ),
                CustomerSearch(setStateToupdateCustomersList),
                SizedBox(height: 20),
                CustomersList(this.customers)
              ]).paddingHorizontallyAndVertical(typeMobile == TYPEMOBILE.TABLET ? 20 :2 , typeMobile == TYPEMOBILE.TABLET ? 2 :8 ),
            );
          }
          return Center(
              child: LoadingAnimation(
            typeOfAnimation: "staggeredDotsWave",
            color: themeColor,
            size: 100,
          ));
        },
      ),
    );
  }
}
