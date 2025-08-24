import 'package:app_test/src/features/posts/data/domain/entities/post.dart';
import 'package:app_test/src/features/posts/data/domain/repositories/post_repository.dart';
import 'package:app_test/src/features/posts/presentation/bloc/post_cubit.dart';
import 'package:app_test/src/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'post_detail_screen_test.mocks.dart';

@GenerateMocks([PostRepository])
void main() {
  group('PostDetailScreen Widget Tests', () {
    late MockPostRepository mockPostRepository;
    late PostDetailCubit postDetailCubit;
    late Post mockPost;

    setUp(() {
      mockPostRepository = MockPostRepository();
      postDetailCubit = PostDetailCubit(postRepository: mockPostRepository);

      mockPost = const Post(
        id: 1,
        title: 'Título do Post Detalhado',
        body:
            'Este é o conteúdo completo do post. Aqui temos todas as informações detalhadas sobre o assunto discutido. É um texto mais longo que permite ver todo o conteúdo sem truncamento.',
        userId: 1,
        userName: 'João Silva',
        userAvatar: '',
        image: '',
        likes: 42,
        comments: 15,
        createdAt: '2024-01-15T10:30:00Z',
        tags: ['flutter', 'desenvolvimento', 'mobile', 'teste'],
      );
    });

    tearDown(() {
      postDetailCubit.close();
    });

    Widget createTestWidget(int postId) {
      return MaterialApp(
        home: BlocProvider<PostDetailCubit>.value(
          value: postDetailCubit,
          child: PostDetailScreen(postId: postId),
        ),
      );
    }

    testWidgets('should show loading indicator initially', (
      WidgetTester tester,
    ) async {
      // Configura o mock para retornar o post sem delay
      when(mockPostRepository.getPostById(1)).thenAnswer((_) async => mockPost);

      await tester.pumpWidget(createTestWidget(1));

      // Verifica se o indicador de carregamento está presente inicialmente
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verifica se o título da tela está presente
      expect(find.text('Detalhes do Post'), findsOneWidget);
    });

    testWidgets('should show all post details when loaded', (
      WidgetTester tester,
    ) async {
      // Configura o mock para retornar o post
      when(mockPostRepository.getPostById(1)).thenAnswer((_) async => mockPost);

      await tester.pumpWidget(createTestWidget(1));

      // Aguarda o carregamento
      await tester.pump();

      // Verifica se todos os elementos estão presentes
      expect(find.text('Título do Post Detalhado'), findsOneWidget);
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.textContaining('Este é o conteúdo completo'), findsOneWidget);

      // Verifica estatísticas
      expect(find.text('42'), findsOneWidget); // likes
      expect(find.text('15'), findsOneWidget); // comments
      expect(find.text('Likes'), findsOneWidget);
      expect(find.text('Comentários'), findsOneWidget);

      // Verifica tags
      expect(find.text('Tags'), findsOneWidget);
      expect(find.text('#flutter'), findsOneWidget);
      expect(find.text('#desenvolvimento'), findsOneWidget);
      expect(find.text('#mobile'), findsOneWidget);
      expect(find.text('#teste'), findsOneWidget);

      // Verifica se o avatar está presente (ícone padrão)
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Como não há imagem do post, não deve ter Image widgets
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should show error message when post is not found', (
      WidgetTester tester,
    ) async {
      // Configura o mock para retornar null
      when(mockPostRepository.getPostById(1)).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget(1));

      // Aguarda o carregamento
      await tester.pumpAndSettle();

      // Verifica se a mensagem de erro está presente
      expect(find.text('Post não encontrado'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('should show error message when there is loading failure', (
      WidgetTester tester,
    ) async {
      // Configura o mock para lançar uma exceção
      when(
        mockPostRepository.getPostById(1),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget(1));

      // Aguarda o carregamento
      await tester.pumpAndSettle();

      // Verifica se a mensagem de erro está presente
      expect(find.textContaining('Sem conexão com a internet'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('should try to load again when "Try again" button is pressed', (
      WidgetTester tester,
    ) async {
      // Configura o mock para falhar primeiro
      when(
        mockPostRepository.getPostById(1),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget(1));
      await tester.pumpAndSettle();

      // Verifica se a mensagem de erro está presente
      expect(find.text('Tentar novamente'), findsOneWidget);

      // Configura o mock para retornar sucesso na segunda tentativa
      when(mockPostRepository.getPostById(1)).thenAnswer((_) async => mockPost);

      // Toca no botão "Tentar novamente"
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      // Verifica se o post foi carregado
      expect(find.text('Título do Post Detalhado'), findsOneWidget);
    });

    testWidgets('should navigate back when back button is pressed', (
      WidgetTester tester,
    ) async {
      when(mockPostRepository.getPostById(1)).thenAnswer((_) async => mockPost);

      bool didPop = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider<PostDetailCubit>.value(
                        value: postDetailCubit,
                        child: const PostDetailScreen(postId: 1),
                      ),
                    ),
                  );
                  if (result == null) didPop = true;
                },
                child: const Text('Ir para detalhes'),
              ),
            ),
          ),
        ),
      );

      // Navega para a tela de detalhes
      await tester.tap(find.text('Ir para detalhes'));
      await tester.pumpAndSettle();

      // Verifica se está na tela de detalhes
      expect(find.text('Detalhes do Post'), findsOneWidget);

      // Toca no botão voltar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(didPop, isTrue);
    });

    testWidgets('should render correctly post without image', (
      WidgetTester tester,
    ) async {
      final postSemImagem = Post(
        id: 1,
        title: 'Post sem imagem',
        body: 'Este post não tem imagem',
        userId: 1,
        userName: 'User',
        userAvatar: '',
        image: '',
        likes: 0,
        comments: 0,
        createdAt: '2024-01-15T10:30:00Z',
        tags: [],
      );

      when(
        mockPostRepository.getPostById(1),
      ).thenAnswer((_) async => postSemImagem);

      await tester.pumpWidget(createTestWidget(1));
      await tester.pumpAndSettle();

      // Verifica se o post foi carregado sem problemas
      expect(find.text('Post sem imagem'), findsOneWidget);
      expect(find.text('Este post não tem imagem'), findsOneWidget);

      // Verifica se não há seção de Tags quando não há tags
      expect(find.text('Tags'), findsNothing);
    });

    testWidgets('should render correctly post without tags', (
      WidgetTester tester,
    ) async {
      final postSemTags = mockPost.copyWith(tags: []);

      when(
        mockPostRepository.getPostById(1),
      ).thenAnswer((_) async => postSemTags);

      await tester.pumpWidget(createTestWidget(1));
      await tester.pumpAndSettle();

      // Verifica se o post foi carregado
      expect(find.text('Título do Post Detalhado'), findsOneWidget);

      // Verifica se não há seção de Tags
      expect(find.text('Tags'), findsNothing);
    });

    testWidgets('should show default icon when there is no avatar', (
      WidgetTester tester,
    ) async {
      final postSemAvatar = mockPost.copyWith(userAvatar: '');

      when(
        mockPostRepository.getPostById(1),
      ).thenAnswer((_) async => postSemAvatar);

      await tester.pumpWidget(createTestWidget(1));
      await tester.pumpAndSettle();

      // Verifica se o ícone padrão está presente no avatar
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should display all tags when there are multiple tags', (
      WidgetTester tester,
    ) async {
      final postComMuitasTags = mockPost.copyWith(
        tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5', 'tag6'],
      );

      when(
        mockPostRepository.getPostById(1),
      ).thenAnswer((_) async => postComMuitasTags);

      await tester.pumpWidget(createTestWidget(1));
      await tester.pumpAndSettle();

      // Verifica se todas as tags estão presentes (diferente do PostItem que limita a 3)
      expect(find.text('#tag1'), findsOneWidget);
      expect(find.text('#tag2'), findsOneWidget);
      expect(find.text('#tag3'), findsOneWidget);
      expect(find.text('#tag4'), findsOneWidget);
      expect(find.text('#tag5'), findsOneWidget);
      expect(find.text('#tag6'), findsOneWidget);
    });

    testWidgets('should have correct layout structure', (
      WidgetTester tester,
    ) async {
      when(mockPostRepository.getPostById(1)).thenAnswer((_) async => mockPost);

      await tester.pumpWidget(createTestWidget(1));
      await tester.pumpAndSettle();

      // Verifica se tem Scaffold
      expect(find.byType(Scaffold), findsOneWidget);

      // Verifica se tem AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Verifica se tem SingleChildScrollView para scroll
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verifica se tem Card para estatísticas
      expect(find.byType(Card), findsOneWidget);
    });
  });
}

// Extensão para facilitar testes com Post
extension PostTestHelper on Post {
  Post copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
    String? userName,
    String? userAvatar,
    String? image,
    int? likes,
    int? comments,
    String? createdAt,
    List<String>? tags,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      image: image ?? this.image,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }
}
