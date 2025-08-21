import 'package:app_test/src/features/auth/data/services/firebase_auth_service.dart';
import 'package:app_test/src/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/core/routes/router_generator.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/widgets/error_screen.dart';
import 'src/features/auth/data/repositories/auth_repository_impl.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        try {
          final firebaseAuthService = FirebaseAuthService();
          final authRepository = AuthRepositoryImpl(
            firebaseAuthService: firebaseAuthService,
          );
          return AuthCubit(authRepository: authRepository)..checkAuthStatus();
        } catch (e) {
          // Em caso de erro crítico, retorna um Cubit em estado de erro
          debugPrint('Erro crítico ao inicializar AuthCubit: $e');
          rethrow;
        }
      },
      child: MaterialApp(
        title: 'App Test',
        theme: AppTheme.themeData,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouterGenerator.generateRoute,
        builder: (context, child) {
          // Captura erros de widget e exibe tela de erro amigável
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return ErrorScreen(
              message: 'Erro interno do aplicativo. Tente reiniciar o app.',
              onRetry: () {
                // Pode implementar lógica de retry aqui
              },
            );
          };
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
