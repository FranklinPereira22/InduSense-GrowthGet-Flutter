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
        title: const Text('Logs de Alertas'),
        actions: [
          IconButton(
            icon: Icon(_apenasNaoLidos ? Icons.filter_alt_rounded : Icons.filter_alt_outlined),
            tooltip: 'Mostrar apenas pendentes',
            onPressed: () => setState(() => _apenasNaoLidos = !_apenasNaoLidos),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_carregando) return const LoadingWidget(mensagem: 'Carregando histórico de alertas...');
    if (_erro != null) return AppErrorWidget(mensagem: _erro!, onRetry: _carregar);

    var alertas = _alertas ?? [];
    if (_apenasNaoLidos) {
      alertas = alertas.where((a) => !a.lido).toList();
    }
    alertas.sort((a, b) => b.dataHora.compareTo(a.dataHora));

    if (alertas.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.check_circle_outline_rounded,
        titulo: 'Sem ocorrências registradas',
        mensagem: 'Todos os parâmetros operacionais estão dentro das faixas limites.',
      );
    }

    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: alertas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _alertaCard(alertas[index]),
      ),
    );
  }

  Widget _alertaCard(AlertModel alerta) {
    final cor = statusColor(alerta.severidade.name);

    return Container(
      decoration: BoxDecoration(
        color: alerta.lido ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: alerta.lido ? const Color(0xFFE2E8F0) : cor.withOpacity(0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: alerta.lido ? null : () => _marcarComoLido(alerta),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Barra lateral indicadora da gravidade da ocorrência
                Container(
                  width: 4,
                  color: cor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alerta.sensorNome,
                                style: TextStyle(
                                  fontWeight: alerta.lido ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            if (!alerta.lido)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'PENDENTE',
                                  style: TextStyle(
                                    color: cor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${alerta.tipo.name.toUpperCase()} excedeu o limite máximo: '
                          '${alerta.valorMedido.toStringAsFixed(1)} (Limite: ${alerta.limite.toStringAsFixed(0)})',
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat("dd/MM/yyyy · HH:mm:ss").format(alerta.dataHora),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}