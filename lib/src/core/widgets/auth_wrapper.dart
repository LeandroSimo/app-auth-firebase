import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import 'splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // Pode adicionar listeners globais aqui se necessário
        if (state is AuthError) {
          // Log do erro ou outras ações globais
          debugPrint('Auth Error: ${state.message}');
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        } else if (state is AuthAuthenticated) {
          return const HomeScreen();
        } else if (state is AuthUnauthenticated || state is AuthError) {
          return const LoginScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
