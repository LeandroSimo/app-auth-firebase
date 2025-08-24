import 'package:flutter_test/flutter_test.dart';

/// Pure unit tests - no Firebase dependencies
/// These tests can be executed without additional configuration
void main() {
  group('Pure Unit Tests', () {
    group('Email Validation', () {
      test('should validate valid email', () {
        // Arrange
        const validEmail = 'usuario@exemplo.com';

        // Act
        final isValid = _isValidEmail(validEmail);

        // Assert
        expect(isValid, isTrue);
      });

      test('should reject invalid email', () {
        // Arrange
        const invalidEmails = [
          '',
          'email-sem-arroba',
          '@dominio.com',
          'usuario@',
          'usuario@dominio',
          'usuario.dominio.com',
        ];

        // Act & Assert
        for (final email in invalidEmails) {
          final isValid = _isValidEmail(email);
          expect(isValid, isFalse, reason: 'Email "$email" should be invalid');
        }
      });
    });

    group('Password Validation', () {
      test('should validate strong password', () {
        // Arrange
        const strongPasswords = [
          'MinhaSenh@123',
          'P@ssw0rd!',
          'Teste123!@#',
          'SenhaForte2024!',
        ];

        // Act & Assert
        for (final password in strongPasswords) {
          final isStrong = _isStrongPassword(password);
          expect(
            isStrong,
            isTrue,
            reason: 'Password "$password" should be strong',
          );
        }
      });

      test('should reject weak password', () {
        // Arrange
        const weakPasswords = [
          '',
          '123',
          '12345',
          'senha',
          'password',
          'abc123',
        ];

        // Act & Assert
        for (final password in weakPasswords) {
          final isStrong = _isStrongPassword(password);
          expect(
            isStrong,
            isFalse,
            reason: 'Password "$password" should be weak',
          );
        }
      });
    });

    group('Name Validation', () {
      test('should validate valid name', () {
        // Arrange
        const validNames = [
          'João Silva',
          'Maria Santos',
          'José',
          'Ana Paula',
          'Carlos Eduardo',
        ];

        // Act & Assert
        for (final name in validNames) {
          final isValid = _isValidName(name);
          expect(isValid, isTrue, reason: 'Name "$name" should be valid');
        }
      });

      test('should reject invalid name', () {
        // Arrange
        const invalidNames = ['', ' ', 'A', '   '];

        // Act & Assert
        for (final name in invalidNames) {
          final isValid = _isValidName(name);
          expect(isValid, isFalse, reason: 'Name "$name" should be invalid');
        }
      });
    });

    group('File Validation', () {
      test('should validate allowed image extensions', () {
        // Arrange
        const validFiles = [
          'foto.jpg',
          'imagem.jpeg',
          'perfil.png',
          'avatar.JPG',
          'imagem.PNG',
        ];

        // Act & Assert
        for (final fileName in validFiles) {
          final isValid = _isValidImageFile(fileName);
          expect(isValid, isTrue, reason: 'File "$fileName" should be valid');
        }
      });

      test('should reject non-allowed extensions', () {
        // Arrange
        const invalidFiles = [
          'documento.pdf',
          'video.mp4',
          'audio.mp3',
          'arquivo.txt',
          'imagem.gif',
          'foto.bmp',
        ];

        // Act & Assert
        for (final fileName in invalidFiles) {
          final isValid = _isValidImageFile(fileName);
          expect(
            isValid,
            isFalse,
            reason: 'File "$fileName" should be invalid',
          );
        }
      });

      test('should validate file size', () {
        // Arrange
        const maxSizeInMB = 5;
        const maxSizeInBytes = maxSizeInMB * 1024 * 1024;

        // Act & Assert
        expect(_isValidFileSize(1024 * 1024, maxSizeInBytes), isTrue); // 1MB
        expect(
          _isValidFileSize(3 * 1024 * 1024, maxSizeInBytes),
          isTrue,
        ); // 3MB
        expect(
          _isValidFileSize(5 * 1024 * 1024, maxSizeInBytes),
          isTrue,
        ); // 5MB
        expect(
          _isValidFileSize(6 * 1024 * 1024, maxSizeInBytes),
          isFalse,
        ); // 6MB
        expect(
          _isValidFileSize(10 * 1024 * 1024, maxSizeInBytes),
          isFalse,
        ); // 10MB
      });
    });

    group('String Utilities', () {
      test('should generate unique filename', () {
        // Arrange
        const userId = 'user123';
        const extension = '.jpg';

        // Act
        final fileName = _generateUniqueFileName(userId, extension);

        // Assert
        expect(fileName, startsWith('profile_'));
        expect(fileName, contains(userId));
        expect(fileName, endsWith(extension));
      });

      test('should format name for display', () {
        // Arrange
        const rawName = '  João Silva  ';

        // Act
        final formatted = _formatDisplayName(rawName);

        // Assert
        expect(formatted, equals('João Silva'));
        expect(formatted.trim(), equals(formatted));
      });
    });

    group('Application States', () {
      test('should create loading state', () {
        // Arrange & Act
        final loadingState = _createLoadingState();

        // Assert
        expect(loadingState['isLoading'], isTrue);
        expect(loadingState['error'], isNull);
        expect(loadingState['data'], isNull);
      });

      test('should create success state', () {
        // Arrange
        const data = {'name': 'João', 'email': 'joao@test.com'};

        // Act
        final successState = _createSuccessState(data);

        // Assert
        expect(successState['isLoading'], isFalse);
        expect(successState['error'], isNull);
        expect(successState['data'], equals(data));
      });

      test('should create error state', () {
        // Arrange
        const errorMessage = 'Authentication failed';

        // Act
        final errorState = _createErrorState(errorMessage);

        // Assert
        expect(errorState['isLoading'], isFalse);
        expect(errorState['error'], equals(errorMessage));
        expect(errorState['data'], isNull);
      });
    });

    group('Data Manipulation', () {
      test('should convert interest to standardized format', () {
        // Arrange
        const interests = ['  tecnologia  ', 'ESPORTES', 'música'];

        // Act
        final normalized = _normalizeInterests(interests);

        // Assert
        expect(normalized, equals(['Tecnologia', 'Esportes', 'Música']));
      });

      test('should filter empty interests', () {
        // Arrange
        const interests = ['Tecnologia', '', '  ', 'Esportes', null];

        // Act
        final filtered = _filterValidInterests(interests);

        // Assert
        expect(filtered, equals(['Tecnologia', 'Esportes']));
      });
    });
  });
}

// ========== Validation helper functions ==========

bool _isValidEmail(String email) {
  if (email.isEmpty) return false;
  return RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);
}

bool _isStrongPassword(String password) {
  if (password.length < 8) return false;

  // Check if it has at least uppercase, lowercase, number and special character
  final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
  final hasLowercase = RegExp(r'[a-z]').hasMatch(password);
  final hasNumber = RegExp(r'[0-9]').hasMatch(password);
  final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

  return hasUppercase && hasLowercase && hasNumber && hasSpecialChar;
}

bool _isValidName(String name) {
  final trimmed = name.trim();
  return trimmed.isNotEmpty && trimmed.length >= 2;
}

bool _isValidImageFile(String fileName) {
  const allowedExtensions = ['.jpg', '.jpeg', '.png'];
  final lowerFileName = fileName.toLowerCase();
  return allowedExtensions.any((ext) => lowerFileName.endsWith(ext));
}

bool _isValidFileSize(int fileSizeInBytes, int maxSizeInBytes) {
  return fileSizeInBytes <= maxSizeInBytes;
}

String _generateUniqueFileName(String userId, String extension) {
  return 'profile_${userId}$extension';
}

String _formatDisplayName(String name) {
  return name.trim();
}

Map<String, dynamic> _createLoadingState() {
  return {'isLoading': true, 'error': null, 'data': null};
}

Map<String, dynamic> _createSuccessState(dynamic data) {
  return {'isLoading': false, 'error': null, 'data': data};
}

Map<String, dynamic> _createErrorState(String error) {
  return {'isLoading': false, 'error': error, 'data': null};
}

List<String> _normalizeInterests(List<String> interests) {
  return interests
      .map((interest) => interest.trim())
      .where((interest) => interest.isNotEmpty)
      .map(
        (interest) =>
            interest[0].toUpperCase() + interest.substring(1).toLowerCase(),
      )
      .toList();
}

List<String> _filterValidInterests(List<String?> interests) {
  return interests
      .where((interest) => interest != null && interest.trim().isNotEmpty)
      .map((interest) => interest!)
      .toList();
}
