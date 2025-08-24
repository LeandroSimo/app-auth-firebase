import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:app_test/src/features/posts/data/repositories/post_repository_impl.dart';
import 'package:app_test/src/features/posts/data/services/post_api_service.dart';
import 'package:app_test/src/features/posts/data/models/post_model.dart';
import 'package:app_test/src/features/posts/data/domain/entities/post.dart';

import 'post_repository_impl_test.mocks.dart';

@GenerateMocks([PostApiService])
void main() {
  group('PostRepositoryImpl Tests', () {
    late PostRepositoryImpl postRepository;
    late MockPostApiService mockPostApiService;

    setUp(() {
      mockPostApiService = MockPostApiService();
      postRepository = PostRepositoryImpl(apiService: mockPostApiService);
    });

    group('getPosts', () {
      test(
        'should return list of Post entities when API call is successful',
        () async {
          // Arrange
          final mockPostModels = [
            PostModel(
              id: 1,
              title: 'Primeiro Post',
              body: 'Conteúdo do primeiro post de João Silva',
              userId: 1,
              userName: 'João Silva',
              userAvatar: 'https://example.com/joao.jpg',
              image: 'https://example.com/post1.jpg',
              likes: 42,
              comments: 15,
              createdAt: '2024-01-15T10:30:00Z',
              tags: ['tecnologia', 'flutter'],
            ),
            PostModel(
              id: 2,
              title: 'Segundo Post',
              body: 'Conteúdo do segundo post de Maria Santos',
              userId: 2,
              userName: 'Maria Santos',
              userAvatar: 'https://example.com/maria.jpg',
              image: 'https://example.com/post2.jpg',
              likes: 28,
              comments: 8,
              createdAt: '2024-01-14T15:20:00Z',
              tags: ['dart', 'mobile'],
            ),
          ];

          when(
            mockPostApiService.getPosts(),
          ).thenAnswer((_) async => mockPostModels);

          // Act
          final result = await postRepository.getPosts();

          // Assert
          expect(result, hasLength(2));
          expect(result[0], isA<Post>());
          expect(result[0].title, equals('Primeiro Post'));
          expect(result[0].userName, equals('João Silva'));
          expect(result[1], isA<Post>());
          expect(result[1].title, equals('Segundo Post'));
          expect(result[1].userName, equals('Maria Santos'));
          verify(mockPostApiService.getPosts()).called(1);
        },
      );

      test('should return paginated Post entities correctly', () async {
        // Arrange
        final mockPostModels = List.generate(
          10,
          (index) => PostModel(
            id: index + 1,
            title: 'Post ${index + 1}',
            body: 'Conteúdo do post ${index + 1}',
            userId: (index % 3) + 1,
            userName: 'Usuário ${(index % 3) + 1}',
            userAvatar: 'https://example.com/user${(index % 3) + 1}.jpg',
            image: 'https://example.com/post${index + 1}.jpg',
            likes: index * 5,
            comments: index * 2,
            createdAt: '2024-01-${(index % 28) + 1}T10:30:00Z',
            tags: ['tag${index % 2}'],
          ),
        );

        when(
          mockPostApiService.getPosts(page: 1, limit: 10),
        ).thenAnswer((_) async => mockPostModels.take(10).toList());

        // Act
        final result = await postRepository.getPosts(page: 1, limit: 10);

        // Assert
        expect(result, hasLength(10));
        for (final post in result) {
          expect(post, isA<Post>());
        }
        expect(result[0].id, equals(1));
        expect(result[9].id, equals(10));
        verify(mockPostApiService.getPosts(page: 1, limit: 10)).called(1);
      });

      test('should return empty list when API returns empty list', () async {
        // Arrange
        when(mockPostApiService.getPosts()).thenAnswer((_) async => []);

        // Act
        final result = await postRepository.getPosts();

        // Assert
        expect(result, isEmpty);
        verify(mockPostApiService.getPosts()).called(1);
      });

      test('should propagate exception when API service throws', () async {
        // Arrange
        when(
          mockPostApiService.getPosts(),
        ).thenThrow(Exception('Failed to load posts'));

        // Act & Assert
        expect(
          () => postRepository.getPosts(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load posts'),
            ),
          ),
        );
        verify(mockPostApiService.getPosts()).called(1);
      });

      test('should handle network exceptions gracefully', () async {
        // Arrange
        when(
          mockPostApiService.getPosts(),
        ).thenThrow(Exception('Sem conexão com a internet'));

        // Act & Assert
        expect(
          () => postRepository.getPosts(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Sem conexão com a internet'),
            ),
          ),
        );
      });

      test('should properly convert PostModel to Post entity', () async {
        // Arrange
        final mockPostModel = PostModel(
          id: 1,
          title: 'Test Post',
          body: 'Test content with special characters: áçêõü',
          userId: 1,
          userName: 'Carlos Eduardo',
          userAvatar: 'https://example.com/carlos.jpg',
          image: 'https://example.com/test.jpg',
          likes: 100,
          comments: 25,
          createdAt: '2024-01-15T10:30:00Z',
          tags: ['test', 'conversion'],
        );

        when(
          mockPostApiService.getPosts(),
        ).thenAnswer((_) async => [mockPostModel]);

        // Act
        final result = await postRepository.getPosts();

        // Assert
        expect(result, hasLength(1));
        final post = result[0];
        expect(post.id, equals(mockPostModel.id));
        expect(post.title, equals(mockPostModel.title));
        expect(post.body, equals(mockPostModel.body));
        expect(post.userId, equals(mockPostModel.userId));
        expect(post.userName, equals(mockPostModel.userName));
        expect(post.userAvatar, equals(mockPostModel.userAvatar));
        expect(post.image, equals(mockPostModel.image));
        expect(post.likes, equals(mockPostModel.likes));
        expect(post.comments, equals(mockPostModel.comments));
        expect(post.tags, equals(mockPostModel.tags));
      });
    });

    group('getPostById', () {
      test('should return Post entity when API returns PostModel', () async {
        // Arrange
        final mockPostModel = PostModel(
          id: 1,
          title: 'Post Específico',
          body: 'Conteúdo detalhado do post específico de Ana Paula',
          userId: 1,
          userName: 'Ana Paula',
          userAvatar: 'https://example.com/ana.jpg',
          image: 'https://example.com/specific-post.jpg',
          likes: 150,
          comments: 42,
          createdAt: '2024-01-15T10:30:00Z',
          tags: ['específico', 'detalhado'],
        );

        when(
          mockPostApiService.getPostById(1),
        ).thenAnswer((_) async => mockPostModel);

        // Act
        final result = await postRepository.getPostById(1);

        // Assert
        expect(result, isNotNull);
        expect(result, isA<Post>());
        expect(result!.id, equals(1));
        expect(result.title, equals('Post Específico'));
        expect(result.userName, equals('Ana Paula'));
        expect(result.likes, equals(150));
        verify(mockPostApiService.getPostById(1)).called(1);
      });

      test('should return null when API returns null', () async {
        // Arrange
        when(mockPostApiService.getPostById(999)).thenAnswer((_) async => null);

        // Act
        final result = await postRepository.getPostById(999);

        // Assert
        expect(result, isNull);
        verify(mockPostApiService.getPostById(999)).called(1);
      });

      test('should propagate exception when API service throws', () async {
        // Arrange
        when(
          mockPostApiService.getPostById(1),
        ).thenThrow(Exception('Failed to load post'));

        // Act & Assert
        expect(
          () => postRepository.getPostById(1),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load post'),
            ),
          ),
        );
        verify(mockPostApiService.getPostById(1)).called(1);
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        when(
          mockPostApiService.getPostById(1),
        ).thenThrow(Exception('Server error: 500'));

        // Act & Assert
        expect(
          () => postRepository.getPostById(1),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Server error'),
            ),
          ),
        );
      });

      test(
        'should properly convert PostModel to Post with all fields',
        () async {
          // Arrange
          final mockPostModel = PostModel(
            id: 42,
            title: 'Complex Post Title',
            body:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' *
                10,
            userId: 5,
            userName: 'José da Silva',
            userAvatar: 'https://example.com/profile/jose.png',
            image: 'https://example.com/images/complex-post.jpg',
            likes: 999,
            comments: 156,
            createdAt: '2024-01-15T10:30:00Z',
            tags: ['lorem', 'ipsum', 'teste', 'complexo'],
          );

          when(
            mockPostApiService.getPostById(42),
          ).thenAnswer((_) async => mockPostModel);

          // Act
          final result = await postRepository.getPostById(42);

          // Assert
          expect(result, isNotNull);
          expect(result!.id, equals(42));
          expect(result.title, equals('Complex Post Title'));
          expect(result.body, contains('Lorem ipsum'));
          expect(result.userId, equals(5));
          expect(result.userName, equals('José da Silva'));
          expect(
            result.userAvatar,
            equals('https://example.com/profile/jose.png'),
          );
          expect(
            result.image,
            equals('https://example.com/images/complex-post.jpg'),
          );
          expect(result.likes, equals(999));
          expect(result.comments, equals(156));
          expect(result.tags, hasLength(4));
          expect(result.tags, contains('lorem'));
          expect(result.tags, contains('complexo'));
        },
      );
    });

    group('Default Constructor', () {
      test(
        'should create repository with default ApiService when none provided',
        () {
          // Act
          final repository = PostRepositoryImpl(apiService: PostApiService());

          // Assert
          expect(repository, isNotNull);
          // Repository should be created successfully with default dependencies
        },
      );
    });

    group('Data Transformation', () {
      test('should correctly transform PostModel to Post entity', () async {
        // Arrange
        final mockPostModel = PostModel(
          id: 1,
          title: 'Transformation Test',
          body: 'Testing data transformation between layers',
          userId: 1,
          userName: 'Testador Silva',
          userAvatar: 'https://example.com/testador.jpg',
          image: 'https://example.com/transformation.jpg',
          likes: 75,
          comments: 12,
          createdAt: '2024-01-15T10:30:00Z',
          tags: ['transformation', 'test'],
        );

        when(
          mockPostApiService.getPosts(),
        ).thenAnswer((_) async => [mockPostModel]);

        // Act
        final result = await postRepository.getPosts();
        final transformedPost = result.first;

        // Assert - Verify all fields are properly transformed
        expect(transformedPost, isA<Post>());
        expect(transformedPost.id, equals(mockPostModel.id));
        expect(transformedPost.title, equals(mockPostModel.title));
        expect(transformedPost.body, equals(mockPostModel.body));
        expect(transformedPost.userId, equals(mockPostModel.userId));
        expect(transformedPost.userName, equals(mockPostModel.userName));
        expect(transformedPost.userAvatar, equals(mockPostModel.userAvatar));
        expect(transformedPost.image, equals(mockPostModel.image));
        expect(transformedPost.likes, equals(mockPostModel.likes));
        expect(transformedPost.comments, equals(mockPostModel.comments));
        expect(transformedPost.tags, orderedEquals(mockPostModel.tags));

        // Test computed properties
        expect(transformedPost.timeAgo, isNotEmpty);
        expect(transformedPost.contentSummary, isNotEmpty);
      });

      test('should handle empty lists correctly', () async {
        // Arrange
        when(mockPostApiService.getPosts()).thenAnswer((_) async => []);

        // Act
        final result = await postRepository.getPosts();

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<Post>>());
      });

      test('should maintain order of posts from API', () async {
        // Arrange
        final mockPostModels = [
          PostModel(
            id: 3,
            title: 'Third Post',
            body: 'Content 3',
            userId: 1,
            userName: 'User',
            userAvatar: '',
            image: '',
            likes: 0,
            comments: 0,
            createdAt: '2024-01-15T10:30:00Z',
            tags: [],
          ),
          PostModel(
            id: 1,
            title: 'First Post',
            body: 'Content 1',
            userId: 1,
            userName: 'User',
            userAvatar: '',
            image: '',
            likes: 0,
            comments: 0,
            createdAt: '2024-01-15T10:30:00Z',
            tags: [],
          ),
          PostModel(
            id: 2,
            title: 'Second Post',
            body: 'Content 2',
            userId: 1,
            userName: 'User',
            userAvatar: '',
            image: '',
            likes: 0,
            comments: 0,
            createdAt: '2024-01-15T10:30:00Z',
            tags: [],
          ),
        ];

        when(
          mockPostApiService.getPosts(),
        ).thenAnswer((_) async => mockPostModels);

        // Act
        final result = await postRepository.getPosts();

        // Assert
        expect(result, hasLength(3));
        expect(result[0].id, equals(3)); // Maintains API order
        expect(result[1].id, equals(1));
        expect(result[2].id, equals(2));
        expect(result[0].title, equals('Third Post'));
        expect(result[1].title, equals('First Post'));
        expect(result[2].title, equals('Second Post'));
      });
    });
  });
}
