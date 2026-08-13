import '../core/constants/api_constants.dart';
import '../models/alert_model.dart';
import 'api_client.dart';
import 'mock_data_service.dart';

/// Alertas: parâmetro excedido, valor medido, limite, data/hora e
/// status lido/não lido.
class AlertService {
  final ApiClient _client = ApiClient();

  Future<List<AlertModel>> getAlerts() async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      return List.of(MockDataService.alerts);
    }
    final res = await _client.get(ApiConstants.alerts);
    return (res as List).map((e) => AlertModel.fromJson(e)).toList();
  }

  Future<void> marcarComoLido(String alertId) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    await _client.patch(ApiConstants.alertRead(alertId));
  }
}
