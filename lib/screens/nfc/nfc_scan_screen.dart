import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sala_model.dart';
import '../../services/api_client.dart';
import '../../services/nfc_service.dart';
import '../../services/sala_service.dart';

enum _NfcEstado { aguardando, lendo, erro }

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

  Future<void> _simularLeitura() async {
    await _resolverSala('NFC-GALPAO1-LINHA-A');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Escanear sala',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildIcone(),
              const SizedBox(height: 36),
              Text(
                _titulo(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _mensagem(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              if (_estado == _NfcEstado.erro) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _iniciarLeitura,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Tentar novamente',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              TextButton.icon(
                onPressed: _simularLeitura,
                icon: const Icon(Icons.bug_report_outlined, size: 18, color: Color(0xFF0EA5E9)),
                label: const Text(
                  'Simular leitura (modo teste)',
                  style: TextStyle(
                    color: Color(0xFF0EA5E9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Color(0xFF0EA5E9),
              ),
            ),
          ),
        );
      case _NfcEstado.erro:
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.statusCritico,
          ),
        );
      case _NfcEstado.aguardando:
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.nfc_rounded,
                size: 56,
                color: Color(0xFF0EA5E9),
              ),
            ),
          ),
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