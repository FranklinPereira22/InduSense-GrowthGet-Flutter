import 'sensor_model.dart';

/// Um registro histórico de leitura de um sensor.
class ReadingModel {
  final String id;
  final String sensorId;
  final String sensorNome;
  final SensorType tipo;
  final double valor;
  final DateTime dataHora;
  final SensorStatus status;

  ReadingModel({
    required this.id,
    required this.sensorId,
    required this.sensorNome,
    required this.tipo,
    required this.valor,
    required this.dataHora,
    required this.status,
  });

  factory ReadingModel.fromJson(Map<String, dynamic> json) {
    return ReadingModel(
      id: json['id'].toString(),
      sensorId: json['sensorId'].toString(),
      sensorNome: json['sensorNome'] ?? '',
      tipo: SensorTypeX.fromString(json['tipo'] ?? 'temperatura'),
      valor: (json['valor'] as num).toDouble(),
      dataHora: DateTime.parse(json['dataHora']),
      status: SensorStatusX.fromString(json['status'] ?? 'normal'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sensorId': sensorId,
        'sensorNome': sensorNome,
        'tipo': tipo.name,
        'valor': valor,
        'dataHora': dataHora.toIso8601String(),
        'status': status.value,
      };
}
