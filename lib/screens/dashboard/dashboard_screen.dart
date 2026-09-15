import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sala_model.dart';
import '../../models/sensor_model.dart';
import '../../services/auth_provider.dart';
import '../../services/sala_service.dart';
import '../../widgets/sala_card.dart';
import '../../widgets/state_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SalaService _salaService = SalaService();

  List<SalaComSensores>? _salas;
  String? _erro;
  bool _carregando = true;
  Timer? _autoRefresh;

  @override
  void initState() {
    super.initState();
    _carregar();
    // Simula atualização em tempo real dos sensores IoT/ESP32.
    _autoRefresh = Timer.periodic(
        const Duration(seconds: 30), (_) => _carregar(silencioso: true));
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  Future<void> _carregar({bool silencioso = false}) async {
    if (!silencioso) {
      setState(() {
        _carregando = true;
        _erro = null;
      });
    }
    try {
      final salas = await _salaService.getSalasComSensores();
      if (!mounted) return;
      setState(() {
        _salas = salas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar as salas.';
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/alertas'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/nfc-scan'),
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Escanear sala'),
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _buildBody(user?.nome),
      ),
    );
  }

  Widget _buildBody(String? nomeUsuario) {
    if (_carregando) return const LoadingWidget(mensagem: 'Carregando salas...');
    if (_erro != null) {
      return AppErrorWidget(mensagem: _erro!, onRetry: _carregar);
    }
    final salas = _salas ?? [];
    if (salas.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.meeting_room_outlined,
        titulo: 'Nenhuma sala cadastrada',
        mensagem: 'Cadastre uma sala e vincule os sensores ESP32/IoT a ela.',
      );
    }

    final todosSensores = salas.expand((s) => s.sensores).toList();
    final criticos =
        todosSensores.where((s) => s.status == SensorStatus.critico).length;
    final atencao =
        todosSensores.where((s) => s.status == SensorStatus.atencao).length;
    final normais =
        todosSensores.where((s) => s.status == SensorStatus.normal).length;
    final offline = todosSensores.where((s) => !s.online).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (nomeUsuario != null) ...[
          Text('Olá, $nomeUsuario',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          const Text('Visão geral dos ambientes monitorados',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final chips = [
              _resumoChip('Normal', normais, AppColors.statusNormal),
              _resumoChip('Atenção', atencao, AppColors.statusAtencao),
              _resumoChip('Crítico', criticos, AppColors.statusCritico),
              _resumoChip('Offline', offline, AppColors.statusOffline),
            ];
            final larguraItem = (constraints.maxWidth - 24) / 4;
            if (larguraItem >= 70) {
              return Row(
                children: [
                  for (int i = 0; i < chips.length; i++) ...[
                    Expanded(child: chips[i]),
                    if (i != chips.length - 1) const SizedBox(width: 8),
                  ],
                ],
              );
            }
            return Column(
              children: [
                Row(children: [
                  Expanded(child: chips[0]),
                  const SizedBox(width: 8),
                  Expanded(child: chips[1]),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: chips[2]),
                  const SizedBox(width: 8),
                  Expanded(child: chips[3]),
                ]),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const Text('Salas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        const SizedBox(height: 4),
        const Text(
          'Toque em uma sala para ver os sensores, ou use a tag NFC na porta.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ...salas.map((sala) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SalaCard(
                salaComSensores: sala,
                onTap: () => Navigator.of(context)
                    .pushNamed('/sala-detalhe', arguments: sala.sala.id),
              ),
            )),
      ],
    );
  }

  Widget _resumoChip(String label, int valor, Color cor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$valor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cor, letterSpacing: 0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}