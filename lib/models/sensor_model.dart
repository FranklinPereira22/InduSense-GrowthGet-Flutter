/// Tipos de grandeza monitorados pelos sensores ESP32/IoT.
enum SensorType { temperatura, umidade, qualidadeAr, gas }

extension SensorTypeX on SensorType {
  String get label {
    switch (this) {
      case SensorType.temperatura:
        return 'Temperatura';
      case SensorType.umidade:
        return 'Umidade';
      case SensorType.qualidadeAr:
        return 'Qualidade do Ar';
      case SensorType.gas:
        return 'Gases';
    }
  }

  String get unidade {
    switch (this) {
      case SensorType.temperatura:
        return '°C';
      case SensorType.umidade:
        return '%';
      case SensorType.qualidadeAr:
        return 'IQA';
      case SensorType.gas:
        return 'ppm';
    }
  }

  static SensorType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'temperatura':
        return SensorType.temperatura;
      case 'umidade':
        return SensorType.umidade;
      case 'qualidade_ar':
      case 'qualidadear':
        return SensorType.qualidadeAr;
      case 'gas':
      case 'gases':
        return SensorType.gas;
      default:
        return SensorType.temperatura;
    }
  }
}

/// Status atual do sensor.
enum SensorStatus { normal, atencao, critico, offline }

extension SensorStatusX on SensorStatus {
  String get value => toString().split('.').last;

  static SensorStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'normal':
        return SensorStatus.normal;
      case 'atencao':
      case 'atenção':
        return SensorStatus.atencao;
      case 'critico':
      case 'crítico':
        return SensorStatus.critico;
      default:
        return SensorStatus.offline;
    }
  }
}

class SensorModel {
  final String id;
  final String nome;
  final String localizacao;
  final String salaId;
  final SensorType tipo;
  final SensorStatus status;
  final double valorAtual;
  final double limiteMin;
  final double limiteMax;
  final DateTime ultimaLeitura;
  final bool online;

  SensorModel({
    required this.id,
    required this.nome,
    required this.localizacao,
    required this.salaId,
    required this.tipo,
    required this.status,
    required this.valorAtual,
    required this.limiteMin,
    required this.limiteMax,
    required this.ultimaLeitura,
    required this.online,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'].toString(),
      nome: json['nome'] ?? '',
      localizacao: json['localizacao'] ?? '',
      salaId: json['salaId']?.toString() ?? '',
      tipo: SensorTypeX.fromString(json['tipo'] ?? 'temperatura'),
      status: SensorStatusX.fromString(json['status'] ?? 'offline'),
      valorAtual: (json['valorAtual'] as num).toDouble(),
      limiteMin: (json['limiteMin'] as num).toDouble(),
      limiteMax: (json['limiteMax'] as num).toDouble(),
      ultimaLeitura: DateTime.parse(json['ultimaLeitura']),
      online: json['online'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'localizacao': localizacao,
        'salaId': salaId,
        'tipo': tipo.name,
        'status': status.value,
        'valorAtual': valorAtual,
        'limiteMin': limiteMin,
        'limiteMax': limiteMax,
        'ultimaLeitura': ultimaLeitura.toIso8601String(),
        'online': online,
      };
}
