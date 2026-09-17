import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../models/sensor_model.dart';
import 'status_indicator.dart';

IconData _iconForType(SensorType tipo) {
  switch (tipo) {
    case SensorType.temperatura:
      return Icons.thermostat_rounded;
    case SensorType.umidade:
      return Icons.water_drop_rounded;
    case SensorType.qualidadeAr:
      return Icons.air_rounded;
    case SensorType.gas:
      return Icons.sensors_rounded;
  }
}

class SensorCard extends StatelessWidget {
  final SensorModel sensor;
  final VoidCallback? onTap;

  const SensorCard({super.key, required this.sensor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_iconForType(sensor.tipo), size: 16, color: const Color(0xFF0EA5E9)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sensor.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    sensor.online
                        ? '${sensor.valorAtual.toStringAsFixed(1)} ${sensor.tipo.unidade}'
                        : '—',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: sensor.online ? null : AppColors.statusOffline,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusIndicator(status: sensor.status, compact: true),
                    const SizedBox(height: 6),
                    Text(
                      'Atualizado ${DateFormat('HH:mm').format(sensor.ultimaLeitura)}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}