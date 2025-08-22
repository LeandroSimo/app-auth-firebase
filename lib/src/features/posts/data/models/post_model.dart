class PostModel {
  final int id;
  final String slug;
  final String url;
  final String title;
  final String content;
  final String image;
  final String thumbnail;
  final String status;
  final String category;
  final String publishedAt;
  final String updatedAt;
  final int userId;

  const PostModel({
    required this.id,
    required this.slug,
    required this.url,
    required this.title,
    required this.content,
    required this.image,
    required this.thumbnail,
    required this.status,
    required this.category,
    required this.publishedAt,
    required this.updatedAt,
    required this.userId,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      slug: json['slug'] ?? '',
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      image: json['image'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'url': url,
      'title': title,
      'content': content,
      'image': image,
      'thumbnail': thumbnail,
      'status': status,
      'category': category,
      'publishedAt': publishedAt,
      'updatedAt': updatedAt,
      'userId': userId,
    };
  }

  // Método para obter um resumo do conteúdo
  String get contentSummary {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100)}...';
  }

  // Método para verificar se o conteúdo foi truncado
  bool get isContentTruncated => content.length > 100;

  // Método para formatar a data de publicação
  String get formattedPublishDate {
    try {
      // Assuming the date format is DD/MM/YYYY HH:mm:ss
      final parts = publishedAt.split(' ');
      if (parts.length >= 2) {
        final dateParts = parts[0].split('/');
        if (dateParts.length == 3) {
          return '${dateParts[0]}/${dateParts[1]}/${dateParts[2]}';
        }
      }
      return publishedAt;
    } catch (e) {
      return publishedAt;
    }
  }

  @override
  String toString() {
    return 'PostModel(id: $id, title: $title, userId: $userId)';
  }
}
