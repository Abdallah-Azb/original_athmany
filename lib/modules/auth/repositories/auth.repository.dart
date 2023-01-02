// import 'package:app/modules/opening/models/opening.details.dart';
// import 'package:app/services/services.dart';

// import '../auth.dart';

// class AuthRepository {
//   AuthService _authService = AuthService();
//   OpeningService _openingService = OpeningService();

//   Future<User> login(String email, String password) async {
//     var user = _authService.login(email, password);

//     return user;
//   }

//   Future<String> getLoggedInUser() async {
//     return await _authService.getLoggedInUser();
//   }

//   Future<List> getOpenings() async {
//     return await _openingService.getOpeningsList();
//   }

//   Future openingFromLogin(OpeningDetails openingDetails) async {
//     await _openingService.createOpeningFromOpeningsList(openingDetails);
//   }
// }
