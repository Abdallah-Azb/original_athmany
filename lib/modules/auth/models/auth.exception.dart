class AuthException {
  String message;
  String type;
  Error e;

  AuthException({
    this.message,
    this.type,
    this.e,
  });
}

class MyException {
  String message;
  String type;
  Error e;

  MyException({
    this.message,
    this.type,
    this.e,
  });
}
