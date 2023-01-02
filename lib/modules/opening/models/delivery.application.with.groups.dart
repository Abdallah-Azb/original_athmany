import 'package:app/models/models.dart';

import '../opening.dart';

class DeliveryApplicationWithGroupsAndItems {
  final DeliveryApplication deliveryApplication;
  final List<GroupWithItems> groupsWithItems;

  DeliveryApplicationWithGroupsAndItems({
    this.deliveryApplication,
    this.groupsWithItems,
  });
}
