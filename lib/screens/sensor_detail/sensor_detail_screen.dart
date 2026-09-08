import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/reading_model.dart';
import '../../models/sensor_model.dart';
import '../../services/sensor_service.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/status_indicator.dart';

class SensorDetailScreen extends StatefulWidget {
  final String sensorId;
  const SensorDetailScreen({super.key, required this.sensorId});

  @override
  State<SensorDetailScreen> createState() => _SensorDetailScreenState();
}

class _SensorDetailScreenState extends State<SensorDetailScreen> {
  final SensorService _sensorService = SensorService();

  SensorModel? _sensor;
  List<ReadingModel>? _leituras;
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
      final sensor = await _sensorService.getSensorById(widget.sensorId);
      final leituras = await _sensorService.getReadings(sensorId: widget.sensorId);
      if (!mounted) return;
      setState(() {
        _sensor = sensor;
        _leituras = leituras;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os dados do sensor.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_sensor?.nome ?? 'Detalhes do sensor')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) return const LoadingWidget(mensagem: 'Carregando sensor...');
    if (_erro != null) return AppErrorWidget(mensagem: _erro!, onRetry: _carregar);

    final sensor = _sensor!;
    final leituras = List.of(_leituras ?? [])
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(sensor.localizacao,
                            style: const TextStyle(color: AppColors.textSecondary)),
                      ),
                      StatusIndicator(status: sensor.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sensor.online
                        ? '${sensor.valorAtual.toStringAsFixed(1)} ${sensor.tipo.unidade}'
                        : 'Sensor offline',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Faixa ideal: ${sensor.limiteMin.toStringAsFixed(0)} a ${sensor.limiteMax.toStringAsFixed(0)} ${sensor.tipo.unidade}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Última leitura: ${DateFormat("dd/MM/yyyy 'às' HH:mm").format(sensor.ultimaLeitura)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Tendência (últimas 24h)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (leituras.isEmpty)
            const EmptyStateWidget(
              icon: Icons.show_chart,
              titulo: 'Sem histórico',
              mensagem: 'Ainda não há leituras registradas para este sensor.',
            )
          else
            SizedBox(
              height: 220,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: leituras
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.valor))
                              .toList(),
                          isCurved: true,
                          color: statusColor(sensor.status.value),
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: statusColor(sensor.status.value).withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
