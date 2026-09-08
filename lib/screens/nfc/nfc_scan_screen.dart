import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sala_model.dart';
import '../../services/api_client.dart';
import '../../services/nfc_service.dart';
import '../../services/sala_service.dart';

enum _NfcEstado { aguardando, lendo, erro }

/// Tela de leitura de tag NFC. O funcionário aproxima o celular da tag
/// fixada na porta da sala e o app navega automaticamente para os
/// sensores daquela sala, sem precisar procurar manualmente.
class NfcScanScreen extends StatefulWidget {
  const NfcScanScreen({super.key});

  @override
  State<NfcScanScreen> createState() => _NfcScanScreenState();
}

class _NfcScanScreenState extends State<NfcScanScreen> {
  final NfcService _nfcService = NfcService();
  final SalaService _salaService = SalaService();

  _NfcEstado _estado = _NfcEstado.aguardando;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _iniciarLeitura();
  }

  @override
  void dispose() {
    _nfcService.pararLeitura();
    super.dispose();
  }

  Future<void> _iniciarLeitura() async {
    setState(() {
      _estado = _NfcEstado.aguardando;
      _mensagemErro = null;
    });

    await _nfcService.iniciarLeitura(
      onTagLido: (tagId) => _resolverSala(tagId),
      onErro: (mensagem) {
        if (!mounted) return;
        setState(() {
          _estado = _NfcEstado.erro;
          _mensagemErro = mensagem;
        });
      },
    );
  }

  Future<void> _resolverSala(String tagId) async {
    if (!mounted) return;
    setState(() => _estado = _NfcEstado.lendo);
    try {
      final SalaModel sala = await _salaService.getSalaPorTagNfc(tagId);
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacementNamed('/sala-detalhe', arguments: sala.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _estado = _NfcEstado.erro;
        _mensagemErro = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _estado = _NfcEstado.erro;
        _mensagemErro = 'Não foi possível identificar a sala desta tag.';
      });
    }
  }

  /// Simula a leitura com uma tag de exemplo — útil para testar o
  /// fluxo em aparelhos sem NFC ou sem uma tag física em mãos.
  Future<void> _simularLeitura() async {
    await _resolverSala('NFC-GALPAO1-LINHA-A');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear sala')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcone(),
              const SizedBox(height: 32),
              Text(
                _titulo(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _mensagem(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              if (_estado == _NfcEstado.erro)
                ElevatedButton(
                  onPressed: _iniciarLeitura,
                  child: const Text('Tentar novamente'),
                ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _simularLeitura,
                icon: const Icon(Icons.bug_report_outlined, size: 18),
                label: const Text('Simular leitura (modo teste)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcone() {
    switch (_estado) {
      case _NfcEstado.lendo:
        return const SizedBox(
          width: 96,
          height: 96,
          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
        );
      case _NfcEstado.erro:
        return const Icon(Icons.error_outline, size: 96, color: AppColors.statusCritico);
      case _NfcEstado.aguardando:
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.nfc, size: 56, color: AppColors.primary),
        );
    }
  }

  String _titulo() {
    switch (_estado) {
      case _NfcEstado.aguardando:
        return 'Aproxime o celular da tag NFC';
      case _NfcEstado.lendo:
        return 'Identificando a sala...';
      case _NfcEstado.erro:
        return 'Não foi possível ler a tag';
    }
  }

  String _mensagem() {
    if (_estado == _NfcEstado.erro) {
      return _mensagemErro ?? 'Tente aproximar novamente da tag na porta da sala.';
    }
    if (_estado == _NfcEstado.lendo) {
      return 'Buscando os dados dos sensores desta sala.';
    }
    return 'A tag fica fixada na porta de cada sala. Ao aproximar, '
        'o InduSense mostra automaticamente os sensores desse ambiente.';
  }
}
