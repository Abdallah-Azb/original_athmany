import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/services/services.dart';

class HeaderRepository {
  HeaderService _headerService = HeaderService();

  Future syncWithBackend() async {
    print("ibra");
    await _headerService.syncWithBackend();
  }

  Future changeLanguage(String local) async {
    print("${local} local !");
    await _headerService.changeLangueage(local);
  }

  Future syncInvoices() async {
    await InvoiceRepositoryRefactor().syncInvoices();
  }
}
