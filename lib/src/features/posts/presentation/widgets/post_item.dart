import 'package:app_test/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import '../../data/domain/entities/post.dart';

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
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.mediaQuery.width * 0.02),
        child: Padding(
          padding: EdgeInsets.all(context.mediaQuery.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                post.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.mediaQuery.height * 0.015),

              // Conteúdo
              Text(
                post.contentSummary,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Botão "Ver mais" se o conteúdo foi truncado
              if (post.isContentTruncated) ...[
                SizedBox(height: context.mediaQuery.height * 0.01),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Ver mais',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Footer com data e autor
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: context.mediaQuery.width * 0.01),
                      Text(
                        'Autor ${post.userId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: context.mediaQuery.width * 0.04,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: context.mediaQuery.width * 0.01),
                      Text(
                        post.formattedPublishDate,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
