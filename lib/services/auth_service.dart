import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'mock_data_service.dart';

/// Regras de autenticação: login, cadastro, sessão e logout.
///
/// Quando [ApiConstants.useMock] é true, simula respostas de rede
/// (delay + validações simples) sem depender do backend.
class AuthService {
  final ApiClient _client = ApiClient();
  static const _sessionKey = 'indusense_session_user';

  Future<UserModel> login({
    required String email,
    required String senha,
  }) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (email.trim().isEmpty || senha.length < 4) {
        throw ApiException('E-mail ou senha inválidos.');
      }
      final user = MockDataService.mockUser;
      await ApiClient.saveToken('mock-token-123');
      await _persistUser(user);
      return user;
    }

    final res = await _client.post(ApiConstants.login, {
      'email': email,
      'senha': senha,
    });
    final auth = AuthResponse.fromJson(res);
    await ApiClient.saveToken(auth.token);
    await _persistUser(auth.user);
    return auth.user;
  }

  Future<UserModel> cadastrar({
    required String nome,
    required String email,
    required String senha,
    String? empresa,
  }) async {
    if (ApiConstants.useMock) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (nome.trim().isEmpty || !email.contains('@') || senha.length < 6) {
        throw ApiException('Verifique os dados informados.');
      }
      final user = UserModel(
        id: 'u-novo',
        nome: nome,
        email: email,
        empresa: empresa,
      );
      await ApiClient.saveToken('mock-token-novo');
      await _persistUser(user);
      return user;
    }

    final res = await _client.post(ApiConstants.register, {
      'nome': nome,
      'email': email,
      'senha': senha,
      'empresa': empresa,
    });
    final auth = AuthResponse.fromJson(res);
    await ApiClient.saveToken(auth.token);
    await _persistUser(auth.user);
    return auth.user;
  }

  Future<void> logout() async {
    if (!ApiConstants.useMock) {
      try {
        await _client.post(ApiConstants.logout, {});
      } catch (_) {
        // mesmo se falhar no servidor, limpamos a sessão local
      }
    }
    await ApiClient.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<void> _persistUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, user.email);
  }

  /// Verifica se existe uma sessão salva localmente (auto-login no splash).
  Future<UserModel?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_sessionKey);
    if (saved == null) return null;
    if (ApiConstants.useMock) return MockDataService.mockUser;

    try {
      final res = await _client.get(ApiConstants.me);
      return UserModel.fromJson(res);
    } catch (_) {
      return null;
    }
  }
}
