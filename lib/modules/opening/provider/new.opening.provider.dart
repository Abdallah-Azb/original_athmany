import 'package:app/modules/opening/models/models.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:flutter/material.dart';

class NewOpeningProvider extends ChangeNotifier {
  OpeningRepositoryRefactor _openingRepositoryRefactor =
      OpeningRepositoryRefactor();

  bool _loading = false;
  Company _selectedCompany;
  Profile _selectedProfile;
  List<Profile> _profilesList = [];
  List<OpeningBalance> _openingBalanceList = [];

  List<OpeningDetails> openingList = [];
  bool get loading => _loading;
  Company get selectedCompany => _selectedCompany;
  Profile get selectedProfile => _selectedProfile;
  List<Profile> get profilesList => _profilesList;
  List<OpeningBalance> get openingBalanceList => _openingBalanceList;

  void setLoadingValue(bool loadingValue) async {
    this._loading = loadingValue;
    notifyListeners();
  }

  void setSelectedCompany(Company value) {
    this._selectedCompany = value;
    setLoadingValue(true);
    notifyListeners();
    setProfilesList();
  }

   getOpeningList() async {
    openingList = await _openingRepositoryRefactor.getOpeningList();
    return openingList.length;
  }

  void setProfilesList() async {
    this._profilesList = [];
    this._profilesList =
        await _openingRepositoryRefactor.getProfilesList(selectedCompany);
    setLoadingValue(false);
    notifyListeners();
  }

  void setSelectedProfile(Profile value) {
    this._selectedProfile = value;
    setLoadingValue(true);
    notifyListeners();
    setOpeningBalanceList();
  }

  void setOpeningBalanceList() async {
    this._openingBalanceList = [];
    if (selectedProfile != null) {
      this._openingBalanceList = await _openingRepositoryRefactor
          .getOpeningBalanceList(selectedProfile);
      setLoadingValue(false);
      notifyListeners();
    }
  }
}
