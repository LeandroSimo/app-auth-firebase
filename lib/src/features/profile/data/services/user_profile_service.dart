import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/user_profile_repository.dart';
import '../repositories/firestore_user_profile_repository.dart';

class UserProfileService {
  late final UserProfileRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfileService({UserProfileRepository? repository}) {
    _repository = repository ?? FirestoreUserProfileRepository();
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final profile = await _repository.getUserProfile(userId);

      if (profile != null) {
        return profile;
      }

      // Se não encontrou o perfil e é o usuário atual, cria um perfil padrão
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        final defaultProfile = UserProfile(
          id: userId,
          name: currentUser.displayName ?? 'Usuário',
          email: currentUser.email ?? '',
          photoURL: currentUser.photoURL,
          postsCount: 5, // Valor padrão
          age: 29, // Valor padrão
          interests: [
            'Tecnologia',
            'Esportes',
            'Música',
            'Viagens',
            'Religião',
          ],
        );

        await _repository.createUserProfile(defaultProfile);
        return defaultProfile;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> createUserProfile({
    required String userId,
    String? name,
    int age = 29,
    List<String> interests = const [
      'Tecnologia',
      'Esportes',
      'Música',
      'Viagens',
      'Religião',
    ],
  }) async {
    try {
      final currentUser = _auth.currentUser;

      final profile = UserProfile(
        id: userId,
        name: name ?? currentUser?.displayName ?? 'Usuário',
        email: currentUser?.email ?? '',
        photoURL: currentUser?.photoURL,
        postsCount: 5, // Valor padrão
        age: age,
        interests: interests,
      );

      await _repository.createUserProfile(profile);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      await _repository.updateUserProfile(userProfile);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String userId) async {
    try {
      await _repository.deleteUserProfile(userId);
    } catch (e) {
      rethrow;
    }
  }
}
