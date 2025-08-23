import 'package:app_test/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorScreen({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.mediaQuery.width * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: context.mediaQuery.width * 0.2,
                color: Colors.red[300],
              ),
              SizedBox(height: context.mediaQuery.height * 0.03),
              Text(
                'Ops! Algo deu errado',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.mediaQuery.height * 0.02),
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.mediaQuery.height * 0.04),
              if (onRetry != null) ...[
                SizedBox(
                  width: double.infinity,
                  height: context.mediaQuery.height * 0.06,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                ),
                SizedBox(height: context.mediaQuery.height * 0.02),
              ],
              OutlinedButton(
                onPressed: () {
                  // Pode implementar uma tela de suporte ou outras opções
                },
                child: const Text('Relatar Problema'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
