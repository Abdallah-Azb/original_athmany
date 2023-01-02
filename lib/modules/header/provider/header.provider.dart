import 'dart:async';
import 'dart:io';

import 'package:app/core/utils/utils.dart';
import 'package:app/db-operations/db.invoice.refactor.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/auth/repositories/auth.repository.refactor.dart';
import 'package:app/modules/header/header.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/providers/providers.dart';
import 'package:app/services/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../main.dart';

class HeaderProvider extends ChangeNotifier {
  HeaderRepository _headerRepository = HeaderRepository();
  Session _session = Session();

  Future syncWithBackend(context, updatePageLoading) async {
    // try {
    //   final result = await InternetAddress.lookup('example.com');
    //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
    //     print('connected');
    //   }
    // } on SocketException catch (_) {
    //   print('not connected');
    // }

    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
      updatePageLoading(true);
      await _headerRepository.syncWithBackend();
      Phoenix.rebirth(context);
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      updatePageLoading(false);
      if (e.error is SocketException || e.error is TimeoutException)
        toast('Check your internet connection', Colors.red);
      else {
        print(e.message);
        toast('Server Error', Colors.red);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
      toast('Someting went wrong', Colors.red);
      updatePageLoading(false);
    }
  }

  Future syncInvoices(context) async {
    try {
      HomeProvider homeProvider = Provider.of(context, listen: false);
      await _headerRepository.syncInvoices();
      List<Invoice> savedInvocies =
          await DBInvoiceRefactor().getSavedInvoices();
      if (savedInvocies.length > 0) {
        showUnpaidInvoicesWarning(context);
      } else {
        homeProvider.setMainIndex(2);
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException || e.error is TimeoutException) {
        toast('Check you internet connection', Colors.red);
      }
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      toast('Error occurred', Colors.red);
    }
  }

  Future<void> showUnpaidInvoicesWarning(context) async {
    var result = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ConfirmDialog(
          acceptText: Localization.of(context).tr('go_to_unpaid_invoices'),
          icon: Image.asset('assets/unpaid-invoices.png'),
          onConfirm: () async {
            Navigator.pop(context, true);
          },
          bodyText: Localization.of(context).tr('unpaid_invoiecs_warning'),
        );
      },
    );
    if (result == true) {
      HomeProvider homeProvider = Provider.of(context, listen: false);
      homeProvider.setMainIndex(1);
    }
  }

  Future confirmSignout(context) async {
    bool result = await showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        acceptText: "Yes",
        cancelText: "Cancel",
        bodyText: "Confirm sigout",
        onConfirm: () async {
          Navigator.pop(context, true);
        },
      ),
    );
    if (result) signout(context);
  }

  Future signout(context) async {
    var isNotSynced = await DBInvoiceRefactor().checkIfInvoicesNotSynced();

    if (isNotSynced) {
      await showDialog(
        context: context,
        builder: (context) => ConfirmDialog(
          acceptText: "Try again",
          cancelText: "Cancel",
          bodyText: "Make sure all invoices are synced",
          onConfirm: () async {
            Navigator.pop(context);
            await signout(context);
          },
        ),
      );
    } else {
      InvoiceProvider invoice =
          Provider.of<InvoiceProvider>(context, listen: false);

      await invoice.resetAll(context, logout: true);
      await await _session.clear();
      await DBService().dropAllTables(db);
      await AuthRepositoryRefactor().logOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
        ModalRoute.withName('/'),
      );
    }
  }

  void setLocale(BuildContext context, Locale locale, String lang) {
    MyAppState state = context.findAncestorStateOfType<MyAppState>();
    state.setAndSaveLocale(locale);
    _headerRepository.changeLanguage(lang);
  }
}
