import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';
import '../../services/auth_provider.dart';
import '../../services/sensor_service.dart';
import '../../widgets/sensor_card.dart';
import '../../widgets/state_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SensorService _sensorService = SensorService();

  List<SensorModel>? _sensores;
  String? _erro;
  bool _carregando = true;
  Timer? _autoRefresh;

  @override
  void initState() {
    super.initState();
    _carregar();
    // Simula atualização em tempo real dos sensores IoT/ESP32.
    _autoRefresh = Timer.periodic(const Duration(seconds: 30), (_) => _carregar(silencioso: true));
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
      final sensores = await _sensorService.getSensors();
      if (!mounted) return;
      setState(() {
        _sensores = sensores;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = 'Não foi possível carregar os sensores.';
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
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _buildBody(user?.nome),
      ),
    );
  }

  Widget _buildBody(String? nomeUsuario) {
    if (_carregando) return const LoadingWidget(mensagem: 'Carregando sensores...');
    if (_erro != null) {
      return AppErrorWidget(mensagem: _erro!, onRetry: _carregar);
    }
    final sensores = _sensores ?? [];
    if (sensores.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.sensors_off_outlined,
        titulo: 'Nenhum sensor encontrado',
        mensagem: 'Cadastre um sensor ESP32/IoT para começar o monitoramento.',
      );
    }

    final criticos = sensores.where((s) => s.status == SensorStatus.critico).length;
    final atencao = sensores.where((s) => s.status == SensorStatus.atencao).length;
    final normais = sensores.where((s) => s.status == SensorStatus.normal).length;
    final offline = sensores.where((s) => !s.online).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (nomeUsuario != null) ...[
          Text('Olá, $nomeUsuario 👋',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Visão geral dos ambientes monitorados',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
        ],
        Row(
          children: [
            _resumoChip('Normal', normais, AppColors.statusNormal),
            const SizedBox(width: 8),
            _resumoChip('Atenção', atencao, AppColors.statusAtencao),
            const SizedBox(width: 8),
            _resumoChip('Crítico', criticos, AppColors.statusCritico),
            const SizedBox(width: 8),
            _resumoChip('Offline', offline, AppColors.statusOffline),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Sensores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sensores.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
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
    );
  }

  Widget _resumoChip(String label, int valor, Color cor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$valor',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: cor)),
          ],
        ),
      ),
    );
  }
}
