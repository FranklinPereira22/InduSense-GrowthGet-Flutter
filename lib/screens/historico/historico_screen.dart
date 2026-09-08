import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/reading_model.dart';
import '../../models/sensor_model.dart';
import '../../services/sensor_service.dart';
import '../../widgets/state_widgets.dart';

enum _Periodo { horas24, dias7, dias30 }

extension on _Periodo {
  String get label {
    switch (this) {
      case _Periodo.horas24:
        return '24h';
      case _Periodo.dias7:
        return '7 dias';
      case _Periodo.dias30:
        return '30 dias';
    }
  }

  Duration get duracao {
    switch (this) {
      case _Periodo.horas24:
        return const Duration(hours: 24);
      case _Periodo.dias7:
        return const Duration(days: 7);
      case _Periodo.dias30:
        return const Duration(days: 30);
    }
  }
}

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final SensorService _sensorService = SensorService();

  List<ReadingModel>? _leituras;
  bool _carregando = true;
  String? _erro;

  SensorType? _filtroTipo;
  _Periodo _periodo = _Periodo.horas24;

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
      final leituras = await _sensorService.getReadings(
        tipo: _filtroTipo,
        inicio: DateTime.now().subtract(_periodo.duracao),
      );
      if (!mounted) return;
      setState(() {
        _leituras = leituras;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar o histórico.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _Periodo.values.map((p) {
                final selecionado = p == _periodo;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(p.label),
                    selected: selecionado,
                    onSelected: (_) {
                      setState(() => _periodo = p);
                      _carregar();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filtroTipoChip(null, 'Todos os sensores'),
                ...SensorType.values.map((t) => _filtroTipoChip(t, t.label)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtroTipoChip(SensorType? tipo, String label) {
    final selecionado = _filtroTipo == tipo;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selecionado,
        onSelected: (_) {
          setState(() => _filtroTipo = tipo);
          _carregar();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_carregando) return const LoadingWidget(mensagem: 'Carregando histórico...');
    if (_erro != null) return AppErrorWidget(mensagem: _erro!, onRetry: _carregar);

    final leituras = _leituras ?? [];
    if (leituras.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.show_chart,
        titulo: 'Sem registros no período',
        mensagem: 'Ajuste os filtros de período ou tipo de sensor.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 220,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
              child: _buildChart(leituras),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Registros (${leituras.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...leituras.map((r) => _leituraTile(r)),
      ],
    );
  }

  Widget _buildChart(List<ReadingModel> leituras) {
    final ordenadas = List.of(leituras)
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
    final pontos = ordenadas
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.valor))
        .toList();

    return LineChart(
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
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
            spots: pontos,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leituraTile(ReadingModel r) {
    final cor = statusColor(r.status.value);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor.withOpacity(0.12),
          child: Icon(Icons.circle, color: cor, size: 12),
        ),
        title: Text(r.sensorNome, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(DateFormat("dd/MM/yyyy 'às' HH:mm").format(r.dataHora)),
        trailing: Text(
          '${r.valor.toStringAsFixed(1)} ${r.tipo.unidade}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
