import 'package:app_test/src/core/routes/app_routes.dart';
import 'package:app_test/src/features/posts/data/domain/entities/post.dart';
import 'package:app_test/src/features/posts/presentation/widgets/post_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostItem Widget Tests', () {
    late Post mockPost;
    late VoidCallback mockOnTap;

    setUp(() {
      mockPost = const Post(
        id: 1,
        title: 'Título do Post',
        body:
            'Este é o conteúdo do post. Este é um exemplo de conteúdo que pode ser muito longo e precisa ser truncado quando excede o limite de caracteres para o resumo.',
        userId: 1,
        userName: 'João Silva',
        userAvatar: '',
        image: '',
        likes: 25,
        comments: 10,
        createdAt: '2024-01-15T10:30:00Z',
        tags: ['flutter', 'desenvolvimento', 'mobile'],
      );

      mockOnTap = () {};
    });

    Widget createTestWidget(Post post) {
      return MaterialApp(
        home: Scaffold(
          body: PostItem(post: post, onTap: mockOnTap),
        ),
        routes: {
          AppRoutes.profile: (context) => const Scaffold(body: Text('Profile')),
        },
      );
    }

    testWidgets('should render all basic post elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(mockPost));

      // Verifica se o título está presente
      expect(find.text('Título do Post'), findsOneWidget);

      // Verifica se o nome do usuário está presente
      expect(find.text('João Silva'), findsOneWidget);

      // Verifica se o resumo do conteúdo está presente
      expect(find.textContaining('Este é o conteúdo do post'), findsOneWidget);

      // Verifica se os likes estão presentes
      expect(find.text('25'), findsOneWidget);

      // Verifica se os comentários estão presentes
      expect(find.text('10'), findsOneWidget);

      // Verifica se as tags estão presentes
      expect(find.text('#flutter'), findsOneWidget);
      expect(find.text('#desenvolvimento'), findsOneWidget);
      expect(find.text('#mobile'), findsOneWidget);

      // Verifica se o avatar do usuário está presente (ícone padrão)
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Verifica se os botões de ação estão presentes
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('should show "Ver mais" when content is truncated', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(mockPost));

      // Verifica se "Ver mais" está presente para conteúdo truncado
      expect(find.textContaining('Ver mais'), findsOneWidget);
    });

    testWidgets('should not show "Ver mais" when content is not truncated', (
      WidgetTester tester,
    ) async {
      final shortPost = mockPost.copyWith(body: 'Conteúdo curto');

      await tester.pumpWidget(createTestWidget(shortPost));

      // Verifica se "Ver mais" não está presente para conteúdo curto
      expect(find.textContaining('Ver mais'), findsNothing);
    });

    testWidgets('should show default icon when there is no avatar', (
      WidgetTester tester,
    ) async {
      final postSemAvatar = mockPost.copyWith(userAvatar: '');

      await tester.pumpWidget(createTestWidget(postSemAvatar));

      // Verifica se o ícone padrão está presente
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should not show image when image is empty', (
      WidgetTester tester,
    ) async {
      final postSemImagem = mockPost.copyWith(image: '');

      await tester.pumpWidget(createTestWidget(postSemImagem));

      // Como não há imagem do post e nem avatar, apenas o ícone padrão deve estar presente
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should not show tags when list is empty', (
      WidgetTester tester,
    ) async {
      final postSemTags = mockPost.copyWith(tags: []);

      await tester.pumpWidget(createTestWidget(postSemTags));

      // Verifica se nenhuma tag está presente
      expect(find.textContaining('#'), findsNothing);
    });

    testWidgets('should show maximum 3 tags', (WidgetTester tester) async {
      final postComMuitasTags = mockPost.copyWith(
        tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5'],
      );

      await tester.pumpWidget(createTestWidget(postComMuitasTags));

      // Verifica se apenas 3 tags estão visíveis
      expect(find.text('#tag1'), findsOneWidget);
      expect(find.text('#tag2'), findsOneWidget);
      expect(find.text('#tag3'), findsOneWidget);
      expect(find.text('#tag4'), findsNothing);
      expect(find.text('#tag5'), findsNothing);
    });

    testWidgets('should call onTap when post is tapped', (
      WidgetTester tester,
    ) async {
      bool tapCalled = false;
      final testOnTap = () {
        tapCalled = true;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostItem(post: mockPost, onTap: testOnTap),
          ),
        ),
      );

      // Toca no post
      await tester.tap(find.byType(PostItem));
      await tester.pumpAndSettle();

      expect(tapCalled, isTrue);
    });

    testWidgets('should call onTap when "Ver mais" is tapped', (
      WidgetTester tester,
    ) async {
      bool tapCalled = false;
      final testOnTap = () {
        tapCalled = true;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostItem(post: mockPost, onTap: testOnTap),
          ),
        ),
      );

      // Toca em "Ver mais"
      await tester.tap(find.textContaining('Ver mais'));
      await tester.pumpAndSettle();

      expect(tapCalled, isTrue);
    });

    testWidgets('should call onTap when comment button is tapped', (
      WidgetTester tester,
    ) async {
      bool tapCalled = false;
      final testOnTap = () {
        tapCalled = true;
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostItem(post: mockPost, onTap: testOnTap),
          ),
        ),
      );

      // Toca no botão de comentários
      await tester.tap(find.byIcon(Icons.chat_bubble_outline));
      await tester.pumpAndSettle();

      expect(tapCalled, isTrue);
    });

    testWidgets('should display relative time correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(mockPost));

      // Verifica se algum indicador de tempo está presente
      // O texto exato depende de quando o teste é executado
      expect(
        find.textContaining(RegExp(r'\d+[smhd]|agora|sem')),
        findsOneWidget,
      );
    });

    testWidgets('should have correct widget structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(mockPost));

      // Verifica se o widget é um Card
      expect(find.byType(Card), findsOneWidget);

      // Verifica se tem InkWell para interação
      expect(find.byType(InkWell), findsAtLeast(1));

      // Verifica se tem os ícones de menu
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should render correctly with minimal data', (
      WidgetTester tester,
    ) async {
      final postMinimo = const Post(
        id: 1,
        title: 'Título',
        body: 'Conteúdo',
        userId: 1,
        userName: 'User',
        userAvatar: '',
        image: '',
        likes: 0,
        comments: 0,
        createdAt: '2024-01-15T10:30:00Z',
        tags: [],
      );

      await tester.pumpWidget(createTestWidget(postMinimo));

      // Verifica se os elementos essenciais estão presentes
      expect(find.text('Título'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Conteúdo'), findsOneWidget);
      expect(find.text('0'), findsAtLeast(2)); // likes e comments
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
