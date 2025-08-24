import 'package:app_test/src/features/posts/data/domain/entities/post.dart';
import 'package:app_test/src/features/posts/presentation/widgets/post_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostItem Widget Tests - Funcionais', () {
    late Post mockPost;
    late VoidCallback mockOnTap;

    setUp(() {
      mockPost = const Post(
        id: 1,
        title: 'Título do Post',
        body: 'Este é um conteúdo de teste para o post',
        userId: 1,
        userName: 'João Silva',
        userAvatar: '', // Sem avatar para evitar problemas de imagem
        image: '', // Sem imagem para evitar problemas de carregamento
        likes: 25,
        comments: 10,
        createdAt: '2024-01-15T10:30:00Z',
        tags: ['flutter', 'teste'],
      );

      mockOnTap = () {};
    });

    Widget createTestWidget(Post post) {
      return MaterialApp(
        home: Scaffold(
          body: PostItem(post: post, onTap: mockOnTap),
        ),
      );
    }

    testWidgets('should render basic post elements without images', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(mockPost));

      // Verifica se o título está presente
      expect(find.text('Título do Post'), findsOneWidget);

      // Verifica se o nome do usuário está presente
      expect(find.text('João Silva'), findsOneWidget);

      // Verifica se o conteúdo está presente
      expect(
        find.text('Este é um conteúdo de teste para o post'),
        findsOneWidget,
      );

      // Verifica se os likes estão presentes
      expect(find.text('25'), findsOneWidget);

      // Verifica se os comentários estão presentes
      expect(find.text('10'), findsOneWidget);

      // Verifica se as tags estão presentes
      expect(find.text('#flutter'), findsOneWidget);
      expect(find.text('#teste'), findsOneWidget);

      // Verifica se os botões de ação estão presentes
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);

      // Verifica se o ícone padrão do avatar está presente
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should show truncated content for long text', (
      WidgetTester tester,
    ) async {
      final postLongo = Post(
        id: 1,
        title: 'Título',
        body:
            'Este é um conteúdo muito longo que deveria ser truncado porque excede o limite de cem caracteres permitidos para exibição no resumo do post. Este texto é longo o suficiente para ser truncado e deve mostrar reticências no final.',
        userId: 1,
        userName: 'User',
        userAvatar: '',
        image: '',
        likes: 0,
        comments: 0,
        createdAt: '2024-01-15T10:30:00Z',
        tags: [],
      );

      await tester.pumpWidget(createTestWidget(postLongo));

      // Verifica se o conteúdo foi truncado (deve ter ... no final do resumo)
      final contentSummary = postLongo.contentSummary;
      expect(contentSummary.endsWith('...'), isTrue);

      // Verifica se existe algum RichText ou Text.rich (usado para "Ver mais")
      expect(find.byType(RichText), findsAtLeast(1));
    });

    testWidgets('should not show See more for short content', (
      WidgetTester tester,
    ) async {
      final postCurto = mockPost.copyWith(body: 'Conteúdo curto');

      await tester.pumpWidget(createTestWidget(postCurto));

      // Verifica se "Ver mais" não está presente
      expect(find.text(' Ver mais'), findsNothing);
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

      // Toca no Card do post
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(tapCalled, isTrue);
    });

    testWidgets('should show correct basic structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(mockPost));

      // Verifica se é um Card
      expect(find.byType(Card), findsOneWidget);

      // Verifica se tem CircleAvatar para o usuário
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Verifica se tem Column principal
      expect(find.byType(Column), findsAtLeast(1));

      // Verifica se tem os ícones de ação
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should not show tags when list is empty', (
      WidgetTester tester,
    ) async {
      final postSemTags = mockPost.copyWith(tags: []);

      await tester.pumpWidget(createTestWidget(postSemTags));

      // Verifica se não há texto com # (tags)
      expect(find.textContaining('#'), findsNothing);
    });

    testWidgets('should show correct values for likes and comments', (
      WidgetTester tester,
    ) async {
      final postPersonalizado = mockPost.copyWith(likes: 42, comments: 7);

      await tester.pumpWidget(createTestWidget(postPersonalizado));

      expect(find.text('42'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('should render with minimal data', (WidgetTester tester) async {
      const postMinimo = Post(
        id: 1,
        title: 'T',
        body: 'C',
        userId: 1,
        userName: 'U',
        userAvatar: '',
        image: '',
        likes: 0,
        comments: 0,
        createdAt: '2024-01-15T10:30:00Z',
        tags: [],
      );

      await tester.pumpWidget(createTestWidget(postMinimo));

      expect(find.text('T'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('0'), findsAtLeast(2)); // likes e comments
    });

    testWidgets('should display formatted timeAgo', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(mockPost));

      // Procura por padrões de tempo (números seguidos de letras como 1d, 2h, etc)
      final timePattern = RegExp(r'\d+[dhms]|agora|sem');

      // Busca todos os widgets de texto
      final textWidgets = find.byType(Text);
      final List<Widget> foundTexts = tester.widgetList(textWidgets).toList();

      // Verifica se algum texto contém padrão de tempo
      bool foundTimePattern = false;
      for (Widget widget in foundTexts) {
        if (widget is Text && widget.data != null) {
          if (timePattern.hasMatch(widget.data!)) {
            foundTimePattern = true;
            break;
          }
        }
      }

      expect(
        foundTimePattern,
        isTrue,
        reason: 'Deveria encontrar padrão de tempo no texto',
      );
    });
  });
}

// Extensão para facilitar testes
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
