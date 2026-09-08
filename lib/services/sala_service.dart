import '../core/constants/api_constants.dart';
import '../models/sala_model.dart';
import '../models/sensor_model.dart';
import 'api_client.dart';
import 'mock_data_service.dart';
import 'sensor_service.dart';

/// Agrupa sensores por sala/setor físico da fábrica. Também resolve
/// a sala a partir da tag NFC lida na porta.
class SalaService {
  final ApiClient _client = ApiClient();
  final SensorService _sensorService = SensorService();

  Future<List<SalaModel>> getSalas() async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockDataService.salas;
    }
    final res = await _client.get(ApiConstants.salas);
    return (res as List).map((e) => SalaModel.fromJson(e)).toList();
  }

  /// Retorna todas as salas já com seus sensores e status agregado,
  /// pronto para exibir no Dashboard.
  Future<List<SalaComSensores>> getSalasComSensores() async {
    final salas = await getSalas();
    final sensores = await _sensorService.getSensors();
    return salas.map((sala) {
      final doSala = sensores.where((s) => s.salaId == sala.id).toList();
      return SalaComSensores(sala: sala, sensores: doSala);
    }).toList();
  }

  Future<List<SensorModel>> getSensoresPorSala(String salaId) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockDataService.sensors.where((s) => s.salaId == salaId).toList();
    }
    final res = await _client.get(ApiConstants.salaSensors(salaId));
    return (res as List).map((e) => SensorModel.fromJson(e)).toList();
  }

  Future<SalaModel> getSalaById(String id) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return MockDataService.salas.firstWhere((s) => s.id == id);
    }
    final res = await _client.get(ApiConstants.salaById(id));
    return SalaModel.fromJson(res);
  }

  /// Resolve a sala a partir do id gravado na tag NFC fixada na porta.
  /// Lança [ApiException] se nenhuma sala estiver associada à tag.
  Future<SalaModel> getSalaPorTagNfc(String tagId) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final sala = MockDataService.salas
          .where((s) => s.nfcTagId.toLowerCase() == tagId.toLowerCase())
          .toList();
      if (sala.isEmpty) {
        throw ApiException('Nenhuma sala cadastrada para esta tag NFC.');
      }
      return sala.first;
    }
    final res = await _client.get(ApiConstants.salaByNfcTag(tagId));
    return SalaModel.fromJson(res);
  }
}
