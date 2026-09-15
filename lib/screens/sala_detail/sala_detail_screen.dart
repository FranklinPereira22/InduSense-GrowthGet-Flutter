import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sala_model.dart';
import '../../models/sensor_model.dart';
import '../../services/sala_service.dart';
import '../../widgets/sensor_card.dart';
import '../../widgets/state_widgets.dart';

class SalaDetailScreen extends StatefulWidget {
  final String salaId;
  const SalaDetailScreen({super.key, required this.salaId});

  @override
  State<SalaDetailScreen> createState() => _SalaDetailScreenState();
}

class _SalaDetailScreenState extends State<SalaDetailScreen> {
  final SalaService _salaService = SalaService();

  SalaModel? _sala;
  List<SensorModel>? _sensores;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final sala = await _salaService.getSalaById(widget.salaId);
      final sensores = await _salaService.getSensoresPorSala(widget.salaId);
      if (!mounted) return;
      setState(() {
        _sala = sala;
        _sensores = sensores;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os sensores da sala.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_sala?.nome ?? 'Ambiente')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) return const LoadingWidget(mensagem: 'Sincronizando ambiente...');
    if (_erro != null) return AppErrorWidget(mensagem: _erro!, onRetry: _carregar);

    final sala = _sala!;
    final sensores = _sensores ?? [];

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.factory_outlined, color: Color(0xFF1E293B)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sala.setor.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${sensores.length} dispositivos cadastrados',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (sensores.isEmpty)
            const EmptyStateWidget(
              icon: Icons.sensors_off_rounded,
              titulo: 'Nenhum sensor vinculado',
              mensagem: 'Cadastre um módulo ESP32/IoT nesta área para iniciar a telemetria.',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sensores.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 200,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final sensor = sensores[index];
                return SensorCard(
                  sensor: sensor,
                  onTap: () => Navigator.of(context)
                      .pushNamed('/sensor-detalhe', arguments: sensor.id),
                );
              },
            ),
        ],
      ),
    );
  }
}