import 'package:app/core/enums/enums.dart';

class CustomException implements Exception {
  final String message;
  final Exception e;
  final ErrorTypes type;

  CustomException({
    this.message,
    this.e,
    this.type,
  });
}
