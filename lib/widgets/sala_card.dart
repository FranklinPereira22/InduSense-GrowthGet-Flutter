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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)), // Borda neutra corporativa
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // Fundo neutro Slate
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.factory_outlined, // Ícone industrial
                    color: Color(0xFF1E293B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sala.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sala.setor,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusIndicator(status: status, compact: true),
                          Text(
                            '$totalSensores sensor${totalSensores == 1 ? '' : 'es'}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          if (alertasAtivos > 0)
                            Text(
                              '· $alertasAtivos alerta${alertasAtivos == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}