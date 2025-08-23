import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/user_profile_repository.dart';
import '../models/user_profile_model.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return null;
      }

      // Obtém dados do usuário atual do Firebase Auth
      final currentUser = _auth.currentUser;

      // Cria o modelo com dados do Firestore + Firebase Auth
      final model = UserProfileModel.fromFirestore(doc);

      // Retorna a entidade com dados atualizados do Firebase Auth se for o usuário atual
      if (currentUser != null && currentUser.uid == userId) {
        return model.toEntity().copyWith(
          name: currentUser.displayName ?? model.name,
          email: currentUser.email ?? model.email,
          photoURL: currentUser.photoURL ?? model.photoURL,
        );
      }

      return model.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createUserProfile(UserProfile userProfile) async {
    try {
      final model = UserProfileModel.fromEntity(userProfile);
      await _firestore
          .collection('users')
          .doc(userProfile.id)
          .set(model.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      final model = UserProfileModel.fromEntity(userProfile);
      await _firestore
          .collection('users')
          .doc(userProfile.id)
          .set(model.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      rethrow;
    }
  }
}
