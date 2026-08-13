class UserModel {
  final String id;
  final String nome;
  final String email;
  final String? cargo;
  final String? empresa;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    this.cargo,
    this.empresa,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      nome: json['nome'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      cargo: json['cargo'],
      empresa: json['empresa'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'cargo': cargo,
        'empresa': empresa,
      };
}

/// Resposta de autenticação (login/cadastro): usuário + token de sessão.
class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['accessToken'] ?? '',
      user: UserModel.fromJson(json['user']),
    );
  }
}
