import 'package:flutter/material.dart';
import '../screens/auth/cadastro_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home_shell.dart';
import '../screens/sensor_detail/sensor_detail_screen.dart';
import '../screens/splash/splash_screen.dart';

/// Tabela de rotas nomeadas do InduSense.
///
/// '/sensor-detalhe' recebe o id do sensor via `arguments` (String).
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const dashboard = '/dashboard';
  static const historico = '/historico';
  static const alertas = '/alertas';
  static const configuracoes = '/configuracoes';
  static const sensorDetalhe = '/sensor-detalhe';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        login: (_) => const LoginScreen(),
        cadastro: (_) => const CadastroScreen(),
        dashboard: (_) => const HomeShell(initialIndex: 0),
        historico: (_) => const HomeShell(initialIndex: 1),
        alertas: (_) => const HomeShell(initialIndex: 2),
        configuracoes: (_) => const HomeShell(initialIndex: 3),
      };

  /// Rotas que exigem argumento dinâmico ficam fora do mapa estático.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == sensorDetalhe) {
      final sensorId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => SensorDetailScreen(sensorId: sensorId),
      );
    }
    return null;
  }
}
