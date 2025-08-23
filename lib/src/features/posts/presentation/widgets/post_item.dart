import 'package:app_test/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../data/domain/entities/post.dart';
import '../../../../core/routes/app_routes.dart';

class PostItem extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostItem({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: context.mediaQuery.width * 0.04,
        vertical: context.mediaQuery.height * 0.01,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.mediaQuery.width * 0.03),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.mediaQuery.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com informações do usuário
            Padding(
              padding: EdgeInsets.all(context.mediaQuery.width * 0.04),
              child: Row(
                children: [
                  // Avatar do usuário
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.profile,
                        arguments: 'user_${post.id}', // Mock user ID
                      );
                    },
                    child: CircleAvatar(
                      radius: context.mediaQuery.width * 0.05,
                      backgroundImage: post.userAvatar.isNotEmpty
                          ? NetworkImage(post.userAvatar)
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: post.userAvatar.isEmpty
                          ? Icon(Icons.person, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                  SizedBox(width: context.mediaQuery.width * 0.03),
                  // Nome e tempo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.profile,
                              arguments: 'user_${post.id}', // Mock user ID
                            );
                          },
                          child: Text(
                            post.userName,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          post.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Menu de opções
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                    iconSize: context.mediaQuery.width * 0.05,
                  ),
                ],
              ),
            ),

            // Título do post
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.mediaQuery.width * 0.04,
              ),
              child: Text(
                post.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: context.mediaQuery.height * 0.01),

            // Conteúdo do post
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.mediaQuery.width * 0.04,
              ),
              child: post.isContentTruncated
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: post.contentSummary,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[700]),
                          ),
                          TextSpan(
                            text: ' Ver mais',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                            recognizer: TapGestureRecognizer()..onTap = onTap,
                          ),
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      post.contentSummary,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),

            SizedBox(height: context.mediaQuery.height * 0.015),

            // Imagem do post
            if (post.image.isNotEmpty)
              Container(
                width: double.infinity,
                height: context.mediaQuery.height * 0.25,
                margin: EdgeInsets.symmetric(
                  horizontal: context.mediaQuery.width * 0.04,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    context.mediaQuery.width * 0.02,
                  ),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    context.mediaQuery.width * 0.02,
                  ),
                  child: Image.network(
                    post.image,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),

            // Tags
            if (post.tags.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(context.mediaQuery.width * 0.04),
                child: Wrap(
                  spacing: context.mediaQuery.width * 0.02,
                  runSpacing: context.mediaQuery.width * 0.01,
                  children: post.tags.take(3).map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.mediaQuery.width * 0.02,
                        vertical: context.mediaQuery.height * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          context.mediaQuery.width * 0.03,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Botões de ação (likes, comentários)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.mediaQuery.width * 0.04,
                vertical: context.mediaQuery.height * 0.01,
              ),
              child: Row(
                children: [
                  // Like
                  InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(
                      context.mediaQuery.width * 0.05,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.mediaQuery.width * 0.03,
                        vertical: context.mediaQuery.height * 0.01,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: context.mediaQuery.width * 0.05,
                            color: Colors.grey,
                          ),
                          SizedBox(width: context.mediaQuery.width * 0.01),
                          Text(
                            '${post.likes}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: context.mediaQuery.width * 0.04),

                  // Comentários
                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(
                      context.mediaQuery.width * 0.05,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.mediaQuery.width * 0.03,
                        vertical: context.mediaQuery.height * 0.01,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: context.mediaQuery.width * 0.05,
                            color: Colors.grey,
                          ),
                          SizedBox(width: context.mediaQuery.width * 0.01),
                          Text(
                            '${post.comments}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
