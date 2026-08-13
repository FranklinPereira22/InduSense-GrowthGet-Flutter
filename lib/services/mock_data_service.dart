import '../models/alert_model.dart';
import '../models/reading_model.dart';
import '../models/sensor_model.dart';
import '../models/user_model.dart';

/// Dados fictícios usados enquanto a API real não está disponível.
/// Mantém o mesmo formato/contrato dos endpoints reais, para que a
/// troca por [ApiClient] não exija mudanças nas telas.
class MockDataService {
  static final UserModel _mockUser = UserModel(
    id: 'u1',
    nome: 'Carlos Andrade',
    email: 'carlos.andrade@growthget.com',
    cargo: 'Engenheiro de Processos',
    empresa: 'Growth Get Indústria',
  );

  static UserModel get mockUser => _mockUser;

  static List<SensorModel> get sensors {
    final now = DateTime.now();
    return [
      SensorModel(
        id: 's1',
        nome: 'Sensor Temp — Linha A',
        localizacao: 'Galpão 1 · Linha de Produção A',
        tipo: SensorType.temperatura,
        status: SensorStatus.normal,
        valorAtual: 24.6,
        limiteMin: 15,
        limiteMax: 35,
        ultimaLeitura: now.subtract(const Duration(minutes: 1)),
        online: true,
      ),
      SensorModel(
        id: 's2',
        nome: 'Sensor Umidade — Estoque',
        localizacao: 'Galpão 2 · Estoque Químico',
        tipo: SensorType.umidade,
        status: SensorStatus.atencao,
        valorAtual: 78.0,
        limiteMin: 30,
        limiteMax: 70,
        ultimaLeitura: now.subtract(const Duration(minutes: 3)),
        online: true,
      ),
      SensorModel(
        id: 's3',
        nome: 'Qualidade do Ar — Solda',
        localizacao: 'Galpão 1 · Setor de Solda',
        tipo: SensorType.qualidadeAr,
        status: SensorStatus.critico,
        valorAtual: 168,
        limiteMin: 0,
        limiteMax: 100,
        ultimaLeitura: now.subtract(const Duration(minutes: 2)),
        online: true,
      ),
      SensorModel(
        id: 's4',
        nome: 'Sensor Gás — Caldeira',
        localizacao: 'Casa de Máquinas',
        tipo: SensorType.gas,
        status: SensorStatus.normal,
        valorAtual: 12.4,
        limiteMin: 0,
        limiteMax: 50,
        ultimaLeitura: now.subtract(const Duration(minutes: 1)),
        online: true,
      ),
      SensorModel(
        id: 's5',
        nome: 'Sensor Temp — Câmara Fria',
        localizacao: 'Galpão 3 · Câmara Fria',
        tipo: SensorType.temperatura,
        status: SensorStatus.offline,
        valorAtual: 0,
        limiteMin: -10,
        limiteMax: 8,
        ultimaLeitura: now.subtract(const Duration(hours: 5)),
        online: false,
      ),
      SensorModel(
        id: 's6',
        nome: 'Sensor Gás — Pintura',
        localizacao: 'Galpão 2 · Cabine de Pintura',
        tipo: SensorType.gas,
        status: SensorStatus.atencao,
        valorAtual: 41.2,
        limiteMin: 0,
        limiteMax: 40,
        ultimaLeitura: now.subtract(const Duration(minutes: 4)),
        online: true,
      ),
    ];
  }

  static List<ReadingModel> readings({String? sensorId, SensorType? tipo}) {
    final now = DateTime.now();
    final all = <ReadingModel>[];
    for (final sensor in sensors) {
      for (int i = 0; i < 24; i++) {
        final variance = (i % 5) - 2;
        all.add(ReadingModel(
          id: '${sensor.id}-r$i',
          sensorId: sensor.id,
          sensorNome: sensor.nome,
          tipo: sensor.tipo,
          valor: sensor.valorAtual + variance,
          dataHora: now.subtract(Duration(hours: i)),
          status: sensor.status,
        ));
      }
    }
    return all.where((r) {
      if (sensorId != null && r.sensorId != sensorId) return false;
      if (tipo != null && r.tipo != tipo) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
  }

  static List<AlertModel> get alerts {
    final now = DateTime.now();
    return [
      AlertModel(
        id: 'a1',
        sensorId: 's3',
        sensorNome: 'Qualidade do Ar — Solda',
        tipo: SensorType.qualidadeAr,
        valorMedido: 168,
        limite: 100,
        dataHora: now.subtract(const Duration(minutes: 2)),
        lido: false,
        severidade: SensorStatus.critico,
      ),
      AlertModel(
        id: 'a2',
        sensorId: 's2',
        sensorNome: 'Sensor Umidade — Estoque',
        tipo: SensorType.umidade,
        valorMedido: 78,
        limite: 70,
        dataHora: now.subtract(const Duration(minutes: 30)),
        lido: false,
        severidade: SensorStatus.atencao,
      ),
      AlertModel(
        id: 'a3',
        sensorId: 's6',
        sensorNome: 'Sensor Gás — Pintura',
        tipo: SensorType.gas,
        valorMedido: 41.2,
        limite: 40,
        dataHora: now.subtract(const Duration(hours: 1, minutes: 10)),
        lido: true,
        severidade: SensorStatus.atencao,
      ),
      AlertModel(
        id: 'a4',
        sensorId: 's5',
        sensorNome: 'Sensor Temp — Câmara Fria',
        tipo: SensorType.temperatura,
        valorMedido: 0,
        limite: 8,
        dataHora: now.subtract(const Duration(hours: 5)),
        lido: true,
        severidade: SensorStatus.offline,
      ),
    ];
  }
}
