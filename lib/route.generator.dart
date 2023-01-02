import 'package:app/modules/opening/opening.dart';
import 'package:app/modules/opening/pages/invalid.opening.page.dart';
import 'package:app/modules/return/pages/return.page.dart';
import 'package:app/pages/invoices-list/invoices.list.dart';
import 'package:app/pages/pages.dart';
import 'package:flutter/material.dart';

import 'modules/auth/auth.dart';
import 'modules/auth/get.session.id.dart';
import 'modules/opening/pages/check.opening.details.page.page.dart';
import 'modules/opening/pages/get.openigns.list.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {

////////////////////////////////////
////////////////////////////////////
////////////////////////////////////
      case '/':
        return MaterialPageRoute(builder: (_) => GetSessionId());

      case '/login-page':
        return MaterialPageRoute(builder: (_) => LoginPage());

      case '/return-invioce':
        return MaterialPageRoute(
            builder: (context) => ReturnPage(invoice: args));

      // case '/return-invioce':
      //   if (args is String) {
      //     return MaterialPageRoute(
      //         builder: (context) => ReturnPage(name: args));
      //   }

      //   return MaterialPageRoute(builder: (_) => ReturnPage());

      case '/opening':
        return MaterialPageRoute(builder: (_) => CheckOpeningDetailsPage());

      case '/new-opening':
        bool goBack = settings.arguments;
        return MaterialPageRoute(builder: (_) => NewOpeningPage(goBack));

      case '/opening-list':
        return MaterialPageRoute(builder: (_) => GetOpeningsList());

      case '/invalid-opening':
        return MaterialPageRoute(
            builder: (_) => InvalidOpeningPage(invalidOpeningDetails: args));

      case '/invoices-list':
        return MaterialPageRoute(builder: (_) => InvoicesList());

      case '/home':
        return MaterialPageRoute(builder: (_) => Home());

////////////////////////////////////
////////////////////////////////////
////////////////////////////////////
///////////// default
      default:
        return _errorRoute();
    }
  }

  // error route
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
