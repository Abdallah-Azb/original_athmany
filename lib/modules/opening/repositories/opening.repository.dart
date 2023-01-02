import 'package:app/core/enums/enums.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.opening.dart';
import 'package:app/db-operations/db.opening.details.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/main.dart';
import 'package:app/models/company.details.dart';
import 'package:app/models/custom.exception.dart';
import 'package:app/models/models.dart';
import 'package:app/models/payment.method.dart';
import 'package:app/models/profile.details.dart';
import 'package:app/models/sales.taxes.details.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/modules/tables/models/table.dart';
import 'package:app/services/db.service.dart';
import 'package:app/services/accessory.service.dart';
import 'package:app/services/profile.service.dart';
import 'package:flutter/material.dart';
import '../opening.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpeningRepository {
  DBOpeningDetails _dbOpeningDetails = DBOpeningDetails();
  DBOpening _dbOpening = DBOpening();
  ProfileService _profileService = ProfileService();
  AccessoryService _deviceService = AccessoryService();
  DBUser _dbUser = DBUser();
  Session _session = Session();

  Future<ProfileDetails> getProfileDetails(
      Profile profile, Company company) async {
    return await _profileService.getProfileDetails(profile, company);
  }

  Future handleOpening(Profile profile, Company company) async {
    OpeningModel openingModel = await getOpeningData(profile, company);
    await _dbOpening.initProfileTables();
    await _dbOpening.initDynamicTables(openingModel);
    await _dbOpening.saveDataToTables(openingModel);
    await _dbOpening.cacheImages(openingModel);
  }

  Future<OpeningModel> getOpeningData(Profile profile, Company company) async {
    ProfileDetails profileDetails = await getProfileDetails(profile, company);
    print('check for pref of customer');
    print("$profileDetails.updateStock");
    print(profileDetails.toString());

    if (profileDetails?.sellingPriceList == null) {
      throw CustomException(
        message: 'NO DEFAULT selling_price_list',
        type: ErrorTypes.NO_SELLING_PRICE_LIST,
      );
    }

    List<PaymentMethod> paymentMethods =
        await _profileService.getPaymentMethods(profileDetails.payments);
    CompanyDetails companyDetails =
        await _profileService.getCompanyDetails(company);
    String customerGroups = '';
    for (var custoemrGroup in profileDetails.customerGroups) {
      print("HOW MANY GROUPS ? " + custoemrGroup);
      print("ggggg");
      print("$profileDetails.updateStock");
      customerGroups = customerGroups + ',' + custoemrGroup['customer_group'];
    }
    print('customer_groups: $customerGroups');
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('CUSTOMER_GROUPS', customerGroups);

    Customer defaultCustomer = await _profileService.getDefaultCustomerData(
        profileDetails.customer, customerGroups);
    List<SalesTaxesDetails> salesTaxesDetails = await _profileService
        .getSalesTaxesDetails(profileDetails.taxesAndCharges);

    List<GroupWithItems> groupsWithItems =
        await _profileService.getItemsWithGroups(profileDetails);

    List<DeliveryApplicationWithGroupsAndItems>
        deliveryapplicationsWithGroupsAndItems = await _profileService
            .getDeliveryApplicationWithGroupsAndItems(profileDetails);

    List<Accessory> accessories =
        await _deviceService.getOrSendDeviceAccessories();

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

    // List<TableModel> tables = List.generate(
    //   profileDetails.totalOfTables,
    //   (index) => TableModel(no: index),
    // );

    return OpeningModel(
      paymentMethods: paymentMethods,
      companyDetails: companyDetails,
      defaultCustomer: defaultCustomer,
      salesTaxesList: salesTaxesDetails,
      deliveryApplicationWithGroupsAndItems:
          deliveryapplicationsWithGroupsAndItems,
      groupsWithItems: groupsWithItems,
      profileDetails: profileDetails,
      tables: tables,
      deliveryApplications: profileDetails.deliveryApplications,
      accessories: accessories,
    );
  }

  Future<void> validateOpening(String profile) async {
    // List<Map<String, dynamic>> validators = [
    //   {
    //     "name": "Profile Details",
    //     "table": "pos_profile_details",
    //     "class": ProfileDetails()
    //   },
    //   {
    //     "name": "Company Details",
    //     "table": "company_details",
    //     "class": CompanyDetails()
    //   }
    // ];
    // List<InvalidData> invalidData = [];
    // for (var index = 0; index < validators.length; index++) {
    //   final table = validators[index]['table'];
    //   try {
    //     final sql = '''SELECT * FROM $table''';
    //     final rows = await db.rawQuery(sql);
    //     Map<String, dynamic> data = rows[0];
    //     invalidData.add(InvalidData(
    //         title: validators[index]['name'],
    //         invalidItems: validators[index]['class'].validate(data)));
    //   } catch (e) {
    //     print(e);
    //   }
    // }
    // // validate default customer
    // try {
    //   Customer defaultCustomer = await DBCustomer().getDefaultCutomer();
    //   invalidData.add(InvalidData(
    //       title: "Default Customer",
    //       invalidItems:
    //           defaultCustomer == null ? ["no_default_customer"] : []));
    // } catch (e) {
    //   print(e);
    // }

    // // validate sales taxes details
    // List<SalesTaxesDetails> salesTaxesDetails = [];
    // try {
    //   final sql = '''SELECT * FROM sales_taxes_details''';
    //   final rows = await db.rawQuery(sql);
    //   for (var index = 0; index < rows.length; index++) {
    //     Map<String, dynamic> row = rows[index];
    //     if (SalesTaxesDetails().validate(row).length > 0)
    //       salesTaxesDetails.add(SalesTaxesDetails.fromSqlite(row));
    //   }
    // } catch (e) {}

    // InvalidOpeningDetails invalidOpeningDetails = InvalidOpeningDetails(
    //     profile: profile,
    //     invalidData: invalidData,
    //     salesTaxesDetails: salesTaxesDetails);

    // BuildContext context = MyAppState.navigatorKey.currentState.overlay.context;

    // if (invalidData.firstWhere((e) => e.invalidItems.length > 0,
    //         orElse: () => null) !=
    //     null) {
    //   await DBService().dropTablesForSync(db, deleteOpeningDetails: true);
    //   Navigator.pushReplacementNamed(context, '/invalid-opening',
    //       arguments: invalidOpeningDetails);
    // } else
    //   Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> createOpeningsTable() async {
    await _dbOpeningDetails.dropAndCreateOpeningDetailsTable();
  }

  Future<void> signOut() async {
    await _dbOpeningDetails.dropOpeningDetailsTable();
    await _dbUser.dropUserTable();
    await _session.clear();
  }
}

// class InvalidOpeningDetails {
//   String profile;
//   List<InvalidData> invalidData;
//   List<SalesTaxesDetails> salesTaxesDetails;

//   InvalidOpeningDetails(
//       {this.profile, this.invalidData, this.salesTaxesDetails});
// }

// class InvalidData {
//   String title;
//   List invalidItems;

//   InvalidData({this.title, this.invalidItems});
// }
