import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signOut();

  Future<User?> getCurrentUser();

  Stream<User?> get authStateChanges;

  Future<void> updateUserPhotoURL(String photoURL);

  Future<void> updateUserDisplayName(String displayName);

  Future<void> reloadUser();
}
