import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Sair da conta', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Tem certeza que deseja encerrar a sessão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.statusCritico, fontWeight: FontWeight.bold)),
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
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil e Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Card de Perfil
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0EA5E9) : const Color(0xFF0F172A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (user?.nome.isNotEmpty == true ? user!.nome[0] : '?').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nome ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '—',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                      if (user?.empresa != null && user!.empresa!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.empresa!,
                            style: const TextStyle(
                              color: Color(0xFF0EA5E9),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Seção Aparência (NOVA OPÇÃO DE TEMA)
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Aparência',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: SwitchListTile(
              activeColor: const Color(0xFF0EA5E9),
              secondary: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: const Color(0xFF0EA5E9),
              ),
              title: const Text('Modo Escuro', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Usar o tema azul escuro no aplicativo', style: TextStyle(fontSize: 12)),
              value: isDark,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
          ),
          const SizedBox(height: 24),

          // Seção Notificações
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Notificações',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeColor: const Color(0xFF0EA5E9),
                  title: const Text('Notificações push', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Receber alertas mesmo com o app fechado', style: TextStyle(fontSize: 12)),
                  value: _notificacoesPush,
                  onChanged: (v) => setState(() => _notificacoesPush = v),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  activeColor: const Color(0xFF0EA5E9),
                  title: const Text('Alertas críticos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: _alertasCriticos,
                  onChanged: (v) => setState(() => _alertasCriticos = v),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  activeColor: const Color(0xFF0EA5E9),
                  title: const Text('Alertas de atenção', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: _alertasAtencao,
                  onChanged: (v) => setState(() => _alertasAtencao = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Seção Conta
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              'Conta',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
                  ),
                  title: const Text('Alterar senha', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 20),
                  ),
                  title: const Text('Sobre o InduSense', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
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
          const SizedBox(height: 32),

          // Botão Sair
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _confirmarLogout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.statusCritico, size: 20),
              label: const Text('Sair da conta', style: TextStyle(color: AppColors.statusCritico, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFECDD3), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}