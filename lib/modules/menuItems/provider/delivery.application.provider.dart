import 'package:app/models/models.dart';
import 'package:flutter/material.dart';

class DeliveryApplicationProvider extends ChangeNotifier {
  DeliveryApplication selectedDeliveryApplication;

  void setSelectedDeliveryApplication(
      DeliveryApplication newDeliveryApplication) {
    selectedDeliveryApplication = newDeliveryApplication;
    notifyListeners();
  }

  void clearDeliveryApplication() {
    selectedDeliveryApplication = null;
    notifyListeners();
  }
}
