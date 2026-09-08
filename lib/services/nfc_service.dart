import 'dart:io';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

/// Erros de leitura NFC com mensagem amigável para exibir na UI.
class NfcException implements Exception {
  final String message;
  NfcException(this.message);
  @override
  String toString() => message;
}

/// Encapsula a leitura de tags NFC fixadas na porta de cada sala.
class NfcService {
  /// Verifica se o aparelho tem suporte a leitura NFC.
  Future<bool> isDisponivel() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Inicia uma sessão de leitura e resolve para o id gravado na tag.
  Future<void> iniciarLeitura({
    required void Function(String tagId) onTagLido,
    required void Function(String mensagem) onErro,
  }) async {
    final disponivel = await isDisponivel();
    if (!disponivel) {
      onErro('NFC não disponível ou desativado neste aparelho.');
      return;
    }

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
          NfcPollingOption.iso18092,
        },
        onDiscovered: (NfcTag tag) async {
          try {
            final id = _extrairIdentificador(tag);
            if (id == null) {
              onErro('Tag NFC não reconhecida. Tente novamente.');
            } else {
              onTagLido(id);
            }
          } finally {
            await NfcManager.instance.stopSession();
          }
        },
      );
    } catch (e) {
      onErro('Não foi possível iniciar a leitura NFC.');
    }
  }

  Future<void> pararLeitura() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (_) {
      // sessão já pode estar encerrada
    }
  }

  /// Extrai um identificador de texto da tag. Prioriza um payload NDEF
  /// ou recorre ao fallback de identificador de hardware.
  String? _extrairIdentificador(NfcTag tag) {
    try {
      final ndef = Ndef.from(tag);
      final mensagem = ndef?.cachedMessage;
      if (mensagem != null && mensagem.records.isNotEmpty) {
        final payload = mensagem.records.first.payload;
        if (payload.length > 3) {
          final langLength = payload[0] & 0x3F;
          final texto = String.fromCharCodes(payload.sublist(1 + langLength));
          if (texto.trim().isNotEmpty) return texto.trim();
        }
      }
    } catch (_) {
      // segue para o fallback de serial
    }

    // Fallback: usa o identificador de hardware da tag com cast seguro para Map
    try {
      final data = tag.data as Map<String, dynamic>;
      if (Platform.isAndroid) {
        final id = (data['nfca'] as Map<String, dynamic>?)?['identifier'] ??
            (data['nfcb'] as Map<String, dynamic>?)?['identifier'] ??
            (data['nfcf'] as Map<String, dynamic>?)?['identifier'] ??
            (data['nfcv'] as Map<String, dynamic>?)?['identifier'] ??
            (data['mifareclassic'] as Map<String, dynamic>?)?['identifier'] ??
            (data['mifareultralight'] as Map<String, dynamic>?)?['identifier'];
        if (id != null) return _bytesToHex(id as List<int>);
      } else if (Platform.isIOS) {
        final id = (data['miFare'] as Map<String, dynamic>?)?['identifier'] ??
            (data['iso15693'] as Map<String, dynamic>?)?['identifier'] ??
            (data['feliCa'] as Map<String, dynamic>?)?['currentIDm'];
        if (id != null) return _bytesToHex(id as List<int>);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  String _bytesToHex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
}