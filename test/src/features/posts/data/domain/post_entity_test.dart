import 'package:flutter_test/flutter_test.dart';
import 'package:app_test/src/features/posts/data/domain/entities/post.dart';

void main() {
  group('Post Entity Tests', () {
    late Post testPost;

    setUp(() {
      testPost = const Post(
        id: 1,
        title: 'Título do Post de Teste',
        body:
            'Este é o conteúdo do post de teste que contém informações suficientes para testar a funcionalidade de resumo e outras características da entidade Post.',
        userId: 123,
        userName: 'João Silva',
        userAvatar: 'https://example.com/avatar.jpg',
        image: 'https://example.com/post-image.jpg',
        likes: 42,
        comments: 15,
        createdAt: '2024-01-15T10:30:00Z',
        tags: ['tecnologia', 'flutter', 'dart'],
      );
    });

    group('Post Creation', () {
      test('should create a Post with all required fields', () {
        // Assert
        expect(testPost.id, equals(1));
        expect(testPost.title, equals('Título do Post de Teste'));
        expect(testPost.userName, equals('João Silva'));
        expect(testPost.likes, equals(42));
        expect(testPost.comments, equals(15));
        expect(testPost.tags, hasLength(3));
      });

      test('should be equal when posts have same properties', () {
        // Arrange
        const post1 = Post(
          id: 1,
          title: 'Título',
          body: 'Conteúdo',
          userId: 123,
          userName: 'Maria Santos',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: '2024-01-01T00:00:00Z',
          tags: [],
        );

        const post2 = Post(
          id: 1,
          title: 'Título',
          body: 'Conteúdo',
          userId: 123,
          userName: 'Maria Santos',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: '2024-01-01T00:00:00Z',
          tags: [],
        );

        // Assert
        expect(post1, equals(post2));
        expect(post1.hashCode, equals(post2.hashCode));
      });

      test('should be different when posts have different properties', () {
        // Arrange
        const post1 = Post(
          id: 1,
          title: 'Título 1',
          body: 'Conteúdo',
          userId: 123,
          userName: 'Ana Paula',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: '2024-01-01T00:00:00Z',
          tags: [],
        );

        const post2 = Post(
          id: 2,
          title: 'Título 2',
          body: 'Conteúdo',
          userId: 123,
          userName: 'Ana Paula',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: '2024-01-01T00:00:00Z',
          tags: [],
        );

        // Assert
        expect(post1, isNot(equals(post2)));
      });
    });

    group('DateTime Conversion', () {
      test('should parse valid ISO date string correctly', () {
        // Act
        final dateTime = testPost.createdAtDateTime;

        // Assert
        expect(dateTime.year, equals(2024));
        expect(dateTime.month, equals(1));
        expect(dateTime.day, equals(15));
        expect(dateTime.hour, equals(10));
        expect(dateTime.minute, equals(30));
      });

      test('should return current date for invalid date string', () {
        // Arrange
        const postWithInvalidDate = Post(
          id: 1,
          title: 'Título',
          body: 'Conteúdo',
          userId: 123,
          userName: 'Carlos Eduardo',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: 'invalid-date',
          tags: [],
        );

        final now = DateTime.now();

        // Act
        final dateTime = postWithInvalidDate.createdAtDateTime;

        // Assert
        final difference = now.difference(dateTime).inSeconds;
        expect(difference, lessThan(5)); // Should be within 5 seconds of now
      });
    });

    group('Time Ago Formatting', () {
      test('should return correct time ago for recent post', () {
        // Arrange
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        final post = Post(
          id: 1,
          title: 'Título',
          body: 'Conteúdo',
          userId: 123,
          userName: 'José',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: oneHourAgo.toIso8601String(),
          tags: [],
        );

        // Act
        final timeAgo = post.timeAgo;

        // Assert
        expect(timeAgo, equals('1h'));
      });

      test('should return "agora" for very recent post', () {
        // Arrange
        final now = DateTime.now();
        final post = Post(
          id: 1,
          title: 'Título',
          body: 'Conteúdo',
          userId: 123,
          userName: 'Pedro',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: now.toIso8601String(),
          tags: [],
        );

        // Act
        final timeAgo = post.timeAgo;

        // Assert
        expect(timeAgo, equals('agora'));
      });

      test('should return days for older posts', () {
        // Arrange
        final now = DateTime.now();
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        final post = Post(
          id: 1,
          title: 'Título',
          body: 'Conteúdo',
          userId: 123,
          userName: 'Fernanda',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: threeDaysAgo.toIso8601String(),
          tags: [],
        );

        // Act
        final timeAgo = post.timeAgo;

        // Assert
        expect(timeAgo, equals('3d'));
      });

      test('should return weeks for very old posts', () {
        // Arrange
        final now = DateTime.now();
        final twoWeeksAgo = now.subtract(const Duration(days: 14));
        final post = Post(
          id: 1,
          title: 'Título',
          body: 'Conteúdo',
          userId: 123,
          userName: 'Ricardo',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: twoWeeksAgo.toIso8601String(),
          tags: [],
        );

        // Act
        final timeAgo = post.timeAgo;

        // Assert
        expect(timeAgo, equals('2sem'));
      });
    });

    group('Content Summary', () {
      test('should return full content when body is short', () {
        // Arrange
        const shortPost = Post(
          id: 1,
          title: 'Título',
          body: 'Conteúdo curto',
          userId: 123,
          userName: 'Marcos',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: '2024-01-01T00:00:00Z',
          tags: [],
        );

        // Act
        final summary = shortPost.contentSummary;

        // Assert
        expect(summary, equals('Conteúdo curto'));
        expect(shortPost.isContentTruncated, isFalse);
      });

      test('should truncate content when body is long', () {
        // Arrange
        const longContent =
            'Este é um conteúdo muito longo que definitivamente excede os 100 caracteres e deve ser truncado para exibir apenas um resumo do conteúdo original.';
        const longPost = Post(
          id: 1,
          title: 'Título',
          body: longContent,
          userId: 123,
          userName: 'Lucia',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: '2024-01-01T00:00:00Z',
          tags: [],
        );

        // Act
        final summary = longPost.contentSummary;

        // Assert
        expect(summary.length, equals(103)); // 100 chars + '...'
        expect(summary, endsWith('...'));
        expect(longPost.isContentTruncated, isTrue);
      });

      test('should handle exactly 100 characters correctly', () {
        // Arrange
        final exactContent = '0123456789' * 10; // Exactly 100 characters
        final exactPost = Post(
          id: 1,
          title: 'Título',
          body: exactContent,
          userId: 123,
          userName: 'Gabriel',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: '2024-01-01T00:00:00Z',
          tags: [],
        );

        // Act
        final summary = exactPost.contentSummary;

        // Assert
        expect(summary, equals(exactContent));
        expect(exactPost.isContentTruncated, isFalse);
      });
    });

    group('String Representation', () {
      test('should return correct string representation', () {
        // Act
        final stringRepresentation = testPost.toString();

        // Assert
        expect(
          stringRepresentation,
          equals(
            'Post(id: 1, title: Título do Post de Teste, userId: 123, userName: João Silva)',
          ),
        );
      });
    });

    group('Tags Handling', () {
      test('should handle empty tags list', () {
        // Arrange
        const postWithoutTags = Post(
          id: 1,
          title: 'Título',
          body: 'Conteúdo',
          userId: 123,
          userName: 'Sandra',
          userAvatar: '',
          image: '',
          likes: 0,
          comments: 0,
          createdAt: '2024-01-01T00:00:00Z',
          tags: [],
        );

        // Assert
        expect(postWithoutTags.tags, isEmpty);
      });

      test('should handle multiple tags correctly', () {
        // Assert
        expect(testPost.tags, hasLength(3));
        expect(testPost.tags, contains('tecnologia'));
        expect(testPost.tags, contains('flutter'));
        expect(testPost.tags, contains('dart'));
      });
    });
  });
}
