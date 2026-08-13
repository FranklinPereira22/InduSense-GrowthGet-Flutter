import 'sensor_model.dart';

class AlertModel {
  final String id;
  final String sensorId;
  final String sensorNome;
  final SensorType tipo;
  final double valorMedido;
  final double limite;
  final DateTime dataHora;
  final bool lido;
  final SensorStatus severidade;

  AlertModel({
    required this.id,
    required this.sensorId,
    required this.sensorNome,
    required this.tipo,
    required this.valorMedido,
    required this.limite,
    required this.dataHora,
    required this.lido,
    required this.severidade,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'].toString(),
      sensorId: json['sensorId'].toString(),
      sensorNome: json['sensorNome'] ?? '',
      tipo: SensorTypeX.fromString(json['tipo'] ?? 'temperatura'),
      valorMedido: (json['valorMedido'] as num).toDouble(),
      limite: (json['limite'] as num).toDouble(),
      dataHora: DateTime.parse(json['dataHora']),
      lido: json['lido'] ?? false,
      severidade: SensorStatusX.fromString(json['severidade'] ?? 'atencao'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sensorId': sensorId,
        'sensorNome': sensorNome,
        'tipo': tipo.name,
        'valorMedido': valorMedido,
        'limite': limite,
        'dataHora': dataHora.toIso8601String(),
        'lido': lido,
        'severidade': severidade.value,
      };

  AlertModel copyWith({bool? lido}) {
    return AlertModel(
      id: id,
      sensorId: sensorId,
      sensorNome: sensorNome,
      tipo: tipo,
      valorMedido: valorMedido,
      limite: limite,
      dataHora: dataHora,
      lido: lido ?? this.lido,
      severidade: severidade,
    );
  }
}
