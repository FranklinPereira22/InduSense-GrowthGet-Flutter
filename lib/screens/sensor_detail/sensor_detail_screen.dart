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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _sensor?.nome ?? 'Telemetria do Sensor',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
      color: const Color(0xFF0EA5E9),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sensor.localizacao.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0EA5E9),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusIndicator(status: sensor.status),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  sensor.online
                      ? '${sensor.valorAtual.toStringAsFixed(1)} ${sensor.tipo.unidade}'
                      : 'OFFLINE',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: sensor.online ? null : AppColors.statusOffline,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Faixa nominal',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${sensor.limiteMin.toStringAsFixed(0)} - ${sensor.limiteMax.toStringAsFixed(0)} ${sensor.tipo.unidade}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Última leitura',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('HH:mm').format(sensor.ultimaLeitura),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Histórico de Leituras (Últimas 24 horas)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
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
              height: 240,
              padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
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
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                            ),
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
                      color: statusCol,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: statusCol.withOpacity(0.1),
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