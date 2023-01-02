import 'package:dio/dio.dart';

class ApiUtils {
  String baseUrl;

  Future<String> getBaseUrl(String accountNumber) async {
    String _baseUrl;

    final Response response = await Dio().post(
      'http://athmany.tech/api/method/bench_manager.bench_manager.doctype.site_url.site_url.get_url',
      data: {"account_number": accountNumber},
    );

    if (response.statusCode == 200) {
      _baseUrl = response.data['message'];
      baseUrl = _baseUrl;
    }

    return _baseUrl;
  }

  bool get isBaseUrlValid =>
      baseUrl != null && baseUrl != 'Account number does not exist';
}
