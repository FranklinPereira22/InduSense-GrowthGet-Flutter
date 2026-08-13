import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/alert_model.dart';
import '../../services/alert_service.dart';
import '../../widgets/state_widgets.dart';

class AlertasScreen extends StatefulWidget {
  const AlertasScreen({super.key});

  @override
  State<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends State<AlertasScreen> {
  final AlertService _alertService = AlertService();

  List<AlertModel>? _alertas;
  bool _carregando = true;
  String? _erro;
  bool _apenasNaoLidos = false;

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
      final alertas = await _alertService.getAlerts();
      if (!mounted) return;
      setState(() {
        _alertas = alertas;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os alertas.';
        _carregando = false;
      });
    }
  }

  Future<void> _marcarComoLido(AlertModel alerta) async {
    setState(() {
      _alertas = _alertas!
          .map((a) => a.id == alerta.id ? a.copyWith(lido: true) : a)
          .toList();
    });
    try {
      await _alertService.marcarComoLido(alerta.id);
    } catch (_) {
      // Mantém o estado local mesmo se a chamada falhar silenciosamente.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          IconButton(
            icon: Icon(_apenasNaoLidos ? Icons.filter_alt : Icons.filter_alt_outlined),
            tooltip: 'Mostrar apenas não lidos',
            onPressed: () => setState(() => _apenasNaoLidos = !_apenasNaoLidos),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) return const LoadingWidget(mensagem: 'Carregando alertas...');
    if (_erro != null) return AppErrorWidget(mensagem: _erro!, onRetry: _carregar);

    var alertas = _alertas ?? [];
    if (_apenasNaoLidos) {
      alertas = alertas.where((a) => !a.lido).toList();
    }
    alertas.sort((a, b) => b.dataHora.compareTo(a.dataHora));

    if (alertas.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.notifications_off_outlined,
        titulo: 'Nenhum alerta',
        mensagem: 'Você está em dia! Nenhum parâmetro excedido no momento.',
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: alertas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _alertaCard(alertas[index]),
      ),
    );
  }

  Widget _alertaCard(AlertModel alerta) {
    final cor = statusColor(alerta.severidade.value);
    return Card(
      color: alerta.lido ? null : cor.withOpacity(0.04),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: alerta.lido ? null : () => _marcarComoLido(alerta),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alerta.sensorNome,
                      style: TextStyle(
                        fontWeight: alerta.lido ? FontWeight.w500 : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alerta.tipo.label} excedeu o limite: '
                      '${alerta.valorMedido.toStringAsFixed(1)} ${alerta.tipo.unidade} '
                      '(limite ${alerta.limite.toStringAsFixed(0)} ${alerta.tipo.unidade})',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat("dd/MM/yyyy 'às' HH:mm").format(alerta.dataHora),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!alerta.lido)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
