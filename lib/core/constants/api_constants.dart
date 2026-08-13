/// Configuração central de acesso à API Nest.js.
///
/// Troque [baseUrl] pelo endereço real do backend quando disponível.
/// Enquanto [useMock] estiver true, os services usam MockDataService
/// em vez de chamadas HTTP reais — nenhuma tela precisa mudar.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.indusense.growthget.com/v1';
  static const bool useMock = true;

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Sensores / Dashboard
  static const String sensors = '/sensors';
  static String sensorById(String id) => '/sensors/$id';
  static String sensorReadings(String id) => '/sensors/$id/readings';

  // Histórico
  static const String readings = '/readings';

  // Alertas
  static const String alerts = '/alerts';
  static String alertRead(String id) => '/alerts/$id/read';

  // Perfil
  static const String profile = '/users/profile';

  static const Duration timeout = Duration(seconds: 15);
}
