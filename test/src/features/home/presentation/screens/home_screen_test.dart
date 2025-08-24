import 'package:app_test/src/core/routes/app_routes.dart';
import 'package:app_test/src/features/auth/data/domain/entities/user.dart';
import 'package:app_test/src/features/auth/data/domain/repositories/auth_repository.dart';
import 'package:app_test/src/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:app_test/src/features/auth/presentation/bloc/auth_state.dart';
import 'package:app_test/src/features/home/presentation/screens/home_screen.dart';
import 'package:app_test/src/features/posts/data/domain/entities/post.dart';
import 'package:app_test/src/features/posts/data/domain/repositories/post_repository.dart';
import 'package:app_test/src/features/posts/presentation/bloc/post_cubit.dart';
import 'package:app_test/src/features/posts/presentation/bloc/post_state.dart';
import 'package:app_test/src/features/posts/presentation/widgets/post_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([PostRepository, AuthRepository])
void main() {
  group('HomeScreen Widget Tests', () {
    late MockPostRepository mockPostRepository;
    late MockAuthRepository mockAuthRepository;
    late PostCubit postCubit;
    late AuthCubit authCubit;
    late List<Post> mockPosts;
    late User mockUser;

    setUp(() {
      mockPostRepository = MockPostRepository();
      mockAuthRepository = MockAuthRepository();
      postCubit = PostCubit(postRepository: mockPostRepository);
      authCubit = AuthCubit(authRepository: mockAuthRepository);

      mockUser = const User(
        uid: 'user123',
        email: 'test@example.com',
        displayName: 'João Silva',
        photoURL: 'https://example.com/avatar.jpg',
      );

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
      authCubit.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PostCubit>.value(value: postCubit),
            BlocProvider<AuthCubit>.value(value: authCubit),
          ],
          child: const HomeScreen(),
        ),
        routes: {
          AppRoutes.login: (context) => const Scaffold(body: Text('Login')),
          AppRoutes.profile: (context) => const Scaffold(body: Text('Profile')),
          AppRoutes.postDetail: (context) =>
              const Scaffold(body: Text('Post Detail')),
        },
      );
    }

    group('Layout e Estados', () {
      testWidgets('should show loading indicator when posts are being loaded', (
        WidgetTester tester,
      ) async {
        // Configura o estado de autenticação
        when(
          mockAuthRepository.getCurrentUser(),
        ).thenAnswer((_) async => mockUser);

        // Configura o mock para demorar para responder
        when(mockPostRepository.getPosts(page: 1, limit: 10)).thenAnswer(
          (_) async => await Future.delayed(
            const Duration(seconds: 1),
            () => mockPosts.take(10).toList(),
          ),
        );

        await tester.pumpWidget(createTestWidget());

        // Emite estado autenticado
        authCubit.emit(AuthAuthenticated(user: mockUser));
        await tester.pump();

        // Verifica se o indicador de carregamento está presente
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Verifica se o AppBar está presente
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should show list of posts when loaded successfully', (
        WidgetTester tester,
      ) async {
        // Configura os mocks
        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenAnswer((_) async => mockPosts.take(10).toList());

        await tester.pumpWidget(createTestWidget());

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: mockUser));
        postCubit.emit(PostLoaded(posts: mockPosts.take(10).toList()));
        await tester.pump();

        // Verifica se os posts estão sendo exibidos
        expect(find.byType(PostItem), findsAtLeast(1));
        expect(find.text('Post 1'), findsOneWidget);
        expect(find.text('Post 2'), findsOneWidget);

        // Verifica se o RefreshIndicator está presente
        expect(find.byType(RefreshIndicator), findsOneWidget);

        // Verifica se o ListView está presente
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should show error message when fails to load posts', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: mockUser));
        postCubit.emit(const PostError(message: 'Erro ao carregar posts'));
        await tester.pump();

        // Verifica se a mensagem de erro está presente
        expect(find.text('Erro ao carregar posts'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Tentar novamente'), findsOneWidget);
      });

      testWidgets('should redirect to login when user is not authenticated', (
        WidgetTester tester,
      ) async {
        bool loginCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<PostCubit>.value(value: postCubit),
                BlocProvider<AuthCubit>.value(value: authCubit),
              ],
              child: const HomeScreen(),
            ),
            routes: {
              AppRoutes.login: (context) {
                loginCalled = true;
                return const Scaffold(body: Text('Login'));
              },
            },
          ),
        );

        // Emite estado não autenticado
        authCubit.emit(AuthUnauthenticated());
        await tester.pumpAndSettle();

        expect(loginCalled, isTrue);
      });
    });

    group('AppBar e Navegação', () {
      testWidgets('should show user information in AppBar', (
        WidgetTester tester,
      ) async {
        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenAnswer((_) async => mockPosts.take(10).toList());

        await tester.pumpWidget(createTestWidget());

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: mockUser));
        postCubit.emit(PostLoaded(posts: mockPosts.take(10).toList()));
        await tester.pump();

        // Verifica se o nome do usuário está presente
        expect(find.text('João Silva'), findsOneWidget);

        // Verifica se o avatar está presente
        expect(find.byType(CircleAvatar), findsAtLeast(1));

        // Verifica se o botão de logout está presente
        expect(find.byIcon(Icons.logout), findsOneWidget);
      });

      testWidgets('should show part of email when there is no displayName', (
        WidgetTester tester,
      ) async {
        final userSemNome = mockUser.copyWith(displayName: '');

        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenAnswer((_) async => mockPosts.take(10).toList());

        await tester.pumpWidget(createTestWidget());

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: userSemNome));
        postCubit.emit(PostLoaded(posts: mockPosts.take(10).toList()));
        await tester.pump();

        // Verifica se mostra a parte do email antes do @
        expect(find.text('test'), findsOneWidget);
      });

      testWidgets('should navigate to profile when avatar is tapped', (
        WidgetTester tester,
      ) async {
        bool profileCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<PostCubit>.value(value: postCubit),
                BlocProvider<AuthCubit>.value(value: authCubit),
              ],
              child: const HomeScreen(),
            ),
            routes: {
              AppRoutes.profile: (context) {
                profileCalled = true;
                return const Scaffold(body: Text('Profile'));
              },
            },
          ),
        );

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: mockUser));
        postCubit.emit(PostLoaded(posts: mockPosts.take(10).toList()));
        await tester.pump();

        // Toca no avatar
        await tester.tap(find.byType(CircleAvatar).first);
        await tester.pumpAndSettle();

        expect(profileCalled, isTrue);
      });

      testWidgets('should show logout dialog when logout button is tapped', (
        WidgetTester tester,
      ) async {
        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenAnswer((_) async => mockPosts.take(10).toList());

        await tester.pumpWidget(createTestWidget());

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: mockUser));
        postCubit.emit(PostLoaded(posts: mockPosts.take(10).toList()));
        await tester.pump();

        // Toca no botão de logout
        await tester.tap(find.byIcon(Icons.logout));
        await tester.pump();

        // Verifica se o dialog está presente
        expect(find.text('Logout'), findsOneWidget);
        expect(find.text('Deseja realmente sair?'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Sair'), findsOneWidget);
      });
    });

    group('Interações com Posts', () {
      testWidgets('should navigate to post details when post is tapped', (
        WidgetTester tester,
      ) async {
        bool postDetailCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<PostCubit>.value(value: postCubit),
                BlocProvider<AuthCubit>.value(value: authCubit),
              ],
              child: const HomeScreen(),
            ),
            routes: {
              AppRoutes.postDetail: (context) {
                postDetailCalled = true;
                return const Scaffold(body: Text('Post Detail'));
              },
            },
          ),
        );

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: mockUser));
        postCubit.emit(PostLoaded(posts: mockPosts.take(10).toList()));
        await tester.pump();

        // Toca no primeiro post
        await tester.tap(find.byType(PostItem).first);
        await tester.pumpAndSettle();

        expect(postDetailCalled, isTrue);
      });

      testWidgets('should reload posts with pull-to-refresh', (
        WidgetTester tester,
      ) async {
        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenAnswer((_) async => mockPosts.take(10).toList());

        await tester.pumpWidget(createTestWidget());

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: mockUser));
        postCubit.emit(PostLoaded(posts: mockPosts.take(10).toList()));
        await tester.pump();

        // Simula pull-to-refresh
        await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
        await tester.pump();

        // Verifica se o refresh foi acionado
        verify(mockPostRepository.getPosts(page: 1, limit: 10)).called(1);
      });

      testWidgets(
        'should try to load again when "Try again" button is pressed',
        (WidgetTester tester) async {
          await tester.pumpWidget(createTestWidget());

          // Emite estados
          authCubit.emit(AuthAuthenticated(user: mockUser));
          postCubit.emit(const PostError(message: 'Erro ao carregar posts'));
          await tester.pump();

          // Configura mock para sucesso na segunda tentativa
          when(
            mockPostRepository.getPosts(page: 1, limit: 10),
          ).thenAnswer((_) async => mockPosts.take(10).toList());

          // Toca no botão "Tentar novamente"
          await tester.tap(find.text('Tentar novamente'));
          await tester.pump();

          // Verifica se tentou carregar novamente
          verify(mockPostRepository.getPosts(page: 1, limit: 10)).called(1);
        },
      );
    });

    group('Carregamento de Mais Posts', () {
      testWidgets('should show loading indicator for more posts', (
        WidgetTester tester,
      ) async {
        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenAnswer((_) async => mockPosts.take(10).toList());

        await tester.pumpWidget(createTestWidget());

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: mockUser));
        postCubit.emit(
          PostLoaded(
            posts: mockPosts.take(10).toList(),
            hasReachedMax: false,
            currentPage: 1,
          ),
        );
        await tester.pump();

        // Verifica se há indicador para carregar mais posts no final da lista
        expect(find.byType(ListView), findsOneWidget);

        // Scroll até o final da lista
        await tester.scrollUntilVisible(
          find.text('Carregando...'),
          500.0,
          scrollable: find.byType(Scrollable),
        );

        expect(find.text('Carregando...'), findsOneWidget);
      });

      testWidgets('should not show indicator when reached maximum', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        // Emite estados com hasReachedMax = true
        authCubit.emit(AuthAuthenticated(user: mockUser));
        postCubit.emit(
          PostLoaded(
            posts: mockPosts.take(10).toList(),
            hasReachedMax: true,
            currentPage: 1,
          ),
        );
        await tester.pump();

        // Verifica se não há indicador de carregamento no final
        expect(find.text('Carregando...'), findsNothing);
      });
    });

    group('Estados Diversos', () {
      testWidgets('should show loading indicator in initial state', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createTestWidget());

        // Emite apenas estado autenticado, sem posts
        authCubit.emit(AuthAuthenticated(user: mockUser));
        await tester.pump();

        // Verifica se mostra carregamento para estado inicial
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should handle user without photo', (
        WidgetTester tester,
      ) async {
        final userSemFoto = mockUser.copyWith(photoURL: null);

        when(
          mockPostRepository.getPosts(page: 1, limit: 10),
        ).thenAnswer((_) async => mockPosts.take(10).toList());

        await tester.pumpWidget(createTestWidget());

        // Emite estados
        authCubit.emit(AuthAuthenticated(user: userSemFoto));
        postCubit.emit(PostLoaded(posts: mockPosts.take(10).toList()));
        await tester.pump();

        // Verifica se mostra ícone padrão
        expect(find.byIcon(Icons.person), findsOneWidget);
      });
    });
  });
}

// Extensão para facilitar testes com User
extension UserTestHelper on User {
  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
    );
  }
}
