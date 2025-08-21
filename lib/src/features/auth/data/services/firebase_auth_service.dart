import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';
import '../domain/entities/user.dart' as domain;

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthService({firebase_auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  // Stream de mudanças no estado de autenticação
  Stream<domain.User?> get authStateChanges {
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
  }

  // Usuário atual
  Future<domain.User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final userModel = UserModel.fromFirebaseUser(firebaseUser);
    return domain.User(
      uid: userModel.uid,
      email: userModel.email,
      displayName: userModel.displayName,
      photoURL: userModel.photoURL,
    );
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
    } catch (e) {
      throw Exception('Erro ao fazer login: ${e.toString()}');
    }
  }

  // Criar conta com email e senha
  Future<domain.User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
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
    } catch (e) {
      throw Exception('Erro ao criar conta: ${e.toString()}');
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Erro ao fazer logout: ${e.toString()}');
    }
  }
}
