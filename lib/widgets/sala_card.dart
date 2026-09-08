import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/sala_model.dart';
import 'status_indicator.dart';

/// Card de uma sala no Dashboard: nome, setor, quantidade de sensores
/// e o status geral (o pior status entre os sensores da sala).
class SalaCard extends StatelessWidget {
  final SalaComSensores salaComSensores;
  final VoidCallback? onTap;

  const SalaCard({super.key, required this.salaComSensores, this.onTap});

  @override
  Widget build(BuildContext context) {
    final sala = salaComSensores.sala;
    final status = salaComSensores.statusGeral;
    final color = statusColor(status.name);
    final totalSensores = salaComSensores.sensores.length;
    final alertasAtivos = salaComSensores.totalAlertas;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.meeting_room_outlined, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sala.nome,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sala.setor,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusIndicator(status: status, compact: true),
                        Text(
                          '$totalSensores sensor${totalSensores == 1 ? '' : 'es'}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                        if (alertasAtivos > 0)
                          Text(
                            '· $alertasAtivos alerta${alertasAtivos == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}