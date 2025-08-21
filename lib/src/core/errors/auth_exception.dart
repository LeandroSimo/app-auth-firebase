import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;
  final String code;

  AuthException({required this.message, required this.code});

  static AuthException fromFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
          message: 'Usuário não encontrado. Verifique o e-mail informado.',
          code: e.code,
        );
      case 'wrong-password':
        return AuthException(
          message: 'Senha incorreta. Verifique sua senha e tente novamente.',
          code: e.code,
        );
      case 'invalid-email':
        return AuthException(
          message: 'E-mail inválido. Verifique o formato do e-mail.',
          code: e.code,
        );
      case 'user-disabled':
        return AuthException(
          message:
              'Esta conta foi desabilitada. Entre em contato com o suporte.',
          code: e.code,
        );
      case 'too-many-requests':
        return AuthException(
          message: 'Muitas tentativas de login. Tente novamente mais tarde.',
          code: e.code,
        );
      case 'operation-not-allowed':
        return AuthException(
          message: 'Operação não permitida. Entre em contato com o suporte.',
          code: e.code,
        );
      case 'email-already-in-use':
        return AuthException(
          message: 'Este e-mail já está sendo usado por outra conta.',
          code: e.code,
        );
      case 'weak-password':
        return AuthException(
          message: 'A senha é muito fraca. Use pelo menos 6 caracteres.',
          code: e.code,
        );
      case 'invalid-credential':
        return AuthException(
          message: 'Credenciais inválidas. Verifique seu e-mail e senha.',
          code: e.code,
        );
      case 'network-request-failed':
        return AuthException(
          message: 'Erro de conexão. Verifique sua internet e tente novamente.',
          code: e.code,
        );
      default:
        return AuthException(
          message:
              'Erro desconhecido: ${e.message ?? 'Tente novamente mais tarde.'}',
          code: e.code,
        );
    }
  }

  @override
  String toString() => message;
}
