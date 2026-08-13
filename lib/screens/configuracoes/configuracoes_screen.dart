import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_provider.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  bool _notificacoesPush = true;
  bool _alertasCriticos = true;
  bool _alertasAtencao = true;

  Future<void> _confirmarLogout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja encerrar a sessão?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.statusCritico)),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil e Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      (user?.nome.isNotEmpty == true ? user!.nome[0] : '?').toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.nome ?? '—',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(user?.email ?? '—',
                            style: const TextStyle(color: AppColors.textSecondary)),
                        if (user?.empresa != null && user!.empresa!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(user.empresa!,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Notificações', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notificações push'),
                  subtitle: const Text('Receber alertas mesmo com o app fechado'),
                  value: _notificacoesPush,
                  onChanged: (v) => setState(() => _notificacoesPush = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Alertas críticos'),
                  value: _alertasCriticos,
                  onChanged: (v) => setState(() => _alertasCriticos = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Alertas de atenção'),
                  value: _alertasAtencao,
                  onChanged: (v) => setState(() => _alertasAtencao = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Conta', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Alterar senha'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Sobre o InduSense'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'InduSense',
                    applicationVersion: '1.0.0',
                    applicationLegalese: 'Growth Get — Monitoramento Ambiental Industrial',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _confirmarLogout,
            icon: const Icon(Icons.logout, color: AppColors.statusCritico),
            label: const Text('Sair', style: TextStyle(color: AppColors.statusCritico)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: AppColors.statusCritico),
            ),
          ),
        ],
      ),
    );
  }
}
