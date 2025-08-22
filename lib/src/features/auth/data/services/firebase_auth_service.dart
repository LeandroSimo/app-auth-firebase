import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../domain/entities/user.dart' as domain;
import '../../../../core/errors/auth_exception.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthService({firebase_auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  // Stream de mudanças no estado de autenticação
  Stream<domain.User?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges().map((firebaseUser) {
        if (firebaseUser == null) return null;
        final userModel = UserModel.fromFirebaseUser(firebaseUser);
        return domain.User(
          uid: userModel.uid,
          email: userModel.email,
          displayName: userModel.displayName,
          photoURL: userModel.photoURL,
        );
      });
    } catch (e) {
      // Em caso de erro no stream, retorna um stream que emite null
      return Stream.value(null);
    }
  }

  // Usuário atual
  Future<domain.User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final userModel = UserModel.fromFirebaseUser(firebaseUser);
      return domain.User(
        uid: userModel.uid,
        email: userModel.email,
        displayName: userModel.displayName,
        photoURL: userModel.photoURL,
      );
    } catch (e) {
      // Se houver erro ao obter usuário atual, retorna null
      return null;
    }
  }

  // Login com email e senha
  Future<domain.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      final userModel = UserModel.fromFirebaseUser(credential.user!);
      return domain.User(
        uid: userModel.uid,
        email: userModel.email,
        displayName: userModel.displayName,
        photoURL: userModel.photoURL,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Erro inesperado ao fazer login. Tente novamente.',
        code: 'unknown-error',
      );
    }
  }

  // Criar conta com email e senha
  Future<domain.User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      // Atualiza o displayName se fornecido
      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user!.updateDisplayName(displayName.trim());
        await credential.user!.reload();
      }

      final userModel = UserModel.fromFirebaseUser(credential.user!);
      return domain.User(
        uid: userModel.uid,
        email: userModel.email,
        displayName: displayName?.trim() ?? userModel.displayName,
        photoURL: userModel.photoURL,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Erro inesperado ao criar conta. Tente novamente.',
        code: 'unknown-error',
      );
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Erro inesperado ao fazer logout. Tente novamente.',
        code: 'unknown-error',
      );
    }
  }
}
