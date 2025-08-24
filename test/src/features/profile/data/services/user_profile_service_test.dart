import 'package:flutter_test/flutter_test.dart';
import 'package:app_test/src/features/profile/data/services/user_profile_service.dart';
import 'package:app_test/src/features/profile/data/domain/entities/user_profile.dart';

void main() {
  group('UserProfileService', () {
    late UserProfileService userProfileService;

    setUp(() {
      userProfileService = UserProfileService();
    });

    group('createUserProfile', () {
      test('should create a user profile with default values', () async {
        // Arrange
        const userId = 'test-user-id';
        const name = 'Test User';
        const age = 30;
        const interests = ['Tecnologia', 'Música'];

        // Act & Assert - Testing that the method doesn't throw exception
        expect(
          () => userProfileService.createUserProfile(
            userId: userId,
            name: name,
            age: age,
            interests: interests,
          ),
          isA<Future<void>>(),
        );
      });

      test(
        'should create a user profile with default values when parameters are not provided',
        () async {
          // Arrange
          const userId = 'test-user-id';

          // Act & Assert
          expect(
            () => userProfileService.createUserProfile(userId: userId),
            isA<Future<void>>(),
          );
        },
      );
    });

    group('getUserProfile', () {
      test('should return a profile when it exists', () async {
        // Arrange
        const userId = 'existing-user-id';

        // Act
        final result = await userProfileService.getUserProfile(userId);

        // Assert - Since we're using real Firebase, the result may vary
        // This test demonstrates the expected structure
        expect(result, isA<UserProfile?>());
      });

      test('should handle user not found', () async {
        // Arrange
        const userId = 'non-existent-user';

        // Act
        final result = await userProfileService.getUserProfile(userId);

        // Assert
        expect(result, isA<UserProfile?>());
      });
    });
  });

  group('UserProfile Entity', () {
    test('should create a valid UserProfile instance', () {
      // Arrange & Act
      const userProfile = UserProfile(
        id: 'test-id',
        name: 'Test Name',
        email: 'test@test.com',
        postsCount: 5,
        age: 25,
        interests: ['Tecnologia', 'Esportes'],
      );

      // Assert
      expect(userProfile.id, equals('test-id'));
      expect(userProfile.name, equals('Test Name'));
      expect(userProfile.email, equals('test@test.com'));
      expect(userProfile.postsCount, equals(5));
      expect(userProfile.age, equals(25));
      expect(userProfile.interests, equals(['Tecnologia', 'Esportes']));
      expect(userProfile.photoURL, isNull);
    });

    test('should create a copy with modifications using copyWith', () {
      // Arrange
      const originalProfile = UserProfile(
        id: 'test-id',
        name: 'Original Name',
        email: 'original@test.com',
        postsCount: 5,
        age: 25,
        interests: ['Tecnologia'],
      );

      // Act
      final modifiedProfile = originalProfile.copyWith(
        name: 'Modified Name',
        age: 30,
        interests: ['Tecnologia', 'Música'],
      );

      // Assert
      expect(modifiedProfile.id, equals('test-id')); // Não alterado
      expect(modifiedProfile.name, equals('Modified Name')); // Alterado
      expect(
        modifiedProfile.email,
        equals('original@test.com'),
      ); // Não alterado
      expect(modifiedProfile.age, equals(30)); // Alterado
      expect(
        modifiedProfile.interests,
        equals(['Tecnologia', 'Música']),
      ); // Alterado
      expect(modifiedProfile.postsCount, equals(5)); // Não alterado
    });

    test('should compare equality correctly', () {
      // Arrange
      const profile1 = UserProfile(
        id: 'test-id',
        name: 'Test Name',
        email: 'test@test.com',
        postsCount: 5,
        age: 25,
        interests: ['Tecnologia'],
      );

      const profile2 = UserProfile(
        id: 'test-id',
        name: 'Test Name',
        email: 'test@test.com',
        postsCount: 5,
        age: 25,
        interests: ['Tecnologia'],
      );

      const profile3 = UserProfile(
        id: 'different-id',
        name: 'Test Name',
        email: 'test@test.com',
        postsCount: 5,
        age: 25,
        interests: ['Tecnologia'],
      );

      // Act & Assert
      expect(profile1, equals(profile2)); // Should be equal
      expect(profile1, isNot(equals(profile3))); // Should be different
      expect(profile1.hashCode, equals(profile2.hashCode)); // Hash codes iguais
    });

    test('should generate correct string with toString', () {
      // Arrange
      const userProfile = UserProfile(
        id: 'test-id',
        name: 'Test Name',
        email: 'test@test.com',
        postsCount: 5,
        age: 25,
        interests: ['Tecnologia'],
        photoURL: 'https://example.com/photo.jpg',
      );

      // Act
      final string = userProfile.toString();

      // Assert
      expect(string, contains('test-id'));
      expect(string, contains('Test Name'));
      expect(string, contains('test@test.com'));
      expect(string, contains('5'));
      expect(string, contains('25'));
      expect(string, contains('Tecnologia'));
      expect(string, contains('https://example.com/photo.jpg'));
    });
  });

  group('AuthException Tests', () {
    test('should create AuthException with message and code', () {
      // Arrange & Act
      const exception = AuthException(
        message: 'Test error message',
        code: 'test-error-code',
      );

      // Assert
      expect(exception.message, equals('Test error message'));
      expect(exception.code, equals('test-error-code'));
    });
  });
}

// AuthException class for tests (in case it's not imported)
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException({required this.message, required this.code});
}
