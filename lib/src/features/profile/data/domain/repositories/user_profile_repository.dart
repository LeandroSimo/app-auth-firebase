import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> createUserProfile(UserProfile userProfile);
  Future<void> updateUserProfile(UserProfile userProfile);
  Future<void> deleteUserProfile(String userId);
}
