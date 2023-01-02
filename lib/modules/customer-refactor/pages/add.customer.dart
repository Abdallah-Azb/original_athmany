import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/accessories/models/accessory.dart';
import 'package:app/modules/accessories/provider/accessory.provider.dart';
import 'package:app/modules/customer-refactor/Provider/Territory.dart';
import 'package:app/modules/customer-refactor/models/CustomerGroup.dart';
import 'package:app/modules/customer-refactor/models/Territory.dart';
import 'package:app/modules/customer-refactor/models/models.dart';
import 'package:app/modules/customer-refactor/repositories/customerRepository.dart';
import 'package:app/modules/customer/provider/customers.provider.dart';
import 'package:app/providers/home.provider.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/services/customer.service.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/extensions/widget_extension.dart';
class AddCustomer extends StatefulWidget {
  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  CustomerService _customerService = CustomerService();
  CustomerRepository _customerRepository = CustomerRepository();
  Future companiesListFuture;

  final _formKey = GlobalKey<FormState>();
  Customer customer = Customer();
  bool nameTouched = false;
  bool phoneTouched = false;
  bool emailTouched = false;
  List customerGroups = [];
  bool submited = false;
  var isLoading = false;
  getPref() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var l = _prefs.getString('CUSTOMER_GROUPS');
    customerGroups = l.split(" ");
    print('ee :$l');
    print('length :${customerGroups.length}');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) =>
        Provider.of<DropdownListsProvider>(context, listen: false)
            .getTerritories());
    // Provider.of<DropdownListsProvider>(context, listen: false).getTerritories();
    //Provider.of<TerritoryProvider>(context, listen: false).getTerritories();
    getPref();
    if (context.read<CustomersProvider>().editCustomer != null) {
      this.customer = context.read<CustomersProvider>().editCustomer;
    }
    print(this.customer.customerGroup);
  }

  bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<DropdownListsProvider>(context);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    var width = MediaQuery.of(context).size.width;
    return typeMobile == TYPEMOBILE.TABLET
        ? Scaffold(
      backgroundColor:
      isDarkMode == false ? Colors.grey.shade300 : appBarColor,
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: submit(context, width),
      body: Container(
        child: Column(
          children: [
            Container(
              child: Text(
                context.read<CustomersProvider>().editCustomer != null
                    ? Localization.of(context).tr('edit_customer')
                    : Localization.of(context).tr('add_new_customer'),
                style: TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child: Form(
                autovalidateMode: this.checkInputsTouched()
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                key: _formKey,
                // On Change Validation!
                onChanged: () {
                  final isValid = _formKey.currentState.validate();
                  if (_isValid != isValid) {
                    setState(() {
                      _isValid = isValid;
                    });
                  }
                },
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(flex: 2, child: name()),
                            SizedBox(
                              width: width / 15,
                            ),
                            Flexible(flex: 2, child: phone()),
                            SizedBox(
                              width: width / 15,
                            ),
                            Flexible(flex: 2, child: email())
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(flex: 2, child: customerGroupList()),
                            SizedBox(
                              width: width / 15,
                            ),
                            Flexible(flex: 2, child: territoryList()),
                            SizedBox(
                              width: width / 15,
                            ),
                            Flexible(flex: 2, child: customerTypeList())
                          ],
                        ),
                        // territoryList()
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 60),
                    ),
                    // submit(context)
                  ],
                ),
              ),
            ),
          ],
        ).paddingAll(16),
      ),
    )
        : Scaffold(
      backgroundColor:
      isDarkMode == false ? Colors.white : darkBackGroundColor,
      body: Container(
        child: Column(
          children: [
            Container(
              child: Text(
                context.read<CustomersProvider>().editCustomer != null
                    ? Localization.of(context).tr('edit_customer')
                    : Localization.of(context).tr('add_new_customer'),
                style: TextStyle(
                  fontSize: 20,
                  color: // Colors.red,
                  isDarkMode == false
                      ? darkContainerColor
                      : Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Form(
                autovalidateMode: this.checkInputsTouched()
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                key: _formKey,
                child: ListView(
                  children: [
                    Column(
                      children: [
                        name(size: 15.0),
                        phone(size: 15.0),
                        email(size: 15.0),
                        customerGroupList(size: 15.0),
                        territoryList(size: 15.0)
                      ],
                    ),
                    // submit(context)
                  ],
                ),
              ),
            ),
          ],
        ).paddingAll(10),
      ),
    );
  }

  Container submit(BuildContext context, double width) {
    return Container(
      width: width,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(themeColor),
          padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
                (Set<MaterialState> states) {
              return EdgeInsets.symmetric(vertical: 15);
            },
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        onPressed: () async {
          context.read<CustomersProvider>().editCustomer != null
              ? editCustomer()
              : addCustomer();
        },
        child: Text(
          Localization.of(context).tr('submit_new_customer'),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ).paddingHorizontally(20),
    );
  }

  Future<void> addCustomer() async {
    submited = true;
    setState(() {});
    if (_formKey.currentState.validate()) {
      try {
        print('4    ' + customer.defaultMobile);

        // print('id is : ' + customer.name);
        Response response = await this._customerService.addCustomer(customer);
        print('YELLOW ${response.statusCode}');
        if (response.statusCode == 200) {
          print('x ${response.data}');
          await toast(
              Localization.of(context)
                  .tr('customer_successfully_added_message'),
              themeColor,
              gravity: ToastGravity.TOP);
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text(Localization.of(context)
          //       .tr('customer_successfully_added_message')),
          //   backgroundColor: themeColor,
          // ));
          customer.name = customer.customerName;
          await DBCustomer().add(customer);
          // var currentCustomersList = await DBCustomer().getAll();
          // print(currentCustomersList[0].name);
          context.read<HomeProvider>().setMainIndex(4);
        }
      } on DioError catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        var _serverMessage = e.response.data['_server_messages'];
        if (_serverMessage ==
            "[\"{\\\"message\\\": \\\"Default Mobile must be unique\\\"}\"]") {
          await toast(
              Localization.of(context).tr('phone_must_be_unique_message'),
              Colors.red,
              gravity: ToastGravity.TOP);
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //     content: Text(Localization.of(context)
          //         .tr('phone_must_be_unique_message'))));
        }
        if (_serverMessage ==
            "[\"{\\\"message\\\": \\\"Default Email must be unique\\\"}\"]") {
          await toast(
              Localization.of(context).tr('email_must_be_unique_message'),
              Colors.red,
              gravity: ToastGravity.TOP);
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //     content: Text(Localization.of(context)
          //         .tr('email_must_be_unique_message'))));
        }
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        print(e);
      }
    }
  }

  Future<void> editCustomer() async {
    submited = true;
    setState(() {});
    if (_formKey.currentState.validate()) {
      try {
        print("editing ${customer.name}}");
        Response response = await this._customerService.editCustomer(customer);
        print("editing ${customer.defaultMobile}}");
        if (response.statusCode == 200) {
          await toast(
              Localization.of(context)
                  .tr('customer_successfully_edited_message'),
              themeColor,
              gravity: ToastGravity.TOP);
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text(Localization.of(context)
          //       .tr('customer_successfully_added_message')),
          //   backgroundColor: themeColor,
          // ));
          await DBCustomer().editCustomer(customer);
          context.read<HomeProvider>().setMainIndex(4);
        }
      } on DioError catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        var _serverMessage = e.response.data['_server_messages'];
        if (_serverMessage ==
            "[\"{\\\"message\\\": \\\"Default Mobile must be unique\\\"}\"]") {
          await toast(
              Localization.of(context).tr('phone_must_be_unique_message'),
              Colors.red,
              gravity: ToastGravity.TOP);
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //     content: Text(Localization.of(context)
          //         .tr('phone_must_be_unique_message'))));
        }
        if (_serverMessage ==
            "[\"{\\\"message\\\": \\\"Default Email must be unique\\\"}\"]") {
          await toast(
              Localization.of(context).tr('email_must_be_unique_message'),
              Colors.red,
              gravity: ToastGravity.TOP);
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //     content: Text(Localization.of(context)
          //         .tr('email_must_be_unique_message'))));
        }
      } catch (e, stackTrace) {
        await Sentry.captureException(
          e,
          stackTrace: stackTrace,
        );
        print(e);
      }
    }
  }

  Container email({size = 22.0}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                Localization.of(context).tr('email'),
                style: TextStyle(fontSize: 22),
              ),
            ],
          ).paddingHorizontally(8),
          // merge check , there is a container that added as a parent to following TextFormField
          TextFormField(
            textInputAction: TextInputAction.next,
            initialValue: context.read<CustomersProvider>().editCustomer != null
                ? this.customer.defaultEmail
                : null,
            onChanged: (value) {
              this.emailTouched = true;
              setState(() {});
            },
            validator: (value) {
              if (value != null && value != "") {
                if (!validateEmail(value)) {
                  return Localization.of(context).tr('email_input_error');
                }
              }
              this.customer.defaultEmail = value;
              return null;
            },
            style: TextStyle(
              color: isDarkMode == false ? Colors.black : Colors.white,
            ),
            decoration: _inputDecoration.copyWith(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  )),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.red,
                  )),
              hintText: Localization.of(context).tr('email'),
              hintStyle: TextStyle(
                color: Colors.grey,
              ),
              filled: true,
              fillColor:
              isDarkMode == false ? Colors.white : darkContainerColor,
            ),
          ),
        ],
      ),
    );
  }

  Container phone({size = 22.0}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                Localization.of(context).tr('phone'),
                style: TextStyle(fontSize: 22),
              ),
              Text(
                '*',
                style: TextStyle(fontSize: 22, color: Colors.red),
              ),
            ],
          ).paddingHorizontally(8),
          TextFormField(
            textInputAction: TextInputAction.next,
            // maxLength: 10,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            initialValue: context.read<CustomersProvider>().editCustomer != null
                ? this.customer.defaultMobile
                : null,
            onChanged: (value) {
              if (value.length > 10) return this.phoneTouched = true;
              setState(() {});
            },
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  value.length < 10 ||
                  value.length > 10) {
                return Localization.of(context).tr('phone_input_error');
              }
              this.customer.defaultMobile = value;
              return null;
            },
            // inputFormatters: [
            //   // FilteringTextInputFormatter.allow(
            //   //     RegExp(r"\s+\b|\b\s"))
            //   WhitelistingTextInputFormatter.digitsOnly
            // ],
            style: TextStyle(
              color: isDarkMode == false ? Colors.black : Colors.white,
            ),
            decoration: _inputDecoration.copyWith(
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.green,
                  )),
              errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.red,
                  )),
              contentPadding: const EdgeInsets.all(8.0),
              hintText: '055XXXXXXX',
              hintStyle: TextStyle(
                color: isDarkMode == false ? Colors.grey : Colors.white,
              ),
              filled: true,
              fillColor:
              isDarkMode == false ? Colors.white : darkContainerColor,
            ),
            // hintText: Localization.of(context).tr('phone')),
          ),
        ],
      ),
    );
  }

  Container territoryList({size = 22.0}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                Localization.of(context).tr('territory'),
                style: TextStyle(fontSize: 22),
              ),
              Text(
                '*',
                style: TextStyle(fontSize: 22, color: Colors.red),
              ),
            ],
          ).paddingHorizontally(8),
          Consumer<DropdownListsProvider>(
              builder: (ctx, territory, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Container(
                    decoration: BoxDecoration(
                      // merge check , in ix it does not commented
                      // border: Border.all(
                      //   width: 0.5,
                      //   color: Colors.grey.shade800,
                      // ),
                        borderRadius: BorderRadius.circular(12.0),
                        color: isDarkMode == false
                            ? Colors.white
                            : darkContainerColor),
                    child: DropdownButtonFormField<String>(
                      // underline: SizedBox.shrink(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return Localization.of(context)
                              .tr('territory_input_error');
                        }
                        this.customer.territory = value;
                        return null;
                      },
                      decoration: InputDecoration.collapsed(hintText: ''),
                      isExpanded: true,
                      icon: Transform.rotate(
                        origin: Offset(0, 0),
                        angle: 4.7,
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: isDarkMode == false
                              ? darkContainerColor
                              : Colors.white,
                        ),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          customer.territory = val;
                        });
                      },
                      items: territory.territories
                          .map(
                            (e) => DropdownMenuItem(
                          child: Text(
                            "$e",
                            style: TextStyle(
                              color: isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          value: e,
                        ),
                      )
                          .toList(),
                      value:
                      context.read<CustomersProvider>().editCustomer !=
                          null
                          ? this.customer.territory
                          : null,
                    ).paddingAll(16),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Container customerGroupList({size = 22.0}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    var validator = Localization.of(context).tr('customerGroup_input_error');
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                Localization.of(context).tr('customer_group'),
                style: TextStyle(fontSize: 22),
              ),
              Text(
                '*',
                style: TextStyle(fontSize: 22, color: Colors.red),
              ),
            ],
          ).paddingHorizontally(8),
          Consumer<DropdownListsProvider>(
              builder: (ctx, territory, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Container(
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   width: 0.5,
                      //   color: Colors.grey.shade800,
                      // ),
                        borderRadius: BorderRadius.circular(12.0),
                        color: isDarkMode == false
                            ? Colors.white
                            : darkContainerColor),
                    child: DropdownButtonFormField<String>(
                      validator: (value) =>
                      value == null ? '$validator' : null,
                      decoration: InputDecoration.collapsed(hintText: ''),
                      isExpanded: true,
                      icon: Transform.rotate(
                        origin: Offset(0, 0),
                        angle: 4.7,
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: isDarkMode == false
                              ? darkContainerColor
                              : Colors.white,
                        ),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          customer.customerGroup = val;
                        });
                      },
                      items: territory.customerGroups
                          .map(
                            (e) => DropdownMenuItem(
                          child: Text(
                            " $e ",
                            style: TextStyle(
                              color: isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          value: e,
                        ),
                      )
                          .toList(),
                      value:
                      context.read<CustomersProvider>().editCustomer !=
                          null
                          ? this.customer.customerGroup
                          : null,
                    ).paddingAll(16),
                  ),
                ],
              ))

          // _SelectDropdown<Datum>(
          //   title: Localization.of(context).tr('device_type'),
          //   values: model.territories,
          //   onTap: model.onTerritory,
          //   defaultValue: model.territories[0] ?? 'اختر المنطقة',
          //   // onTap: model.territories,
          // ),
        ],
      ),
    );
  }

  Container customerTypeList({size = 22.0}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    var validator = Localization.of(context).tr('customerType_input_error');
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                Localization.of(context).tr('customer_type'),
                style: TextStyle(fontSize: 22),
              ),
              Text(
                '*',
                style: TextStyle(fontSize: 22, color: Colors.red),
              ),
            ],
          ).paddingHorizontally(8),
          Consumer<DropdownListsProvider>(
              builder: (ctx, territory, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Container(
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   width: 0.5,
                      //   color: Colors.grey.shade800,
                      // ),
                        borderRadius: BorderRadius.circular(12.0),
                        color: isDarkMode == false
                            ? Colors.white
                            : darkContainerColor),
                    child: DropdownButtonFormField<String>(
                      validator: (value) =>
                      value == null ? '$validator' : null,
                      decoration: InputDecoration.collapsed(hintText: ''),
                      isExpanded: true,
                      icon: Transform.rotate(
                        origin: Offset(0, 0),
                        angle: 4.7,
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          color: isDarkMode == false
                              ? darkContainerColor
                              : Colors.white,
                        ),
                      ),
                      onChanged: (String val) {
                        setState(() {
                          customer.customerType = val;
                        });
                      },
                      items: territory.customerTypes
                          .map(
                            (e) => DropdownMenuItem(
                          child: Text(
                            " $e ",
                            style: TextStyle(
                              color: isDarkMode == false
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          value: e,
                        ),
                      )
                          .toList(),
                      value:
                      context.read<CustomersProvider>().editCustomer !=
                          null
                          ? this.customer.customerType
                          : null,
                    ).paddingAll(16),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Container name({size = 22.0}) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                Localization.of(context).tr('customer_name'),
                style: TextStyle(
                  fontSize: size,
                  color: isDarkMode == false ? Colors.black : Colors.white,
                ),
              ),
              Text(
                '*',
                style: TextStyle(fontSize: 22, color: Colors.red),
              ),
            ],
          ).paddingHorizontally(8),
          TextFormField(
            textInputAction: TextInputAction.next,
            initialValue: context.read<CustomersProvider>().editCustomer != null
                ? this.customer.customerName
                : null,
            onChanged: (value) {
              this.nameTouched = true;
              setState(() {});
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return Localization.of(context).tr('name_input_error');
              }
              this.customer.customerName = value;
              return null;
            },
            style: TextStyle(
              color: isDarkMode == false ? Colors.black : Colors.white,
            ),
            decoration: _inputDecoration.copyWith(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    width: 2,
                    color: isDarkMode == false ? Colors.green : Colors.white,
                  )),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.red,
                  )),
              contentPadding: const EdgeInsets.all(8.0),
              hintText: Localization.of(context).tr('customer_name'),
              hintStyle: TextStyle(
                color: isDarkMode == false ? Colors.grey : Colors.white,
              ),
              filled: true,
              fillColor:
              isDarkMode == false ? Colors.white : darkContainerColor,
            ),
          ),
        ],
      ),
    );
  }

  bool checkInputsTouched() {
    if (this.nameTouched && this.phoneTouched && this.submited) {
      return true;
    }
    return false;
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  InputDecoration _inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.red.shade800, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      //borderSide: BorderSide(color: Colors.grey.shade800, width: 0.5),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: themeColor, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.shade800, width: 0.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.red.shade800, width: 0.5),
    ),
  );
}

class _SelectDropdown<T> extends StatelessWidget {
  final List<T> values;
  final T defaultValue;
  final String title;
  final String hintText;
  final Function(T value) onTap;

  const _SelectDropdown({
    Key key,
    this.title,
    this.hintText,
    this.values,
    this.defaultValue,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.0),
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                width: 0.5,
                color: Colors.grey.shade800,
              ),
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.white),
          child: DropdownButton<T>(
            value: defaultValue,
            underline: SizedBox.shrink(),
            isExpanded: true,
            icon: Transform.rotate(
              origin: Offset(0, 0),
              angle: 4.7,
              child: Icon(Icons.arrow_back_ios_rounded),
            ),
            onChanged: onTap,
            items: values
                .map(
                  (e) => DropdownMenuItem(
                child: Text("$e"),
                value: e,
              ),
            )
                .toList(),
          ).paddingHorizontallyAndVertical(16, 8),
        ),
      ],
    );
  }
}
