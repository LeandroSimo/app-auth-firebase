import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/domain/repositories/auth_repository.dart';
import '../../../../core/errors/auth_exception.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    _monitorAuthState();
  }

  void _monitorAuthState() {
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
      onError: (error) {
        // Em caso de erro no stream, emite estado não autenticado
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(
          const AuthError(message: 'Falha na autenticação. Tente novamente.'),
        );
      }
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(
        const AuthError(
          message: 'Erro inesperado. Verifique sua conexão e tente novamente.',
        ),
      );
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      emit(AuthLoading());

      final user = await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(
          const AuthError(message: 'Falha ao criar conta. Tente novamente.'),
        );
      }
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(
        const AuthError(
          message: 'Erro inesperado. Verifique sua conexão e tente novamente.',
        ),
      );
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(const AuthError(message: 'Erro ao fazer logout. Tente novamente.'));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // Em caso de erro ao verificar status, assume não autenticado
      emit(AuthUnauthenticated());
    }
  }

  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> updateUserPhotoURL(String photoURL) async {
    try {
      emit(AuthLoading());

      await _authRepository.updateUserPhotoURL(photoURL);
      await _authRepository.reloadUser();

      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(
          const AuthError(
            message: 'Erro ao obter dados atualizados do usuário.',
          ),
        );
      }
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(
        const AuthError(
          message: 'Erro inesperado ao atualizar foto do perfil.',
        ),
      );
    }
  }

  Future<void> updateUserDisplayName(String displayName) async {
    try {
      emit(AuthLoading());

      await _authRepository.updateUserDisplayName(displayName);
      await _authRepository.reloadUser();

      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(
          const AuthError(
            message: 'Erro ao obter dados atualizados do usuário.',
          ),
        );
      }
    } on AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(
        const AuthError(
          message: 'Erro inesperado ao atualizar nome de exibição.',
        ),
      );
    }
  }

  Future<void> refreshUserData() async {
    try {
      await _authRepository.reloadUser();
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      }
    } catch (e) {
      // Ignorar erros de refresh, manter estado atual
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
