import 'package:app/modules/closing/models.dart/closing_report.dart';
import 'package:app/modules/closing/models.dart/stock_items.dart';

import 'models.dart';

class ClosingData {
  List<PosTransaction> posTransactions;
  List<PaymentReconciliation> paymentReconciliations;
  List<dynamic> stockItems = [];
  ClosingReport closingReportStock;
  List<dynamic> taxes;
  double grandTotal;
  double netTotal;
  double totalQuantity;

  List<Map<String, dynamic>> posTransactionstoMap(
      List<PosTransaction> posTransactions) {
    List<Map<String, dynamic>> posTransactionsMap = [];
    for (PosTransaction posTransaction in posTransactions) {
      Map<String, dynamic> map = <String, dynamic>{
        'pos_invoice': posTransaction.posInvoice,
        'posting_date': posTransaction.postingDate,
        'customer': posTransaction.customer,
        'grand_total': posTransaction.grandTotal
      };
      posTransactionsMap.add(map);
    }
    return posTransactionsMap;
  }

  List<Map<String, dynamic>> paymentReconciliationstoMap(
      List<PaymentReconciliation> paymentReconciliations) {
    List<Map<String, dynamic>> paymentReconciliationsMap = [];
    for (PaymentReconciliation paymentReconciliation
        in paymentReconciliations) {
      Map<String, dynamic> map = <String, dynamic>{
        'mode_of_payment': paymentReconciliation.modeOfPayment,
        'opening_amount': paymentReconciliation.openingAmount,
        'expected_amount': paymentReconciliation.expectedAmount,
        'closing_amount': paymentReconciliation.closingAmount
      };
      paymentReconciliationsMap.add(map);
    }
    return paymentReconciliationsMap;
  }
}

class StockItemModel {
  List<dynamic> stockItems;
}
