import 'dart:io';
import 'package:app/core/utils/dialog/confirm_dialog.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/localization/localization.dart';
import 'package:app/services/auth.service.dart';
import 'package:app/services/db.service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/services/cache.item.image.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sentry/sentry.dart';

class DBOpening {
  DBCompanyDetails _dbCompanyDetails = DBCompanyDetails();
  DBProfileDetails _dbProfileDetails = DBProfileDetails();
  DBSalesTaxesDetails _dbSalesTaxesDetails = DBSalesTaxesDetails();
  DBPaymentMethod _dbPaymentMethod = DBPaymentMethod();
  DBDineInTables _dbDineInTables = DBDineInTables();
  DBCustomer _dbCustomer = DBCustomer();
  DBItemsGroup _dbItemsGroup = DBItemsGroup();
  DBItems _dbItems = DBItems();
  DBItemOfGroup _dbItemOfGroup = DBItemOfGroup();
  DBAccessory _dbAccessory = DBAccessory();
  DBInvoiceRefactor _dbInvoice = DBInvoiceRefactor();
  DBTaxes _dbTaxes = DBTaxes();
  DBPayments _dbPayments = DBPayments();
  DBDeliveryApplication _dbDeliveryApplication = DBDeliveryApplication();
  DBCategoriesAccessories _dbCategoriesAccessories = DBCategoriesAccessories();
  DBItemOptions _dbItemOptions = DBItemOptions();

  Future initProfileTables() async {
    try {
      await Future.wait([
        // opening details tables
        // _dbOpeningDetails.create(),
        _dbCompanyDetails.create(),
        _dbProfileDetails.create(),
        _dbSalesTaxesDetails.create(),
        _dbPaymentMethod.create(),
        _dbDineInTables.create(),
        _dbCustomer.create(),
        _dbItemOfGroup.create(),
        _dbItemOptions.create(),
        _dbItemsGroup.create(),
        _dbCategoriesAccessories.create(),

        // opening data tables
        _dbAccessory.create(),
        _dbInvoice.create(),
        _dbItems.create(),
        _dbTaxes.create(),
        _dbPayments.create(),
        _dbDeliveryApplication.create(),
      ]);
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure(e.toString());
    }
  }

  Future initDynamicTables(OpeningModel openingModel) async {
    try {
      await _dbItemOfGroup
          .createDeliveryApplicationsTables(openingModel.deliveryApplicationWithGroupsAndItems);
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw Failure(e.toString());
    }
  }

  Future saveDataToTables(OpeningModel openingModel, {bool cachItmesImages: false}) async {
    try {
      await Future.wait([
        _dbCompanyDetails.add(openingModel.companyDetails),
        _dbProfileDetails.add(openingModel.profileDetails),
        _dbPaymentMethod.addAll(openingModel.paymentMethods),
        _dbCustomer.add(openingModel.defaultCustomer),
        _dbSalesTaxesDetails.addAll(openingModel.salesTaxesList),
        _dbDeliveryApplication.addAll(openingModel.deliveryApplications),
        _dbItemsGroup.addGroupWithItems(openingModel.groupsWithItems, cachItmesImages: cachItmesImages),
        _dbDeliveryApplication.addGroupWithItems(
            openingModel.deliveryApplicationWithGroupsAndItems),
        _dbDineInTables.addAll(openingModel.tables),
      ]);
      await _dbAccessory.addAll(openingModel.accessories);
    } on DatabaseException catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      await DBService().dropTablesForSync(db, deleteOpeningDetails: true);
      throw Failure("saveDataToTables Error :::: $e :::: stackTrace :::: $stackTrace");
    }
  }

  Future showAlertMessage(context, {String message}) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (dialogContext) {
        return ConfirmDialog(
          showCancelBtn: false,
          icon: Image.asset('assets/icons/warning.png'),
          onConfirm: () async {
            Navigator.pop(dialogContext);
          },
          bodyText: message == null
              ? Localization.of(context).tr('user_permissions')
              : message,
        );
      },
    );
  }

  Future createCachingFolders() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    await Directory(appDocumentsDirectory.path + '/payment-methods')
        .create(recursive: true);
    await Directory(appDocumentsDirectory.path + '/items')
        .create(recursive: true);
    await Directory(appDocumentsDirectory.path + '/invoice-logo')
        .create(recursive: true);
  }

  Future cacheImages(OpeningModel openingModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (openingModel.profileDetails.posLogo != null &&
        openingModel.profileDetails.posLogo != '') {
      await CacheItemImageService().cacheImage(
          "${prefs.getString('base_url')}/${openingModel.profileDetails.posLogo}",
          'invoice-logo');
    }
    for (var payment in openingModel.paymentMethods) {
      if (payment.icon != null && payment.icon.isNotEmpty) {
        await CacheItemImageService().cacheImage(
            "${prefs.getString('base_url')}/${payment.icon}",
            '${payment.modeOfPayment.replaceAll(new RegExp(r"\s+\b|\b\s"), "")}');
      }
    }
  }
}
