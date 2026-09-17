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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Logs de Alertas',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: _apenasNaoLidos ? const Color(0xFF0EA5E9) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              elevation: 2,
              shadowColor: Colors.black12,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _apenasNaoLidos = !_apenasNaoLidos),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    _apenasNaoLidos ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
                    color: _apenasNaoLidos ? Colors.white : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
              ),
            ),
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
      color: const Color(0xFF0EA5E9),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: alertas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) => _alertaCard(alertas[index]),
      ),
    );
  }

  Widget _alertaCard(AlertModel alerta) {
    final cor = statusColor(alerta.severidade.name);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: alerta.lido ? Colors.transparent : cor.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: alerta.lido ? null : () => _marcarComoLido(alerta),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    alerta.lido ? Icons.notifications_none_rounded : Icons.warning_amber_rounded,
                    color: cor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
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
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (!alerta.lido)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: cor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'PENDENTE',
                                style: TextStyle(
                                  color: cor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
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
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat("dd/MM/yyyy · HH:mm:ss").format(alerta.dataHora),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
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