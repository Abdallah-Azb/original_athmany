import 'package:app/models/models.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/modules/customer-refactor/models/customer.dart';
import 'package:app/modules/tables/tables.dart';

import '../opening.dart';

class OpeningModel {
  final OpeningDetails openingDetails;
  final CompanyDetails companyDetails;
  final Customer defaultCustomer;
  final ProfileDetails profileDetails;
  final List<PaymentMethod> paymentMethods;
  final List<SalesTaxesDetails> salesTaxesList;
  final List<GroupWithItems> groupsWithItems;
  final List<DeliveryApplicationWithGroupsAndItems>
      deliveryApplicationWithGroupsAndItems;
  final List<Accessory> accessories;
  final List<TableModel> tables;
  final List<DeliveryApplication> deliveryApplications;

  OpeningModel({
    this.openingDetails,
    this.companyDetails,
    this.defaultCustomer,
    this.profileDetails,
    this.paymentMethods,
    this.salesTaxesList,
    this.groupsWithItems,
    this.accessories,
    this.tables,
    this.deliveryApplicationWithGroupsAndItems,
    this.deliveryApplications,
  });
}
