import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;
  final int userId;
  final String userName;
  final String userAvatar;
  final String image;
  final int likes;
  final int comments;
  final String createdAt;
  final List<String> tags;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.image,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.tags,
  });

  DateTime get createdAtDateTime {
    try {
      return DateTime.parse(createdAt);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAtDateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}sem';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'agora';
    }
  }

  // Método para obter um resumo do conteúdo limitado a 100 caracteres
  String get contentSummary {
    if (body.length <= 100) return body;
    return '${body.substring(0, 100)}...';
  }

  // Método para verificar se o conteúdo foi truncado
  bool get isContentTruncated => body.length > 100;

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    userId,
    userName,
    userAvatar,
    image,
    likes,
    comments,
    createdAt,
    tags,
  ];

  @override
  String toString() {
    return 'Post(id: $id, title: $title, userId: $userId, userName: $userName)';
  }
}
