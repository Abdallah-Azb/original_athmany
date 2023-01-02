import 'dart:async';

import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/db-operations/db.opening.details.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/closing/pages/pages.dart';
import 'package:app/modules/customer-refactor/pages/customers.list.page.dart';
import 'package:app/modules/customer-refactor/pages/pages.dart';
// import 'package:app/modules/customer/customer.dart';
import 'package:app/modules/footer/footer.dart';
import 'package:app/modules/header/header.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/menuItems/menu.item.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:app/modules/searchInvioceList/provider/search.autocomplete.provider.dart';
import 'package:app/modules/stock/stock.page.dart';
import 'package:app/modules/tables/tables.dart';
import 'package:app/pages/home/side.nav.dart';
import 'package:app/pages/invoices-list/invoices.list.dart';
import 'package:app/providers/providers.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' as Io;

import '../../core/version_check.dart';
import '../../widget/widget/loading_animation_widget.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  Future dataFuture;

  // select first item group
  void resetItemGroup() {
    // if (_menuState.currentState != null) {
    //   _menuState.currentState.updateSelectedIndex(0);
    //   context.read<MenuItemProvider>().resetItemGroup();
    // }
  }

  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   print("=======>>>${VersionCheck.canUpdate}");
  //   VersionCheck.canUpdate == true
  //       ? VersionCheck.checkForNewVersion(context)
  //       : print('=====No====');
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    imageCache.clear();
    imageCache.clearLiveImages();

    context.read<InvoiceProvider>().clearInvoice();
    context.read<HomeProvider>().selectedMainWidgetIndex = 0;
    dataFuture = getData();

    // final timer = PausableTimer(Duration(seconds: 1), () => print('Fired!'));

    checkNotSyncedInvoicesTimer = Timer.periodic(
        Duration(seconds: 300), (Timer t) => checkNotSyncedInvoices());

    super.initState();
  }

  Timer checkNotSyncedInvoicesTimer;

  bool checkNotSyncedInvoicesShown = false;

  checkNotSyncedInvoices() async {
    try {
      checkNotSyncedInvoicesTimer.cancel();
      print("STOP");
      print(checkNotSyncedInvoicesTimer.isActive);
      setState(() {});
      await OpeningRepositoryRefactor().checkInternetAvailability();
      List<Invoice> notSyncedInvoices =
          await DBInvoiceRefactor().getAllNotSyncedInvoices();
      if (notSyncedInvoices.length == 0) print("all invoices are synced");
      if (notSyncedInvoices.length >= 1) {
        await OpeningRepositoryRefactor().syncInvoices();
        if (notSyncedInvoices.length > 9) {
          if (!checkNotSyncedInvoicesShown)
            _showMyDialog(notSyncedInvoices.length);
        }
      }
      checkNotSyncedInvoicesTimer = Timer.periodic(
          Duration(seconds: 300), (Timer t) => checkNotSyncedInvoices());
      print("RUN");
      print(checkNotSyncedInvoicesTimer.isActive);
      setState(() {});
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _showMyDialog(int notSyncedInvoices) async {
    setState(() {
      checkNotSyncedInvoicesShown = true;
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog(
          bodyText: "You have $notSyncedInvoices are not synced",
          onConfirm: () => Navigator.pop(context),
        );
      },
    ).then((value) => setState(() {
          checkNotSyncedInvoicesShown = false;
          checkNotSyncedInvoicesTimer.cancel();
          checkNotSyncedInvoicesTimer = Timer.periodic(
              Duration(seconds: 300), (Timer t) => checkNotSyncedInvoices());
        }));
  }

  @override
  void dispose() {
    checkNotSyncedInvoicesTimer.cancel();
    super.dispose();
  }

  User user;
  OpeningDetails openingDetails;
  ProfileDetails posProfileDetails;
  List<SalesTaxesDetails> salestaxesDetails;
  List<ItemsGroups> itemGroups = [];
  List<ItemOfGroup> itemsOfGroup;
  // rate (looping throw sales taxes details array and get total of rate)
  double rate;
  String baseUrl;
  String localPath;
  // get user data
  // get opening details
  // get pos profile details
  // get item groups
  Future<bool> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.baseUrl = prefs.getString('base_url');
    localPath = await CacheItemImageService().localPath;
    InvoiceProvider invoice =
        Provider.of<InvoiceProvider>(context, listen: false);
    invoice.setNewId(await InvoiceRepositoryRefactor().getNewInvoiceId());
    bool data;
    try {
      this.user = await DBUser().getUser();
      this.openingDetails = await DBOpeningDetails().getOpeningDetails();
      // print(openingDetails.toSqlite());
      this.posProfileDetails = await DBProfileDetails().getProfileDetails();
      this.salestaxesDetails =
          await DBSalesTaxesDetails().getSalesTaxeDetails();
      invoice.currentInvoice.customerRefactor =
          await DBCustomer().getDefaultCutomer();
      // this.itemGroups = await DBItemsGroup.getItemGroups();
      DBItemsGroup.getItemGroups()
          .then((itemGroupsRes) => itemGroups.addAll(itemGroupsRes));
      this.rate = await getRate();
      this.mainWidget = [
        Menu(
            key: invoice.menuState,
            localPath: this.localPath,
            itemGroups: itemGroups,
            baseUrl: this.baseUrl),
        ChangeNotifierProvider<SearchAutoCompleteProvider>(
          create: (_) => SearchAutoCompleteProvider(),
          child: InvoicesList(
            clearInvoice: context.read<InvoiceProvider>().clearInvoice,
          ),
        ),
        ClosingPage(),
        TablesPage(),
        CustomersPage(),
        AddCustomer(),
        StockPage(baseUrl: this.baseUrl),
        TablesCategoryPage(),
        // Customers()
      ];
      data = true;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e.toString());
    }
    return data;
  }

  // get rate (vat)
  Future<double> getRate() async {
    List<SalesTaxesDetails> salesTaxeDetailsList =
        await DBSalesTaxesDetails().getSalesTaxeDetails();
    double rate = 0;
    salesTaxeDetailsList.forEach((e) {
      rate += e.rate;
    });
    return rate;
  }

  // main widget
  List<Widget> mainWidget;

  bool pageLoading = false;
  updatePageLoadingValue(bool loading) {
    this.pageLoading = loading;
    setState(() {});
  }

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    HomeProvider homeProvider = Provider.of<HomeProvider>(context);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return LoadingOverlay(
      opacity: 0.3,
      color: themeColor,
      isLoading: pageLoading,
      child: FutureBuilder<bool>(
        future: dataFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Container();
          }
          if (snapshot.hasData) {
            return typeMobile == TYPEMOBILE.TABLET
                ? Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: Column(
                      children: [
                        Container(
                          height: 0,
                          width: 0,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Image.file(
                                Io.File('$localPath/invoice-logo.png'),
                                // scale: 1,
                                width: 320,
                                // height: 200,
                              ),
                            ],
                          ),
                        ),
                        // header
                        Header(
                          updatePageLoadingValue: updatePageLoadingValue,
                          posProfileDetails: this.posProfileDetails,
                          user: this.user,
                          openingDetails: this.openingDetails,
                        ),
                        mainPage(),
                        homeProvider.selectedMainWidgetIndex == 2 ||
                                homeProvider.selectedMainWidgetIndex == 5
                            ? Container()
                            : Fotter(
                                posProfileDetails: this.posProfileDetails,
                                clearInvoice: () async {
                                  await context
                                      .read<InvoiceProvider>()
                                      .clearInvoice();
                                },
                                resetItemGroup: resetItemGroup,
                              )
                      ],
                    ),
                  )
                :
                // mobile
                Scaffold(
                    key: scaffoldKey,
                    resizeToAvoidBottomInset: false,
                    drawer: SideNav(
                      selectedMainWidgetIndex:
                          homeProvider.selectedMainWidgetIndex,
                    ),
                    body: Column(
                      children: [
                        Header(
                          updatePageLoadingValue: updatePageLoadingValue,
                          posProfileDetails: this.posProfileDetails,
                          user: this.user,
                          openingDetails: this.openingDetails,
                          keyScaffold: scaffoldKey,
                        ),
                        homeProvider.selectedMainWidgetIndex == 2 ||
                                homeProvider.selectedMainWidgetIndex == 6 ||
                                homeProvider.selectedMainWidgetIndex == 5 ||
                                homeProvider.selectedMainWidgetIndex == 4
                            ? Container()
                            : Container(
                                color: Colors.blueAccent,
                                height:
                                    MediaQuery.of(context).size.height / 2.2,
                                child: SideInvoice(
                                  salestaxesDetails: this.salestaxesDetails,
                                ),
                              ),
                        SizedBox(height: 4),
                        Expanded(
                            child: mainWidget[
                                homeProvider.selectedMainWidgetIndex]),
                        homeProvider.selectedMainWidgetIndex == 2 ||
                                homeProvider.selectedMainWidgetIndex == 5
                            ? Container()
                            : Fotter(
                                posProfileDetails: this.posProfileDetails,
                                clearInvoice: () async {
                                  await context
                                      .read<InvoiceProvider>()
                                      .clearInvoice();
                                },
                                resetItemGroup: resetItemGroup,
                              )
                      ],
                    ),
                  );
          }
          return Scaffold(
            body: Center(
              child: LoadingAnimation(
                typeOfAnimation: "staggeredDotsWave",
                color: themeColor,
                size: 100,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget mainPage() {
    HomeProvider homeProvider = Provider.of<HomeProvider>(context);
    return Expanded(
        child: Container(
      child: Row(
        children: [
          // side nav
          SideNav(
              selectedMainWidgetIndex: homeProvider.selectedMainWidgetIndex),
          // main widget
          Expanded(child: mainWidget[homeProvider.selectedMainWidgetIndex]),
          homeProvider.selectedMainWidgetIndex == 2 ||
                  homeProvider.selectedMainWidgetIndex == 6 ||
                  homeProvider.selectedMainWidgetIndex == 5 ||
                  homeProvider.selectedMainWidgetIndex == 4
              ? Container()
              : SideInvoice(salestaxesDetails: this.salestaxesDetails)
        ],
      ),
    ));
  }
}
