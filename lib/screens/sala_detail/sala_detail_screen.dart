import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sala_model.dart';
import '../../models/sensor_model.dart';
import '../../services/sala_service.dart';
import '../../widgets/sensor_card.dart';
import '../../widgets/state_widgets.dart';

/// Sensores de uma sala específica. É a tela para onde o app navega
/// automaticamente após ler a tag NFC fixada na porta da sala.
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
      appBar: AppBar(title: Text(_sala?.nome ?? 'Sala')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) return const LoadingWidget(mensagem: 'Carregando sensores...');
    if (_erro != null) return AppErrorWidget(mensagem: _erro!, onRetry: _carregar);

    final sala = _sala!;
    final sensores = _sensores ?? [];

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.meeting_room_outlined,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sala.setor,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        Text('${sensores.length} sensores nesta sala',
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (sensores.isEmpty)
            const EmptyStateWidget(
              icon: Icons.sensors_off_outlined,
              titulo: 'Nenhum sensor nesta sala',
              mensagem: 'Vincule um sensor ESP32/IoT a esta sala para monitorá-la.',
            )
          else
            // MaxCrossAxisExtent + mainAxisExtent fixo (em vez de
            // childAspectRatio) deixa o número de colunas responsivo
            // ao tamanho real da tela (celular x tablet) e evita que o
            // conteúdo do card seja espremido/estourado verticalmente.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sensores.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 190,
                mainAxisExtent: 190,
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
