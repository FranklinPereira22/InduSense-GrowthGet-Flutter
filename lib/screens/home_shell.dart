import 'package:flutter/material.dart';
import 'alertas/alertas_screen.dart';
import 'configuracoes/configuracoes_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'historico/historico_screen.dart';

class HomeShell extends StatefulWidget {
  final int initialIndex;
  const HomeShell({super.key, this.initialIndex = 0});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = widget.initialIndex;

  static const _telas = [
    DashboardScreen(),
    HistoricoScreen(),
    AlertasScreen(),
    ConfiguracoesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _telas),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: NavigationBar(
              elevation: 0,
              height: 64,
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              backgroundColor: Theme.of(context).cardColor,
              indicatorColor: const Color(0xFF0EA5E9).withOpacity(0.15),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, color: Color(0xFF64748B)),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: Color(0xFF0EA5E9)),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined, color: Color(0xFF64748B)),
                  selectedIcon: Icon(Icons.history_rounded, color: Color(0xFF0EA5E9)),
                  label: 'Histórico',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined, color: Color(0xFF64748B)),
                  selectedIcon: Icon(Icons.notifications_rounded, color: Color(0xFF0EA5E9)),
                  label: 'Alertas',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
                  selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF0EA5E9)),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}