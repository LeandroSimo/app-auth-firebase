import 'package:app_test/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post_cubit.dart';
import '../bloc/post_state.dart';

class PostDetailScreen extends StatefulWidget {
  static const String routeName = '/post-detail';
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega o post quando a tela é inicializada
    context.read<PostDetailCubit>().loadPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Post'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<PostDetailCubit, PostDetailState>(
        builder: (context, state) {
          if (state is PostDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostDetailLoaded) {
            final post = state.post;
            return SingleChildScrollView(
              padding: EdgeInsets.all(context.mediaQuery.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com informações do usuário
                  Row(
                    children: [
                      // Avatar do usuário
                      CircleAvatar(
                        radius: context.mediaQuery.width * 0.06,
                        backgroundImage: post.userAvatar.isNotEmpty
                            ? NetworkImage(post.userAvatar)
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: post.userAvatar.isEmpty
                            ? Icon(Icons.person, color: Colors.grey[600])
                            : null,
                      ),
                      SizedBox(width: context.mediaQuery.width * 0.03),
                      // Nome e tempo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.userName,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              post.timeAgo,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: context.mediaQuery.height * 0.025),

                  // Título
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.mediaQuery.height * 0.02),

                  // Conteúdo completo
                  Text(
                    post.body,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                  SizedBox(height: context.mediaQuery.height * 0.025),

                  // Imagem do post
                  if (post.image.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: context.mediaQuery.height * 0.35,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          context.mediaQuery.width * 0.03,
                        ),
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          context.mediaQuery.width * 0.03,
                        ),
                        child: Image.network(
                          post.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: context.mediaQuery.height * 0.25,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              height: context.mediaQuery.height * 0.25,
                              child: const Center(
                                child: Icon(Icons.error, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.025),
                  ],

                  // Tags
                  if (post.tags.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.01),
                    Wrap(
                      spacing: context.mediaQuery.width * 0.02,
                      runSpacing: context.mediaQuery.width * 0.02,
                      children: post.tags.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.mediaQuery.width * 0.03,
                            vertical: context.mediaQuery.height * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              context.mediaQuery.width * 0.04,
                            ),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.025),
                  ],

                  // Estatísticas
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(context.mediaQuery.width * 0.04),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.red[300],
                                    size: context.mediaQuery.width * 0.06,
                                  ),
                                  SizedBox(
                                    height: context.mediaQuery.height * 0.005,
                                  ),
                                  Text(
                                    '${post.likes}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Likes',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Icon(
                                    Icons.chat_bubble,
                                    color: Colors.blue[300],
                                    size: context.mediaQuery.width * 0.06,
                                  ),
                                  SizedBox(
                                    height: context.mediaQuery.height * 0.005,
                                  ),
                                  Text(
                                    '${post.comments}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Comentários',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is PostDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: context.mediaQuery.width * 0.16,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: context.mediaQuery.height * 0.02),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.mediaQuery.height * 0.02),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PostDetailCubit>().loadPost(widget.postId);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Erro inesperado'));
          }
        },
      ),
    );
  }
}
