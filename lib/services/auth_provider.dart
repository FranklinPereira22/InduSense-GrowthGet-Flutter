import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'auth_service.dart';

enum AuthStatus { desconhecido, autenticado, naoAutenticado }

/// Estado global de sessão, consumido pelas telas via Provider.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  AuthStatus _status = AuthStatus.desconhecido;
  String? _errorMessage;
  bool _loading = false;

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get loading => _loading;

  Future<void> restoreSession() async {
    try {
      final user = await _authService.restoreSession();
      _user = user;
      _status = user != null ? AuthStatus.autenticado : AuthStatus.naoAutenticado;
    } catch (_) {
      _status = AuthStatus.naoAutenticado;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String senha) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.login(email: email, senha: senha);
      _user = user;
      _status = AuthStatus.autenticado;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível entrar. Tente novamente.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
    String? empresa,
  }) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.cadastrar(
        nome: nome,
        email: email,
        senha: senha,
        empresa: empresa,
      );
      _user = user;
      _status = AuthStatus.autenticado;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível concluir o cadastro.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.naoAutenticado;
    notifyListeners();
  }
}
