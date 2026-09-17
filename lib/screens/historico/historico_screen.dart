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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Histórico',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
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
                    label: Text(
                      p.label,
                      style: TextStyle(
                        color: selecionado ? Colors.white : const Color(0xFF64748B),
                        fontWeight: selecionado ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    selected: selecionado,
                    selectedColor: const Color(0xFF0EA5E9),
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (_) {
                      setState(() => _periodo = p);
                      _carregar();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
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
        label: Text(
          label,
          style: TextStyle(
            color: selecionado ? Colors.white : const Color(0xFF64748B),
            fontWeight: selecionado ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
        selected: selecionado,
        selectedColor: const Color(0xFF0EA5E9),
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        icon: Icons.show_chart_rounded,
        titulo: 'Sem registros no período',
        mensagem: 'Ajuste os filtros de período ou tipo de sensor.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Container(
          height: 220,
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20, 24, 12),
            child: _buildChart(leituras),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Registros (${leituras.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
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
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
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
            color: const Color(0xFF0EA5E9),
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF0EA5E9).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leituraTile(ReadingModel r) {
    final cor = statusColor(r.status.value);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: cor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.sensors_rounded, color: cor, size: 18),
        ),
        title: Text(
          r.sensorNome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          DateFormat("dd/MM/yyyy 'às' HH:mm").format(r.dataHora),
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0EA5E9).withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${r.valor.toStringAsFixed(1)} ${r.tipo.unidade}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0EA5E9)),
          ),
        ),
      ),
    );
  }
}