import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../models/sensor_model.dart';
import 'status_indicator.dart';

IconData _iconForType(SensorType tipo) {
  switch (tipo) {
    case SensorType.temperatura:
      return Icons.thermostat_outlined;
    case SensorType.umidade:
      return Icons.water_drop_outlined;
    case SensorType.qualidadeAr:
      return Icons.air_outlined;
    case SensorType.gas:
      return Icons.cloud_outlined;
  }
}

/// Card usado no Dashboard e em listagens, exibindo o valor atual,
/// status e última leitura de um sensor.
class SensorCard extends StatelessWidget {
  final SensorModel sensor;
  final VoidCallback? onTap;

  const SensorCard({super.key, required this.sensor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(sensor.status.value);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_iconForType(sensor.tipo), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          sensor.localizacao,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sensor.online
                        ? '${sensor.valorAtual.toStringAsFixed(1)} ${sensor.tipo.unidade}'
                        : '—',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  StatusIndicator(status: sensor.status, compact: true),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Atualizado às ${DateFormat('HH:mm').format(sensor.ultimaLeitura)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
