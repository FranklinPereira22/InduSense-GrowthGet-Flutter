import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Indicador de carregamento padrão do app.
class LoadingWidget extends StatelessWidget {
  final String? mensagem;
  const LoadingWidget({super.key, this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (mensagem != null) ...[
            const SizedBox(height: 16),
            Text(mensagem!, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Estado vazio (sem sensores, sem histórico, sem alertas...).
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String mensagem;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.titulo,
    required this.mensagem,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              mensagem,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de erro com opção de tentar novamente.
class AppErrorWidget extends StatelessWidget {
  final String mensagem;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, required this.mensagem, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.statusCritico),
            const SizedBox(height: 16),
            Text(
              mensagem,
              style: const TextStyle(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(minimumSize: const Size(140, 44)),
                child: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
