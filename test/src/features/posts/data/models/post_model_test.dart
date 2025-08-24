import 'package:flutter_test/flutter_test.dart';
import 'package:app_test/src/features/posts/data/models/post_model.dart';

void main() {
  group('PostModel Tests', () {
    late Map<String, dynamic> validJsonData;
    late PostModel testPostModel;

    setUp(() {
      validJsonData = {
        'id': 1,
        'title': 'Título do Post de Teste',
        'body':
            'Este é o conteúdo do post de teste que contém informações suficientes para testar a funcionalidade.',
        'userId': 123,
        'userName': 'João Silva',
        'userAvatar': 'https://example.com/avatar.jpg',
        'image': 'https://example.com/post-image.jpg',
        'likes': 42,
        'comments': 15,
        'createdAt': '2024-01-15T10:30:00Z',
        'tags': ['tecnologia', 'flutter', 'dart'],
      };

      testPostModel = PostModel.fromJson(validJsonData);
    });

    group('JSON Serialization', () {
      test('should create PostModel from valid JSON', () {
        // Act
        final postModel = PostModel.fromJson(validJsonData);

        // Assert
        expect(postModel.id, equals(1));
        expect(postModel.title, equals('Título do Post de Teste'));
        expect(postModel.userName, equals('João Silva'));
        expect(postModel.likes, equals(42));
        expect(postModel.comments, equals(15));
        expect(postModel.tags, hasLength(3));
        expect(postModel.tags, contains('tecnologia'));
      });

      test('should convert PostModel to JSON correctly', () {
        // Act
        final json = testPostModel.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['title'], equals('Título do Post de Teste'));
        expect(json['userName'], equals('João Silva'));
        expect(json['likes'], equals(42));
        expect(json['comments'], equals(15));
        expect(json['tags'], isA<List<String>>());
        expect(json['tags'], hasLength(3));
      });

      test('should handle JSON roundtrip correctly', () {
        // Act
        final json = testPostModel.toJson();
        final recreatedModel = PostModel.fromJson(json);

        // Assert
        expect(recreatedModel.id, equals(testPostModel.id));
        expect(recreatedModel.title, equals(testPostModel.title));
        expect(recreatedModel.userName, equals(testPostModel.userName));
        expect(recreatedModel.tags, equals(testPostModel.tags));
      });
    });

    group('Data Type Parsing', () {
      test('should handle string IDs correctly', () {
        // Arrange
        final jsonWithStringId = {
          ...validJsonData,
          'id': '42',
          'userId': '789',
          'likes': '100',
          'comments': '25',
        };

        // Act
        final postModel = PostModel.fromJson(jsonWithStringId);

        // Assert
        expect(postModel.id, equals(42));
        expect(postModel.userId, equals(789));
        expect(postModel.likes, equals(100));
        expect(postModel.comments, equals(25));
      });

      test('should handle null values with defaults', () {
        // Arrange
        final jsonWithNulls = {
          'id': null,
          'title': null,
          'body': null,
          'userId': null,
          'userName': null,
          'userAvatar': null,
          'image': null,
          'likes': null,
          'comments': null,
          'createdAt': null,
          'tags': null,
        };

        // Act
        final postModel = PostModel.fromJson(jsonWithNulls);

        // Assert
        expect(postModel.id, equals(0));
        expect(postModel.title, isEmpty);
        expect(postModel.body, isEmpty);
        expect(postModel.userId, equals(0));
        expect(postModel.userName, isEmpty);
        expect(postModel.userAvatar, isEmpty);
        expect(postModel.image, isEmpty);
        expect(postModel.likes, equals(0));
        expect(postModel.comments, equals(0));
        expect(postModel.createdAt, isEmpty);
        expect(postModel.tags, isEmpty);
      });

      test('should handle missing fields gracefully', () {
        // Arrange
        final incompleteJson = {
          'id': 1,
          'title': 'Título Teste',
          // Missing other fields
        };

        // Act
        final postModel = PostModel.fromJson(incompleteJson);

        // Assert
        expect(postModel.id, equals(1));
        expect(postModel.title, equals('Título Teste'));
        expect(postModel.body, isEmpty);
        expect(postModel.userName, isEmpty);
        expect(postModel.likes, equals(0));
        expect(postModel.tags, isEmpty);
      });

      test('should handle invalid numeric strings', () {
        // Arrange
        final jsonWithInvalidNumbers = {
          ...validJsonData,
          'id': 'not-a-number',
          'likes': 'invalid',
          'comments': 'abc',
        };

        // Act
        final postModel = PostModel.fromJson(jsonWithInvalidNumbers);

        // Assert
        expect(postModel.id, equals(0));
        expect(postModel.likes, equals(0));
        expect(postModel.comments, equals(0));
      });

      test('should handle various tag formats', () {
        // Arrange
        final jsonWithDifferentTags = {
          ...validJsonData,
          'tags': ['tag1', 2, true, null, 'tag2'],
        };

        // Act
        final postModel = PostModel.fromJson(jsonWithDifferentTags);

        // Assert
        expect(postModel.tags, hasLength(5));
        expect(postModel.tags[0], equals('tag1'));
        expect(postModel.tags[1], equals('2'));
        expect(postModel.tags[2], equals('true'));
        expect(postModel.tags[3], equals('null'));
        expect(postModel.tags[4], equals('tag2'));
      });

      test('should handle empty tags array', () {
        // Arrange
        final jsonWithEmptyTags = {...validJsonData, 'tags': []};

        // Act
        final postModel = PostModel.fromJson(jsonWithEmptyTags);

        // Assert
        expect(postModel.tags, isEmpty);
      });

      test('should handle non-array tags', () {
        // Arrange
        final jsonWithNonArrayTags = {...validJsonData, 'tags': 'single-tag'};

        // Act
        final postModel = PostModel.fromJson(jsonWithNonArrayTags);

        // Assert
        expect(postModel.tags, isEmpty);
      });
    });

    group('DateTime and Time Functions', () {
      test('should parse valid ISO date string correctly', () {
        // Act
        final dateTime = testPostModel.createdAtDateTime;

        // Assert
        expect(dateTime.year, equals(2024));
        expect(dateTime.month, equals(1));
        expect(dateTime.day, equals(15));
        expect(dateTime.hour, equals(10));
        expect(dateTime.minute, equals(30));
      });

      test('should return current date for invalid date string', () {
        // Arrange
        final jsonWithInvalidDate = {
          ...validJsonData,
          'createdAt': 'invalid-date-format',
        };
        final postModel = PostModel.fromJson(jsonWithInvalidDate);
        final now = DateTime.now();

        // Act
        final dateTime = postModel.createdAtDateTime;

        // Assert
        final difference = now.difference(dateTime).inSeconds;
        expect(difference, lessThan(5));
      });

      test('should format time ago correctly for minutes', () {
        // Arrange
        final thirtyMinutesAgo = DateTime.now().subtract(
          const Duration(minutes: 30),
        );
        final jsonWithRecentDate = {
          ...validJsonData,
          'createdAt': thirtyMinutesAgo.toIso8601String(),
        };
        final postModel = PostModel.fromJson(jsonWithRecentDate);

        // Act
        final timeAgo = postModel.timeAgo;

        // Assert
        expect(timeAgo, equals('30min'));
      });

      test('should format time ago correctly for hours', () {
        // Arrange
        final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
        final jsonWithRecentDate = {
          ...validJsonData,
          'createdAt': twoHoursAgo.toIso8601String(),
        };
        final postModel = PostModel.fromJson(jsonWithRecentDate);

        // Act
        final timeAgo = postModel.timeAgo;

        // Assert
        expect(timeAgo, equals('2h'));
      });
    });

    group('Content Summary Features', () {
      test('should return full content when body is short', () {
        // Arrange
        final jsonWithShortContent = {
          ...validJsonData,
          'body': 'Conteúdo curto',
        };
        final postModel = PostModel.fromJson(jsonWithShortContent);

        // Act
        final summary = postModel.contentSummary;

        // Assert
        expect(summary, equals('Conteúdo curto'));
        expect(postModel.isContentTruncated, isFalse);
      });

      test('should truncate long content with ellipsis', () {
        // Arrange
        final longContent =
            'Este é um conteúdo muito longo que definitivamente excede os 100 caracteres e deve ser truncado para exibir apenas um resumo do conteúdo original para o usuário.';
        final jsonWithLongContent = {...validJsonData, 'body': longContent};
        final postModel = PostModel.fromJson(jsonWithLongContent);

        // Act
        final summary = postModel.contentSummary;

        // Assert
        expect(summary.length, equals(103)); // 100 chars + '...'
        expect(summary, endsWith('...'));
        expect(postModel.isContentTruncated, isTrue);
      });

      test('should handle empty body correctly', () {
        // Arrange
        final jsonWithEmptyBody = {...validJsonData, 'body': ''};
        final postModel = PostModel.fromJson(jsonWithEmptyBody);

        // Act
        final summary = postModel.contentSummary;

        // Assert
        expect(summary, isEmpty);
        expect(postModel.isContentTruncated, isFalse);
      });
    });

    group('String Representation', () {
      test('should return correct string representation', () {
        // Act
        final stringRepresentation = testPostModel.toString();

        // Assert
        expect(
          stringRepresentation,
          equals(
            'PostModel(id: 1, title: Título do Post de Teste, userId: 123, userName: João Silva)',
          ),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle extremely large numbers', () {
        // Arrange
        final jsonWithLargeNumbers = {
          ...validJsonData,
          'id': 999999999,
          'likes': 1000000,
          'comments': 500000,
        };

        // Act
        final postModel = PostModel.fromJson(jsonWithLargeNumbers);

        // Assert
        expect(postModel.id, equals(999999999));
        expect(postModel.likes, equals(1000000));
        expect(postModel.comments, equals(500000));
      });

      test('should handle special characters in text fields', () {
        // Arrange
        final jsonWithSpecialChars = {
          ...validJsonData,
          'title': 'Título com ÇãrÁctêrês Éspëciáis',
          'body': 'Conteúdo com símbolos: @#\$%^&*()_+{}[]',
          'userName': 'José da Silva Ção',
        };

        // Act
        final postModel = PostModel.fromJson(jsonWithSpecialChars);

        // Assert
        expect(postModel.title, equals('Título com ÇãrÁctêrês Éspëciáis'));
        expect(postModel.body, contains('@#\$%^&*()_+{}[]'));
        expect(postModel.userName, equals('José da Silva Ção'));
      });

      test('should handle very long URLs', () {
        // Arrange
        final veryLongUrl = 'https://example.com/' + 'a' * 1000 + '.jpg';
        final jsonWithLongUrls = {
          ...validJsonData,
          'userAvatar': veryLongUrl,
          'image': veryLongUrl,
        };

        // Act
        final postModel = PostModel.fromJson(jsonWithLongUrls);

        // Assert
        expect(postModel.userAvatar, equals(veryLongUrl));
        expect(postModel.image, equals(veryLongUrl));
      });
    });
  });
}
