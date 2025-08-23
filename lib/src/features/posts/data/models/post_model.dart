class PostModel {
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

  const PostModel({
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

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: _parseToInt(json['id']),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      userId: _parseToInt(json['userId']),
      userName: json['userName']?.toString() ?? '',
      userAvatar: json['userAvatar']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      likes: _parseToInt(json['likes']),
      comments: _parseToInt(json['comments']),
      createdAt: json['createdAt']?.toString() ?? '',
      tags: _parseToStringList(json['tags']),
    );
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static List<String> _parseToStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'image': image,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt,
      'tags': tags,
    };
  }

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
  String toString() {
    return 'PostModel(id: $id, title: $title, userId: $userId, userName: $userName)';
  }
}
