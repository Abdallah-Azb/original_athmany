import 'package:provider/provider.dart';
import 'package:app/modules/closing/provider/provider.dart';
import 'package:app/modules/customer/customer.dart';
import 'package:app/modules/menuItems/menu.item.dart';
import 'package:app/modules/pay-dialog/pay.dialog.provider.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/services/print-service/new_service_print/printer_service_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'modules/accessories/provider/accessory.provider.dart';
import 'modules/customer-refactor/Provider/Territory.dart';
import 'modules/header/header.dart';
import 'modules/invoice/invoice.dart';
import 'modules/opening/provider/new.opening.provider.dart';
import 'modules/return/provider/return.invioce.proivder.dart';
import 'modules/tables/tables.dart';
import 'pages/home/menu/qty.dialog/qty.dialog.provider.dart';
import 'providers/providers.dart';


class Providers {

  var providers = [
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
    ),
    ChangeNotifierProvider<PrinterServicesProvider>(
      create: (_) => PrinterServicesProvider(),
    ),
    ChangeNotifierProvider<MenuItemProvider>(
      create: (_) => MenuItemProvider(),
    ),
    ChangeNotifierProvider<DeliveryApplicationProvider>(
      create: (_) => DeliveryApplicationProvider(),
    ),
    ChangeNotifierProvider<HomeProvider>(
      create: (_) => HomeProvider(),
    ),
    ChangeNotifierProvider<InvoiceProvider>(
      create: (_) => InvoiceProvider(),
    ),
    ChangeNotifierProvider<ReturnInvoiceProvider>(
      create: (_) => ReturnInvoiceProvider(),
    ),
    ChangeNotifierProvider<TablesProvider>(
      create: (_) => TablesProvider(),
    ),
    ChangeNotifierProvider<HeaderProvider>(
      create: (_) => HeaderProvider(),
    ),
    ChangeNotifierProvider<PayDialogProvider>(
      create: (_) => PayDialogProvider(),
    ),
    ChangeNotifierProvider<ClosingProvider>(
      create: (_) => ClosingProvider(),
    ),
    ChangeNotifierProvider<CustomersProvider>(
      create: (_) => CustomersProvider(),
    ),
    ChangeNotifierProvider<QtyDialogProvider>(
      create: (_) => QtyDialogProvider(),
    ),
    ChangeNotifierProvider<AccessoryModel>(
      create: (_) => AccessoryModel(),
    ),
    ChangeNotifierProvider<DropdownListsProvider>(
      create: (_) => DropdownListsProvider(),
    ),
    ChangeNotifierProvider<TypeMobileProvider>(
      create: (_) => TypeMobileProvider(),
    ),
    ChangeNotifierProvider<NewOpeningProvider>(
      create: (_) => NewOpeningProvider(),
    ),
  ];
}