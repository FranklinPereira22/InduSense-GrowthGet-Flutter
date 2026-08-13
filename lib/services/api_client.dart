import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';

/// Exceção padronizada para erros de API, já com mensagem amigável
/// em português para exibir na UI.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Encapsula chamadas HTTP ao backend Nest.js, incluindo o token de
/// sessão salvo localmente. Usado pelos services quando
/// [ApiConstants.useMock] é false.
class ApiClient {
  static const _tokenKey = 'indusense_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('${ApiConstants.baseUrl}$path'),
              headers: await _headers())
          .timeout(ApiConstants.timeout);
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Falha de conexão. Verifique sua internet.');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('${ApiConstants.baseUrl}$path'),
              headers: await _headers(), body: jsonEncode(body))
          .timeout(ApiConstants.timeout);
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Falha de conexão. Verifique sua internet.');
    }
  }

  Future<dynamic> patch(String path, [Map<String, dynamic>? body]) async {
    try {
      final res = await http
          .patch(Uri.parse('${ApiConstants.baseUrl}$path'),
              headers: await _headers(),
              body: body != null ? jsonEncode(body) : null)
          .timeout(ApiConstants.timeout);
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Falha de conexão. Verifique sua internet.');
    }
  }

  dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }
    String message = 'Erro ao comunicar com o servidor.';
    try {
      final decoded = jsonDecode(res.body);
      message = decoded['message']?.toString() ?? message;
    } catch (_) {}
    if (res.statusCode == 401) {
      message = 'Sessão expirada. Faça login novamente.';
    }
    throw ApiException(message, statusCode: res.statusCode);
  }
}
