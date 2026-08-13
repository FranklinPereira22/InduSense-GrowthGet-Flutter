import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/sensor_model.dart';

String statusLabel(SensorStatus status) {
  switch (status) {
    case SensorStatus.normal:
      return 'Normal';
    case SensorStatus.atencao:
      return 'Atenção';
    case SensorStatus.critico:
      return 'Crítico';
    case SensorStatus.offline:
      return 'Offline';
  }
}

/// Pílula colorida indicando o status de um sensor/alerta.
class StatusIndicator extends StatelessWidget {
  final SensorStatus status;
  final bool compact;

  const StatusIndicator({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status.value);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            statusLabel(status),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
