import 'package:app_test/src/features/posts/data/domain/entities/post.dart';
import 'package:app_test/src/features/posts/data/domain/repositories/post_repository.dart';
import 'package:app_test/src/features/posts/presentation/bloc/post_cubit.dart';
import 'package:app_test/src/features/posts/presentation/bloc/post_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';

import 'post_cubit_test.mocks.dart';

@GenerateMocks([PostRepository])
void main() {
  group('PostCubit Tests', () {
    late MockPostRepository mockPostRepository;
    late PostCubit postCubit;
    late List<Post> mockPosts;

    setUp(() {
      mockPostRepository = MockPostRepository();
      postCubit = PostCubit(postRepository: mockPostRepository);

      mockPosts = List.generate(
        15,
        (index) => Post(
          id: index + 1,
          title: 'Post ${index + 1}',
          body: 'Conteúdo do post ${index + 1}',
          userId: 1,
          userName: 'User ${index + 1}',
          userAvatar: 'https://example.com/avatar${index + 1}.jpg',
          image: 'https://example.com/image${index + 1}.jpg',
          likes: index * 5,
          comments: index * 2,
          createdAt: '2024-01-${(index % 28) + 1}T10:30:00Z',
          tags: ['tag${index % 3}'],
        ),
      );
    });

    tearDown(() {
      postCubit.close();
    });

    group('loadPosts', () {
      blocTest<PostCubit, PostState>(
        'should emit [PostLoading, PostLoaded] when posts are loaded successfully',
        build: () {
          when(
            mockPostRepository.getPosts(page: 1, limit: 10),
          ).thenAnswer((_) async => mockPosts.take(10).toList());
          return postCubit;
        },
        act: (cubit) => cubit.loadPosts(),
        expect: () => [
          PostLoading(),
          PostLoaded(
            posts: mockPosts.take(10).toList(),
            hasReachedMax: false,
            currentPage: 1,
          ),
        ],
      );

      blocTest<PostCubit, PostState>(
        'should emit [PostLoading, PostLoaded] with hasReachedMax=true when fewer posts than limit are returned',
        build: () {
          when(
            mockPostRepository.getPosts(page: 1, limit: 10),
          ).thenAnswer((_) async => mockPosts.take(5).toList());
          return postCubit;
        },
        act: (cubit) => cubit.loadPosts(),
        expect: () => [
          PostLoading(),
          PostLoaded(
            posts: mockPosts.take(5).toList(),
            hasReachedMax: true,
            currentPage: 1,
          ),
        ],
      );

      blocTest<PostCubit, PostState>(
        'should emit [PostLoading, PostError] when fails to load posts',
        build: () {
          when(
            mockPostRepository.getPosts(page: 1, limit: 10),
          ).thenThrow(Exception('Network error'));
          return postCubit;
        },
        act: (cubit) => cubit.loadPosts(),
        expect: () => [
          PostLoading(),
          const PostError(
            message:
                'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
          ),
        ],
      );

      blocTest<PostCubit, PostState>(
        'should emit only [PostLoaded] when forceReload=false and posts are already loaded',
        build: () {
          when(
            mockPostRepository.getPosts(page: 1, limit: 10),
          ).thenAnswer((_) async => mockPosts.take(10).toList());
          return postCubit;
        },
        seed: () => PostLoaded(
          posts: mockPosts.take(5).toList(),
          hasReachedMax: false,
          currentPage: 1,
        ),
        act: (cubit) => cubit.loadPosts(forceReload: false),
        expect: () => [
          PostLoaded(
            posts: mockPosts.take(10).toList(),
            hasReachedMax: false,
            currentPage: 1,
          ),
        ],
      );

      blocTest<PostCubit, PostState>(
        'should emit [PostLoading, PostLoaded] when forceReload=true even with loaded posts',
        build: () {
          when(
            mockPostRepository.getPosts(page: 1, limit: 10),
          ).thenAnswer((_) async => mockPosts.take(10).toList());
          return postCubit;
        },
        seed: () => PostLoaded(
          posts: mockPosts.take(5).toList(),
          hasReachedMax: false,
          currentPage: 1,
        ),
        act: (cubit) => cubit.loadPosts(forceReload: true),
        expect: () => [
          PostLoading(),
          PostLoaded(
            posts: mockPosts.take(10).toList(),
            hasReachedMax: false,
            currentPage: 1,
          ),
        ],
      );
    });

    group('loadMorePosts', () {
      blocTest<PostCubit, PostState>(
        'should load more posts when there are more pages available',
        build: () {
          // Primeira página
          when(
            mockPostRepository.getPosts(page: 1, limit: 10),
          ).thenAnswer((_) async => mockPosts.take(10).toList());
          // Segunda página
          when(
            mockPostRepository.getPosts(page: 2, limit: 10),
          ).thenAnswer((_) async => mockPosts.skip(10).take(5).toList());
          return postCubit;
        },
        seed: () => PostLoaded(
          posts: mockPosts.take(10).toList(),
          hasReachedMax: false,
          currentPage: 1,
          isLoadingMore: false,
        ),
        act: (cubit) => cubit.loadMorePosts(),
        expect: () => [
          PostLoaded(
            posts: mockPosts.take(10).toList(),
            hasReachedMax: false,
            currentPage: 1,
            isLoadingMore: true,
          ),
          PostLoaded(
            posts: mockPosts.take(15).toList(),
            hasReachedMax: true,
            currentPage: 2,
            isLoadingMore: false,
          ),
        ],
      );

      blocTest<PostCubit, PostState>(
        'should not load more posts when hasReachedMax=true',
        build: () => postCubit,
        seed: () => PostLoaded(
          posts: mockPosts.take(10).toList(),
          hasReachedMax: true,
          currentPage: 1,
          isLoadingMore: false,
        ),
        act: (cubit) => cubit.loadMorePosts(),
        expect: () => [],
      );

      blocTest<PostCubit, PostState>(
        'should not load more posts when already loading',
        build: () => postCubit,
        seed: () => PostLoaded(
          posts: mockPosts.take(10).toList(),
          hasReachedMax: false,
          currentPage: 1,
          isLoadingMore: true,
        ),
        act: (cubit) => cubit.loadMorePosts(),
        expect: () => [],
      );

      blocTest<PostCubit, PostState>(
        'should handle error when loading more posts keeping existing posts',
        build: () {
          when(
            mockPostRepository.getPosts(page: 2, limit: 10),
          ).thenThrow(Exception('Network error'));
          return postCubit;
        },
        seed: () => PostLoaded(
          posts: mockPosts.take(10).toList(),
          hasReachedMax: false,
          currentPage: 1,
          isLoadingMore: false,
        ),
        act: (cubit) => cubit.loadMorePosts(),
        expect: () => [
          PostLoaded(
            posts: mockPosts.take(10).toList(),
            hasReachedMax: false,
            currentPage: 1,
            isLoadingMore: true,
          ),
          PostLoaded(
            posts: mockPosts.take(10).toList(),
            hasReachedMax: false,
            currentPage: 1,
            isLoadingMore: false,
          ),
          const PostError(
            message:
                'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
          ),
        ],
      );
    });

    group('refreshPosts', () {
      blocTest<PostCubit, PostState>(
        'should reload posts with forceReload=true',
        build: () {
          when(
            mockPostRepository.getPosts(page: 1, limit: 10),
          ).thenAnswer((_) async => mockPosts.take(10).toList());
          return postCubit;
        },
        seed: () => PostLoaded(
          posts: mockPosts.take(5).toList(),
          hasReachedMax: false,
          currentPage: 1,
        ),
        act: (cubit) => cubit.refreshPosts(),
        expect: () => [
          PostLoading(),
          PostLoaded(
            posts: mockPosts.take(10).toList(),
            hasReachedMax: false,
            currentPage: 1,
          ),
        ],
      );
    });

    group('_getErrorMessage', () {
      test('should return connection message for network error', () {
        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenThrow(Exception('Network error'));

        expectLater(
          postCubit.stream,
          emitsInOrder([
            PostLoading(),
            const PostError(
              message:
                  'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
            ),
          ]),
        );

        postCubit.loadPosts();
      });

      test('should return server message for loading error', () {
        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenThrow(Exception('Failed to load'));

        expectLater(
          postCubit.stream,
          emitsInOrder([
            PostLoading(),
            const PostError(
              message:
                  'Erro ao carregar dados do servidor. Tente novamente mais tarde.',
            ),
          ]),
        );

        postCubit.loadPosts();
      });

      test('should return generic message for other errors', () {
        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenThrow(Exception('Something else'));

        expectLater(
          postCubit.stream,
          emitsInOrder([
            PostLoading(),
            const PostError(
              message: 'Erro ao carregar posts. Tente novamente.',
            ),
          ]),
        );

        postCubit.loadPosts();
      });
    });
  });

  group('PostDetailCubit Tests', () {
    late MockPostRepository mockPostRepository;
    late PostDetailCubit postDetailCubit;
    late Post mockPost;

    setUp(() {
      mockPostRepository = MockPostRepository();
      postDetailCubit = PostDetailCubit(postRepository: mockPostRepository);

      mockPost = const Post(
        id: 1,
        title: 'Post de Teste',
        body: 'Conteúdo do post de teste',
        userId: 1,
        userName: 'User Teste',
        userAvatar: 'https://example.com/avatar.jpg',
        image: 'https://example.com/image.jpg',
        likes: 10,
        comments: 5,
        createdAt: '2024-01-15T10:30:00Z',
        tags: ['teste'],
      );
    });

    tearDown(() {
      postDetailCubit.close();
    });

    group('loadPost', () {
      blocTest<PostDetailCubit, PostDetailState>(
        'should emit [PostDetailLoading, PostDetailLoaded] when post is loaded successfully',
        build: () {
          when(
            mockPostRepository.getPostById(1),
          ).thenAnswer((_) async => mockPost);
          return postDetailCubit;
        },
        act: (cubit) => cubit.loadPost(1),
        expect: () => [PostDetailLoading(), PostDetailLoaded(post: mockPost)],
      );

      blocTest<PostDetailCubit, PostDetailState>(
        'should emit [PostDetailLoading, PostDetailError] when post is not found',
        build: () {
          when(mockPostRepository.getPostById(1)).thenAnswer((_) async => null);
          return postDetailCubit;
        },
        act: (cubit) => cubit.loadPost(1),
        expect: () => [
          PostDetailLoading(),
          const PostDetailError(message: 'Post não encontrado'),
        ],
      );

      blocTest<PostDetailCubit, PostDetailState>(
        'should emit [PostDetailLoading, PostDetailError] when fails to load post',
        build: () {
          when(
            mockPostRepository.getPostById(1),
          ).thenThrow(Exception('Network error'));
          return postDetailCubit;
        },
        act: (cubit) => cubit.loadPost(1),
        expect: () => [
          PostDetailLoading(),
          const PostDetailError(
            message:
                'Sem conexão com a internet. Verifique sua conexão e tente novamente.',
          ),
        ],
      );
    });
  });
}
