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
      appBar: AppBar(title: Text(_sensor?.nome ?? 'Telemetria do Sensor')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) return const LoadingWidget(mensagem: 'Carregando leituras...');
    if (_erro != null) return AppErrorWidget(mensagem: _erro!, onRetry: _carregar);

    final sensor = _sensor!;
    final leituras = List.of(_leituras ?? [])
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    final statusCol = statusColor(sensor.status.value);

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sensor.localizacao.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    StatusIndicator(status: sensor.status),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  sensor.online
                      ? '${sensor.valorAtual.toStringAsFixed(1)} ${sensor.tipo.unidade}'
                      : 'OFFLINE',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    fontFamily: 'monospace',
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Faixa nominal: ${sensor.limiteMin.toStringAsFixed(0)} - ${sensor.limiteMax.toStringAsFixed(0)} ${sensor.tipo.unidade}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    Text(
                      'Última leitura: ${DateFormat('HH:mm').format(sensor.ultimaLeitura)}',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Histórico de Leituras (Últimas 24 horas)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          if (leituras.isEmpty)
            const EmptyStateWidget(
              icon: Icons.show_chart_rounded,
              titulo: 'Sem dados no histórico',
              mensagem: 'Aguardando envio de pacotes pela rede ESP32/IoT.',
            )
          else
            Container(
              height: 230,
              padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'monospace',
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
                      isCurved: false, // Linha reta estilo dashboard técnico de telemetria
                      color: statusCol,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: statusCol.withOpacity(0.05),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}