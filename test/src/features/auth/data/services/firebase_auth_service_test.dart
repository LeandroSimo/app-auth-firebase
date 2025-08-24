import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:app_test/src/features/auth/data/services/firebase_auth_service.dart';
import 'package:app_test/src/core/errors/auth_exception.dart';

import '../../../../../mocks/firebase_mocks.mocks.dart';

void main() {
  group('FirebaseAuthService', () {
    late FirebaseAuthService firebaseAuthService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      firebaseAuthService = FirebaseAuthService(firebaseAuth: mockFirebaseAuth);
    });

    group('getCurrentUser', () {
      test('should return a user when user is logged in', () async {
        // Arrange
        const uid = 'test-uid';
        const email = 'test@test.com';
        const displayName = 'Test User';

        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(displayName);
        when(mockUser.photoURL).thenReturn(null);

        // Act
        final result = await firebaseAuthService.getCurrentUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.uid, equals(uid));
        expect(result.email, equals(email));
        expect(result.displayName, equals(displayName));
        expect(result.photoURL, isNull);
      });

      test('should return null when no user is logged in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await firebaseAuthService.getCurrentUser();

        // Assert
        expect(result, isNull);
      });

      test('should return null when exception occurs', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenThrow(Exception('Erro'));

        // Act
        final result = await firebaseAuthService.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('signInWithEmailAndPassword', () {
      test('should sign in successfully', () async {
        // Arrange
        const email = 'test@test.com';
        const password = 'password123';
        const uid = 'test-uid';
        const displayName = 'Test User';

        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(displayName);
        when(mockUser.photoURL).thenReturn(null);

        // Act
        final result = await firebaseAuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.uid, equals(uid));
        expect(result.email, equals(email));
        expect(result.displayName, equals(displayName));
        verify(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      });

      test('should return null when credential.user is null', () async {
        // Arrange
        const email = 'test@test.com';
        const password = 'password123';

        when(
          mockFirebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(null);

        // Act
        final result = await firebaseAuthService.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isNull);
      });

      test(
        'should throw AuthException when FirebaseAuthException is thrown',
        () async {
          // Arrange
          const email = 'invalid@test.com';
          const password = 'wrongpassword';

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenThrow(
            firebase_auth.FirebaseAuthException(
              code: 'user-not-found',
              message: 'User not found',
            ),
          );

          // Act & Assert
          expect(
            () => firebaseAuthService.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
            throwsA(isA<AuthException>()),
          );
        },
      );

      test(
        'should throw AuthException when generic exception is thrown',
        () async {
          // Arrange
          const email = 'test@test.com';
          const password = 'password123';

          when(
            mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenThrow(Exception('Generic error'));

          // Act & Assert
          expect(
            () => firebaseAuthService.signInWithEmailAndPassword(
              email: email,
              password: password,
            ),
            throwsA(isA<AuthException>()),
          );
        },
      );
    });

    group('createUserWithEmailAndPassword', () {
      test('should create user successfully', () async {
        // Arrange
        const email = 'newuser@test.com';
        const password = 'password123';
        const displayName = 'New User';
        const uid = 'new-user-uid';

        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(displayName);
        when(mockUser.photoURL).thenReturn(null);
        when(
          mockUser.updateDisplayName(displayName),
        ).thenAnswer((_) async => {});
        when(mockUser.reload()).thenAnswer((_) async => {});

        // Act
        final result = await firebaseAuthService.createUserWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.uid, equals(uid));
        expect(result.email, equals(email));
        expect(result.displayName, equals(displayName));
        verify(mockUser.updateDisplayName(displayName)).called(1);
        verify(mockUser.reload()).called(1);
      });

      test('should create user without displayName', () async {
        // Arrange
        const email = 'newuser@test.com';
        const password = 'password123';
        const uid = 'new-user-uid';

        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(null);
        when(mockUser.photoURL).thenReturn(null);

        // Act
        final result = await firebaseAuthService.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.uid, equals(uid));
        expect(result.email, equals(email));
        expect(result.displayName, isNull);
        verifyNever(mockUser.updateDisplayName(any));
        verifyNever(mockUser.reload());
      });

      test('should return null when credential.user is null', () async {
        // Arrange
        const email = 'newuser@test.com';
        const password = 'password123';

        when(
          mockFirebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(null);

        // Act
        final result = await firebaseAuthService.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isNull);
      });

      test(
        'should throw AuthException when FirebaseAuthException is thrown',
        () async {
          // Arrange
          const email = 'invalid-email';
          const password = 'password123';

          when(
            mockFirebaseAuth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            ),
          ).thenThrow(
            firebase_auth.FirebaseAuthException(
              code: 'invalid-email',
              message: 'Invalid email',
            ),
          );

          // Act & Assert
          expect(
            () => firebaseAuthService.createUserWithEmailAndPassword(
              email: email,
              password: password,
            ),
            throwsA(isA<AuthException>()),
          );
        },
      );
    });

    group('signOut', () {
      test('should sign out successfully', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});

        // Act
        await firebaseAuthService.signOut();

        // Assert
        verify(mockFirebaseAuth.signOut()).called(1);
      });

      test(
        'should throw AuthException when FirebaseAuthException is thrown',
        () async {
          // Arrange
          when(mockFirebaseAuth.signOut()).thenThrow(
            firebase_auth.FirebaseAuthException(
              code: 'unknown',
              message: 'Unknown error',
            ),
          );

          // Act & Assert
          expect(
            () => firebaseAuthService.signOut(),
            throwsA(isA<AuthException>()),
          );
        },
      );

      test(
        'should throw AuthException when generic exception is thrown',
        () async {
          // Arrange
          when(
            mockFirebaseAuth.signOut(),
          ).thenThrow(Exception('Generic error'));

          // Act & Assert
          expect(
            () => firebaseAuthService.signOut(),
            throwsA(isA<AuthException>()),
          );
        },
      );
    });

    group('updateUserPhotoURL', () {
      test('should update user photo URL successfully', () async {
        // Arrange
        const photoURL = 'https://example.com/photo.jpg';

        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.updatePhotoURL(photoURL)).thenAnswer((_) async => {});
        when(mockUser.reload()).thenAnswer((_) async => {});

        // Act
        await firebaseAuthService.updateUserPhotoURL(photoURL);

        // Assert
        verify(mockUser.updatePhotoURL(photoURL)).called(1);
        verify(mockUser.reload()).called(1);
      });

      test('should throw AuthException when user is not logged in', () async {
        // Arrange
        const photoURL = 'https://example.com/photo.jpg';

        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => firebaseAuthService.updateUserPhotoURL(photoURL),
          throwsA(isA<AuthException>()),
        );
      });

      test(
        'should throw AuthException when FirebaseAuthException is thrown',
        () async {
          // Arrange
          const photoURL = 'https://example.com/photo.jpg';

          when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
          when(mockUser.updatePhotoURL(photoURL)).thenThrow(
            firebase_auth.FirebaseAuthException(
              code: 'unknown',
              message: 'Unknown error',
            ),
          );

          // Act & Assert
          expect(
            () => firebaseAuthService.updateUserPhotoURL(photoURL),
            throwsA(isA<AuthException>()),
          );
        },
      );
    });

    group('updateUserDisplayName', () {
      test('should update user display name successfully', () async {
        // Arrange
        const displayName = 'New Display Name';

        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(
          mockUser.updateDisplayName(displayName),
        ).thenAnswer((_) async => {});
        when(mockUser.reload()).thenAnswer((_) async => {});

        // Act
        await firebaseAuthService.updateUserDisplayName(displayName);

        // Assert
        verify(mockUser.updateDisplayName(displayName)).called(1);
        verify(mockUser.reload()).called(1);
      });

      test('should throw AuthException when user is not logged in', () async {
        // Arrange
        const displayName = 'New Display Name';

        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => firebaseAuthService.updateUserDisplayName(displayName),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('reloadUser', () {
      test('should reload user successfully', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.reload()).thenAnswer((_) async => {});

        // Act
        await firebaseAuthService.reloadUser();

        // Assert
        verify(mockUser.reload()).called(1);
      });

      test('should do nothing when user is not logged in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        await firebaseAuthService.reloadUser();

        // Assert
        verifyNever(mockUser.reload());
      });

      test('should ignore reload errors', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(mockUser.reload()).thenThrow(Exception('Reload error'));

        // Act & Assert - Não deve lançar exceção
        await firebaseAuthService.reloadUser();
      });
    });

    group('authStateChanges', () {
      test('should return stream with logged in user', () async {
        // Arrange
        const uid = 'test-uid';
        const email = 'test@test.com';

        when(mockUser.uid).thenReturn(uid);
        when(mockUser.email).thenReturn(email);
        when(mockUser.displayName).thenReturn(null);
        when(mockUser.photoURL).thenReturn(null);

        when(
          mockFirebaseAuth.authStateChanges(),
        ).thenAnswer((_) => Stream.value(mockUser));

        // Act
        final stream = firebaseAuthService.authStateChanges;
        final result = await stream.first;

        // Assert
        expect(result, isNotNull);
        expect(result!.uid, equals(uid));
        expect(result.email, equals(email));
      });

      test(
        'should return stream with null when user is not logged in',
        () async {
          // Arrange
          when(
            mockFirebaseAuth.authStateChanges(),
          ).thenAnswer((_) => Stream.value(null));

          // Act
          final stream = firebaseAuthService.authStateChanges;
          final result = await stream.first;

          // Assert
          expect(result, isNull);
        },
      );

      test('should return stream with null when error occurs', () async {
        // Arrange
        when(
          mockFirebaseAuth.authStateChanges(),
        ).thenThrow(Exception('Stream error'));

        // Act
        final stream = firebaseAuthService.authStateChanges;
        final result = await stream.first;

        // Assert
        expect(result, isNull);
      });
    });
  });
}
