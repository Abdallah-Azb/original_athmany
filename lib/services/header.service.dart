import 'dart:async';

import 'package:app/db-operations/db.opening.details.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/opening/models/opening.details.dart';
import 'package:app/services/accessory.service.dart';
import 'package:app/services/services.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class HeaderService {
  OpeningService _openingService = OpeningService();
  Future syncWithBackend() async {
    await InvoiceRepositoryRefactor().syncInvoices();
    await AccessoryService().syncAccessories();
    await DBService().dropTablesForSync(db);
    print("ahmed");
    OpeningDetails openingDetails =
        await DBOpeningDetails().getOpeningDetails();
    await _openingService.createOpeningFromOpeningsList(openingDetails);
  }

  Future changeLangueage(String local) async {
    String api = "/api/method/athmany.utils.api.change_language";
    print("API LANG =================== :$local");
    Map<String, dynamic> request = {"currentLanguage": local};
    try {
      final response = await ApiService().dio.post(api, data: request);
      if(response.statusCode == 200) {
        print("${response} for logOut API");
      }
    } on DioError catch (e, stackTrace) {
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      if (e.error is SocketException)
        throw Failure("check_your_internet_connection");
      if (e.error is TimeoutException) throw Failure("time_out");
      switch (e.response?.statusCode) {
        case 401:
          throw Failure("incorrect_data");
          break;
        case 500:
          throw Failure("many_wrong_login_data");
          break;
      }
      throw Failure("unexpected_error");
    }
  }
}
