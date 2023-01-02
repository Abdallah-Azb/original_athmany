import 'package:app/core/utils/const.dart';
import 'package:app/core/utils/toas.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/models/company.details.dart';
import 'package:app/models/device.details.dart';
import 'package:app/models/payment.method.dart';
import 'package:app/models/profile.details.dart';
import 'package:app/models/sales.taxes.details.dart';
import 'package:app/modules/accessories/models/accessory.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/modules/opening/models/models.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:app/modules/tables/models/table.dart';
import 'package:app/services/accessory.service.dart';
import 'package:app/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:provider/provider.dart';

import '../../../widget/provider/theme_provider.dart';
import '../../../widget/widget/loading_animation_widget.dart';
import '../../../core/extensions/widget_extension.dart';

class SyncDataDialog extends StatefulWidget {
  final bool cachItmesImages;
  const SyncDataDialog({Key key, this.cachItmesImages}) : super(key: key);

  @override
  _SyncDataDialogState createState() => _SyncDataDialogState();
}

class _SyncDataDialogState extends State<SyncDataDialog> {
  Future<void> handleSync() async {
    try {
      this.textButtonString = "مزامنة ...";
      setState(() {});
      await syncInvoices();
      OpeningDetails openingDetails =
          await DBOpeningDetails().getOpeningDetails();
      await syncCompnayDetails(openingDetails);
      ProfileDetails profileDetails = await syncProfileDetails(openingDetails);
      await syncItemsGroupsWithItems(profileDetails);
      await syncDeliveryApps(profileDetails);
      await syncDefaultCustomer(profileDetails);
      await syncPaymentMethods(profileDetails);
      await syncSalesTaxesDetails(profileDetails);
      await syncDineInTablesables(profileDetails);
      await syncAccessories();
      InvalidOpeningDetails invalidOpeningDetails =
          await OpeningRepositoryRefactor()
              .validateOpening(openingDetails.profile);
      if (invalidOpeningDetails.invalidData.firstWhere(
              (e) => e.invalidItems.length > 0,
              orElse: () => null) !=
          null) {
        this.invalidOpeningDetails = invalidOpeningDetails;
        setState(() {});
      }
      syncDone = true;
      setState(() {});
      if (this.invalidOpeningDetails == null) {
        this.textButtonString = "متابعة";
        setState(() {});
      }
      if (this.invalidOpeningDetails != null) {
        if (this.invalidOpeningDetails.invalidData.length > 0) {
          this.textButtonString = "إعادة المحاولة";
          setState(() {});
        }
      }
    } on Failure catch (e) {
      toast(e.toString(), Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    handleSync();
  }

  Future<void> syncInvoices() async {
    try {
      await OpeningRepositoryRefactor().syncInvoices();
      syncData.invoicesSynced = true;
      // invoicesSynced = true;
      setState(() {});
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> syncCompnayDetails(OpeningDetails openingDetails) async {
    try {
      Company company = Company(value: openingDetails.company, description: "");
      CompanyDetails companyDetails =
          await ProfileServiceRefactor().getCompanyDetails(company);
      await db.execute("DROP TABLE IF EXISTS company_details");
      await DBService().createCompanyDetailsTable(db);
      await DBCompanyDetails().add(companyDetails);
      syncData.companyDetailsSynced = true;
      // companyDetailsSynced = true;
      setState(() {});
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<ProfileDetails> syncProfileDetails(
      OpeningDetails openingDetails) async {
    try {
      Company company = Company(value: openingDetails.company, description: "");
      Profile profile = Profile(value: openingDetails.profile, description: "");
      ProfileDetails profileDetails =
          await ProfileServiceRefactor().getProfileDetails(profile, company);
      if (profileDetails?.sellingPriceList == null)
        throw Failure("no_selling_price_list");
      if (profileDetails?.costCenter == null) throw Failure("no_const_center");
      await db.execute("DROP TABLE IF EXISTS pos_profile_details");
      await DBService().createPOSProfileDetailsTable(db);
      await DBProfileDetails().add(profileDetails);
      syncData.profileDetailsSynced = true;
      // profileDetailsSynced = true;
      setState(() {});
      return profileDetails;
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> syncItemsGroupsWithItems(ProfileDetails profileDetails) async {
    try {
      List<GroupWithItems> groupsWithItems =
          await ProfileServiceRefactor().getItemsWithGroups(profileDetails);
      await db.execute("DROP TABLE IF EXISTS item_groups");
      await DBService().createItemGroupsTable(db);
      await db.execute("DROP TABLE IF EXISTS default_price_list");
      await DBService().createItemsOfGroupTable(db);
      await DBItemsGroup().addGroupWithItems(groupsWithItems,
          cachItmesImages: widget.cachItmesImages);
      syncData.groupsWithItemsSynced = true;
      // groupsWithItemsSynced = true;
      setState(() {});
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> syncDeliveryApps(ProfileDetails profileDetails) async {
    try {
      List<DeliveryApplicationWithGroupsAndItems> deliveryApplications =
          await ProfileServiceRefactor()
              .getDeliveryApplicationWithGroupsAndItems(profileDetails);
      await DBService().dropDeliveryApplicationWithItems(db);
      await DBItemOfGroup()
          .createDeliveryApplicationsTables(deliveryApplications);
      await DBService().createDeliveryApplicationsTable(db);
      // await DBService().createDeliveryApplicationsTable(db);
      await DBDeliveryApplication().addAll(profileDetails.deliveryApplications);
      await DBDeliveryApplication().addGroupWithItems(deliveryApplications);
      syncData.deliveryAppsSynced = true;
      // deliveryAppsSynced = true;
      setState(() {});
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> syncDefaultCustomer(ProfileDetails profileDetails) async {
    try {
      Customer defaultCustomer = await ProfileServiceRefactor()
          .getDefaultCustomer(profileDetails.customer);
      await db.execute("DROP TABLE IF EXISTS customers");
      await DBCustomer().create();
      await DBCustomer().add(defaultCustomer);
      syncData.defaultCustomerSynced = true;
      // defaultCustomerSynced = true;
      setState(() {});
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> syncPaymentMethods(ProfileDetails profileDetails) async {
    try {
      List<PaymentMethod> paymentMethods = await ProfileServiceRefactor()
          .getPaymentMethods(profileDetails.payments);
      await db.execute("DROP TABLE IF EXISTS payment_methods");
      await DBPaymentMethod().create();
      await DBPaymentMethod().addAll(paymentMethods);
      syncData.paymentMethodsSynced = true;
      // paymentMethodsSynced = true;
      setState(() {});
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> syncSalesTaxesDetails(ProfileDetails profileDetails) async {
    try {
      List<SalesTaxesDetails> salesTaxesDetails = await ProfileServiceRefactor()
          .getSalesTaxesDetails(profileDetails.taxesAndCharges);
      await db.execute("DROP TABLE IF EXISTS sales_taxes_details");
      await DBSalesTaxesDetails().create();
      await DBSalesTaxesDetails().addAll(salesTaxesDetails);
      syncData.salesTaxesDetailsSynced = true;
      // salesTaxesDetailsSynced = true;
      setState(() {});
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> syncDineInTablesables(ProfileDetails profileDetails) async {
    try {
      List<TableModel> tables = [];
      profileDetails.posTables.forEach((cateogry) {
        int totalOfTables = (cateogry['total_of_table']);
        List<TableModel> categoryTables = List.generate(
          totalOfTables,
          (index) => TableModel(
              no: (index - 1) + cateogry['start_number'],
              category: cateogry['category']),
        );
        for (TableModel tableModel in categoryTables) {
          tables.add(tableModel);
        }
      });
      await db.execute("DROP TABLE IF EXISTS tables");
      await DBDineInTables().create();
      await DBDineInTables().addAll(tables);
      syncData.syncDineInTablesablesSynced = true;
      // syncDineInTablesablesSynced = true;
      setState(() {});
    } on Failure catch (e) {
      throw e;
    }
  }

  Future<void> syncAccessories() async {
    try {
      DeviceDetails deviceDetails = await AccessoryService().getDeviceDetails();
      List<Accessory> accessories = await AccessoryService()
          .fetchDeviceAccessories(deviceDetails.identifier);
      await db.execute("DROP TABLE IF EXISTS accessories");
      await db.execute("DROP TABLE IF EXISTS categories_of_accessories");
      await DBAccessory().create();
      await DBCategoriesAccessories().create();
      await DBAccessory().addAll(accessories);
      syncData.accessoriesSynced = true;
      setState(() {});
    } on Failure catch (e) {
      throw e;
    }

    // try {
    //   await OpeningRepositoryRefactor().syncAccessories();
    //   syncData.accessoriesSynced = true;
    //   // invoicesSynced = true;
    //   setState(() {});
    // } on Failure catch (e) {
    //   throw e;
    // }
  }

  SyncData syncData = SyncData();

  InvalidOpeningDetails invalidOpeningDetails;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Container(
            padding: EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width * 0.7,
            color: isDarkMode ? appBarColor : Colors.white,
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      height: 500,
                      child: Column(
                        children: [
                          Image.asset("assets/sync.png"),
                          SyncDataItems(
                            invoicesSynced: syncData.invoicesSynced,
                            companyDetailsSynced: syncData.companyDetailsSynced,
                            profileDetailsSynced: syncData.profileDetailsSynced,
                            groupsWithItemsSynced:
                                syncData.groupsWithItemsSynced,
                            deliveryAppsSynced: syncData.deliveryAppsSynced,
                            defaultCustomerSynced:
                                syncData.defaultCustomerSynced,
                            paymentMethodsSynced: syncData.paymentMethodsSynced,
                            salesTaxesDetailsSynced:
                                syncData.salesTaxesDetailsSynced,
                            syncDineInTablesablesSynced:
                                syncData.syncDineInTablesablesSynced,
                            accessoriesSynced: syncData.accessoriesSynced,
                          ),
                          InvalidData(
                            invalidOpeningDetails: invalidOpeningDetails,
                          )
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: syncDone
                          ? () {
                              if (invalidOpeningDetails == null) {
                                print("rebirth");
                                Phoenix.rebirth(context);
                              }
                              if (invalidOpeningDetails.invalidData.length >
                                  0) {
                                this.syncData = SyncData();
                                invalidOpeningDetails = null;
                                syncDone = false;
                                setState(() {});
                                handleSync();
                              }
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: syncDone ? themeColor : Colors.black38,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(24.0),
                            bottomLeft: Radius.circular(24.0),
                          ),
                        ),
                        child: Text(
                          textButtonString,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  bool syncDone = false;
  String textButtonString = "";
}

class SyncDataItems extends StatelessWidget {
  final bool invoicesSynced;
  final bool companyDetailsSynced;
  final bool profileDetailsSynced;
  final bool groupsWithItemsSynced;
  final bool deliveryAppsSynced;
  final bool defaultCustomerSynced;
  final bool paymentMethodsSynced;
  final bool salesTaxesDetailsSynced;
  final bool syncDineInTablesablesSynced;
  final bool accessoriesSynced;
  const SyncDataItems({
    Key key,
    this.invoicesSynced,
    this.companyDetailsSynced,
    this.profileDetailsSynced,
    this.groupsWithItemsSynced,
    this.deliveryAppsSynced,
    this.defaultCustomerSynced,
    this.paymentMethodsSynced,
    this.salesTaxesDetailsSynced,
    this.syncDineInTablesablesSynced,
    this.accessoriesSynced,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: Column(children: [
          SyncItem(item: "الفواتير", status: invoicesSynced),
          SyncItem(item: "معلومات الشركة", status: companyDetailsSynced),
          SyncItem(item: "معلومات البروفايل", status: profileDetailsSynced),
          SyncItem(item: "الأصناف", status: groupsWithItemsSynced),
          SyncItem(item: "تطبيقات التوصيل", status: deliveryAppsSynced),
        ])),
        Expanded(
            child: Column(children: [
          SyncItem(item: "العميل الأساسي", status: defaultCustomerSynced),
          SyncItem(item: "طرق الدفع", status: paymentMethodsSynced),
          SyncItem(item: "الضريبة", status: salesTaxesDetailsSynced),
          SyncItem(item: "الطاولات", status: syncDineInTablesablesSynced),
          SyncItem(item: "الأجهزة", status: accessoriesSynced),
        ])),
      ],
    ).paddingAll(50);
  }
}

class SyncItem extends StatelessWidget {
  final String item;
  final bool status;
  const SyncItem({Key key, this.item, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            child: !status
                ? LoadingAnimation(
                    typeOfAnimation: "threeArchedCircle",
                    color: themeColor,
                    size: 20,
                  )
                : CircleAvatar(
                    backgroundColor: isDarkMode ? appBarColor : Colors.white,
                    child: Icon(
                      Icons.check_circle,
                      color: themeColor,
                      size: 22,
                    ),
                  ),
            width: 20,
            height: 20,
          ),
          SizedBox(width: 12),
          Text(
            item,
            style: TextStyle(fontSize: 16),
          )
        ],
      ),
    );
  }
}

class InvalidData extends StatelessWidget {
  final InvalidOpeningDetails invalidOpeningDetails;
  const InvalidData({Key key, this.invalidOpeningDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        color: mainBlueColor,
        height: 130,
        width: double.infinity,
        child: invalidOpeningDetails == null
            ? SizedBox.shrink()
            : ListView.builder(
                itemBuilder: (context, i) => invalidOpeningDetails
                            .invalidData[i].invalidItems.length >
                        0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invalidOpeningDetails.invalidData[i].title,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          for (int x = 0;
                              x <
                                  invalidOpeningDetails
                                      .invalidData[i].invalidItems.length;
                              x++)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  invalidOpeningDetails
                                      .invalidData[i].invalidItems[x],
                                  style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.white),
                                ),
                              ],
                            ).paddingHorizontally(8)
                        ],
                      )
                    : SizedBox.shrink(),
                itemCount:
                    invalidOpeningDetails.invalidData[0].invalidItems.length,
              ),
      ),
    ).paddingHorizontally(50);
  }
}

class SyncData {
  bool invoicesSynced = false;
  bool companyDetailsSynced = false;
  bool profileDetailsSynced = false;
  bool groupsWithItemsSynced = false;
  bool deliveryAppsSynced = false;
  bool defaultCustomerSynced = false;
  bool paymentMethodsSynced = false;
  bool salesTaxesDetailsSynced = false;
  bool syncDineInTablesablesSynced = false;
  bool accessoriesSynced = false;

  SyncData(
      {invoicesSynced,
      companyDetailsSynced,
      profileDetailsSynced,
      groupsWithItemsSynced,
      deliveryAppsSynced,
      defaultCustomerSynced,
      paymentMethodsSynced,
      salesTaxesDetailsSynced,
      syncDineInTablesablesSynced,
      accessoriesSynced});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = <String, dynamic>{
      'invoicesSynced': this.invoicesSynced,
      'companyDetailsSynced': this.companyDetailsSynced,
      'profileDetailsSynced': this.profileDetailsSynced,
      'groupsWithItemsSynced': this.groupsWithItemsSynced,
      'deliveryAppsSynced': this.deliveryAppsSynced,
      'defaultCustomerSynced': this.defaultCustomerSynced,
      'paymentMethodsSynced': this.paymentMethodsSynced,
      'salesTaxesDetailsSynced': this.salesTaxesDetailsSynced,
      'syncDineInTablesablesSynced': this.syncDineInTablesablesSynced,
      'accessoriesSynced': this.accessoriesSynced,
    };
    return map;
  }
}
