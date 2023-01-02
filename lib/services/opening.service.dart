import 'dart:convert';

import 'package:app/db-operations/db.opening.details.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/db-operations/db.tables.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/invoice/invoice.dart';
import 'package:app/modules/opening/models/models.dart';
import 'package:app/modules/opening/repositories/repositories.dart';
import 'package:app/services/api.service.dart';
import 'package:app/services/services.dart';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class OpeningService {
  OpeningRepository _openingRepository = OpeningRepository();

  // get opennings
  Future<List<OpeningDetails>> getOpeningsList() async {
    User user = await DBUser().getUser();
    List<OpeningDetails> openings = [];

    final request = {"user": user.userId};

    try {
      var response = await ApiService().dio.post(
          '/api/method/erpnext.selling.page.point_of_sale.point_of_sale.check_opening_entry',
          data: request);
      if (response.statusCode == 200) {
        List data = response.data['message'];
        for (var o in data) {
          OpeningDetails openingDetails = OpeningDetails(
            name: o['name'],
            company: o['company'],
            profile: o['pos_profile'],
            periodStartDate: o['period_start_date'],
          );
          openings.add(openingDetails);
        }
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    }
    return openings;
  }

  // get companies list (server can get the comapanies list from sid)
  Future<List<Company>> getCompaniesList() async {
    List<Company> companiesList = [];
    final request = {
      "txt": "",
      "doctype": "Company",
    };
    try {
      var response = await ApiService()
          .dio
          .post('/api/method/frappe.desk.search.search_link', data: request);
      if (response.statusCode == 200) {
        List data = response.data['results'];
        data.forEach((c) {
          final Company comapny = Company.fromServer(c);
          companiesList.add(comapny);
        });

        // print(data);
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
      throw e;
    }
    return companiesList;
  }

  // get profiles list (server can get the profiles list from sid)
  Future<List<Profile>> getProfiles(Company company) async {
    List<Profile> profilesList = [];
    final request = {
      "txt": "",
      "doctype": "POS Profile",
      "query":
          "erpnext.accounts.doctype.pos_profile.pos_profile.pos_profile_query",
      "filters": {"company": company.value}
    };
    try {
      var response = await ApiService()
          .dio
          .post('/api/method/frappe.desk.search.search_link', data: request);
      if (response.statusCode == 200) {
        List data = response.data['results'];
        List<OpeningDetails> openingsDetails = await getOpeningsList();
        data.forEach((p) {
          final Profile profile = Profile.fromServer(p);
          profilesList.add(profile);
          for (OpeningDetails opening in openingsDetails) {
            profilesList
                .removeWhere((element) => element.value == opening.profile);
          }
        });

        // print(data);
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      throw e;
    } catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      print(e);
      throw e;
    }
    return profilesList;
  }

  // get opening balance list
  Future<List<OpeningBalance>> getOpeningBalanceList(Profile profile) async {
    List<OpeningBalance> openingBalanceList = [];
    final request = {"doctype": "POS Profile", "name": profile.value};
    var response = await ApiService()
        .dio
        .post('/api/method/frappe.client.get', data: request);
    if (response.statusCode == 200) {
      List data = response.data['message']['payments'];
      data.forEach((p) {
        final OpeningBalance openingBalance = OpeningBalance.fromServer(p);
        openingBalanceList.add(openingBalance);
      });
    }
    return openingBalanceList;
  }

  // create opening voucher
  Future<OpeningDetails> createOpeningVoucher(Company company,
      Profile posProfile, List<OpeningBalance> openingBalanceList) async {
    OpeningDetails openingDetails;
    List<dynamic> openingAmounts = [];
    openingBalanceList.forEach((e) {
      openingAmounts.add({
        'mode_of_payment': e.modeOfPayment,
        'opening_amount': e.openingAmount
      });
    });
    User user = await DBUser().getUser();
    final request = {
      "docstatus": 1,
      "period_start_date": DateTime.now().toString(),
      "posting_date": DateTime.now().toString(),
      "company": company.value,
      "pos_profile": posProfile.value,
      "user": user.userId,
      // "balance_details": balanceDetails
      "balance_details": openingAmounts
    };
    var response = await ApiService()
        .dio
        .post('/api/resource/POS Opening Entry', data: request);
    if (response.statusCode == 200) {
      dynamic data = response.data['data'];
      openingDetails = OpeningDetails(
        periodStartDate: data['period_start_date'],
        name: data['name'],
        profile: data['pos_profile'],
        company: data['company'],
      );
      // await saveOpeningDetailsToSqlite(openingDetails);
      // await _openingRepository.handleOpening(posProfile, company);
    }
    return openingDetails;
  }

  // openingFromLogin
  Future createOpeningFromOpeningsList(OpeningDetails openingDetails) async {
    // List<OpeningDetails> openings = await getOpenings();
    print("check for customer gtoup1");
    // OpeningDetails openingDetails = OpeningDetails.fromMap(openings[0]);
    await saveOpeningDetailsToSqlite(openingDetails);
    Profile profile = Profile(value: openingDetails.profile, description: "");
    Company company = Company(value: openingDetails.company, description: "");
    await _openingRepository.handleOpening(profile, company);

    /////////////////
    List invoices = await ApiService().getPOSInvoices();
    // print(invoices);
    invoices.forEach((i) async {
      if (i['docstatus'] == 0 &&
          i['table_number'] != null &&
          i['table_number'].isNotEmpty) {
        await DBDineInTables().reserveTable(int.parse(i['table_number']));
      }

      if (i['docstatus'] == 0) {}
      // save invoice
      Map<String, dynamic> invoice = Invoice().fromServer(i);

      int invoiceId = await DBInvoice.addInvoiceFromServer(invoice);
      // save items
      List items = i['items'];
      items.forEach((it) async {
        if (it['is_sup'] == 0) {
          Map<String, dynamic> item =
              Item().fromServer(item: it, invoiceId: invoiceId);
          await DBInvoice.addItemOfFromServer(item);
          List itemOptions = jsonDecode(it['item_options']);
          if (itemOptions.length > 0) {
            itemOptions.forEach((e) async {
              Map<String, dynamic> map = {
                'item_unique_id': e['item_unique_id'],
                'parent': e['parent'],
                'item_code': e['item_code'],
                'item_name': e['item_name'],
                'price_list_rate': e['price_list_rate'],
                'option_with': e['option_with'],
                'selected': 1,
                'FK_item_option_invoice_id': invoiceId
              };
              await DBItemOptions().addItemOptionOfInvoiceFromServer(map);
            });
          }
        }
      });
      // save taxes
      List taxes = i['taxes'];
      taxes.forEach((t) async {
        Tax tax = Tax.fromSqlite(t);
        await DBInvoice.addTaxOfInvoice(tax, invoiceId);
      });
      //////
      // add payments

      List payments = i['payments'];
      payments.forEach((p) {
        Payment payment = Payment(
          defaultPaymentMode: p['default'],
          modeOfPayment: p['mode_of_payment'],
          type: p['type'],
          account: p['account'],
          amount: p['amount'],
          baseAmount: p['base_amount'],
        );
        DBInvoice.addPaymentOfInvoice(payment, invoiceId);
      });

      //////
      // add payments with 0 amount if invoice is not paid => docstatus = 0
      // if (i['docstatus'] == 0) {
      //   List<Payment> payments = [];
      //   List<PaymentMethod> paymentMethods =
      //       await DBPaymentMethod().getPaymentMethods();
      //   for (int i = 0; i < paymentMethods.length; i++) {
      //     Payment payment = Payment(
      //       defaultPaymentMode: paymentMethods[i].defaultPaymentMode,
      //       modeOfPayment: paymentMethods[i].modeOfPayment,
      //       icon: paymentMethods[i].icon,
      //       type: paymentMethods[i].type,
      //       account: paymentMethods[i].account,
      //       amount: 0,
      //       baseAmount: 0,
      //       amountStr: "0",
      //     );
      //     payments.add(payment);
      //   }
      //   payments.forEach((payment) {
      //     DBInvoice.addPaymentOfInvoice(payment, invoiceId);
      //   });
      // }
    });
  }

  // save opening details in sqlite
  Future<void> saveOpeningDetailsToSqlite(OpeningDetails openingDetails) async {
    // await DBOpeningDetails().dropAndCreateOpeningDetailsTable();
    await DBOpeningDetails().add(openingDetails);
  }
}
