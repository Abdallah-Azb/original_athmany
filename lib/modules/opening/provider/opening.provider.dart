import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/modules/opening/repositories/repositories.dart';
import 'package:app/services/opening.service.dart';
import 'package:flutter/material.dart';

class OpeningProvider extends ChangeNotifier {
  // OpeningService _openingService = OpeningService();
  // OpeningRepository _openingRepository = OpeningRepository();
  // bool _loading = true;
  // List<Profile> _profilesList = [];
  // List<OpeningBalance> _openingBalanceList = [];
  // List<OpeningDetails> openignsList = [];

  // Company _company;
  // Profile _profile;

  // bool get loading => _loading;
  // List<Profile> get profilesList => _profilesList;
  // List<OpeningBalance> get openingBalanceList => _openingBalanceList;

  // Company get company => _company;
  // Profile get profile => _profile;

  // // set profiles list
  // void setProfileList() async {
  //   this._profilesList = [];
  //   this._profilesList = await getProfilesList(company);
  //   notifyListeners();
  // }

  // // set loading value
  // void setLoadingValue(bool loadingValue) async {
  //   this._loading = loadingValue;
  //   notifyListeners();
  // }

  // // set opening balance list
  // void setOpeningBalanceList() async {
  //   this._openingBalanceList = [];
  //   if (profile != null) {
  //     this._openingBalanceList =
  //         await OpeningService().getOpeningBalanceList(profile);
  //     notifyListeners();
  //   }
  // }

  // // set company
  // void setCompany(Company value) {
  //   this._company = value;
  //   notifyListeners();
  //   setProfileList();
  // }

  // // set profile
  // void setProfile(Profile value) {
  //   this._profile = value;
  //   notifyListeners();
  //   setOpeningBalanceList();
  // }

  // // get companies list
  // Future<List<Company>> getCompaniesList() async {
  //   try {
  //     List<Company> companiesList = await OpeningService().getCompaniesList();
  //     setLoadingValue(false);
  //     return companiesList;
  //   } catch (e) {}
  //   return null;
  // }

  // // get profiles list
  // Future<List<Profile>> getProfilesList(Company company) async {
  //   try {
  //     List<Profile> profilesList = await OpeningService().getProfiles(company);
  //     setLoadingValue(false);
  //     return profilesList;
  //   } catch (e) {}
  //   return null;
  // }

  // Future<void> getOpenings() async {
  //   List<OpeningDetails> openings = await _openingService.getOpeningsList();
  //   openignsList = openings;
  //   setLoadingValue(false);
  // }

  // Future<void> selectOpening(
  //     BuildContext context, OpeningDetails openingDetails) async {
  //   setLoadingValue(true);
  //   try {
  //     await _openingService.createOpeningFromOpeningsList(openingDetails);
  //     await OpeningRepository().validateOpening(openingDetails.profile);
  //   } catch (_) {
  //     setLoadingValue(false);
  //   }
  // }

  // Future signout(context) async {
  //   await _openingRepository.signOut();
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
  //     ModalRoute.withName('/'),
  //   );
  // }

  // void clearOpening() {
  //   this._company = null;
  //   this._profilesList = [];
  //   this._openingBalanceList = [];
  // }
}
