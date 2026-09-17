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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _sala?.nome ?? 'Ambiente',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
      color: const Color(0xFF0EA5E9),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.factory_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sala.setor.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${sensores.length} dispositivos cadastrados',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
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