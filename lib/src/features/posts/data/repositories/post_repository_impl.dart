import '../domain/entities/post.dart';
import '../domain/repositories/post_repository.dart';
import '../services/post_api_service.dart';

class PostRepositoryImpl implements PostRepository {
  final PostApiService _apiService;

  PostRepositoryImpl({required PostApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<Post>> getPosts({int page = 1, int limit = 10}) async {
    try {
      final postModels = await _apiService.getPosts(page: page, limit: limit);

      return postModels
          .map(
            (model) => Post(
              id: model.id,
              slug: model.slug,
              url: model.url,
              title: model.title,
              content: model.content,
              image: model.image,
              thumbnail: model.thumbnail,
              status: model.status,
              category: model.category,
              publishedAt: model.publishedAt,
              updatedAt: model.updatedAt,
              userId: model.userId,
            ),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Post?> getPostById(int id) async {
    try {
      final postModel = await _apiService.getPostById(id);

      if (postModel == null) return null;

      return Post(
        id: postModel.id,
        slug: postModel.slug,
        url: postModel.url,
        title: postModel.title,
        content: postModel.content,
        image: postModel.image,
        thumbnail: postModel.thumbnail,
        status: postModel.status,
        category: postModel.category,
        publishedAt: postModel.publishedAt,
        updatedAt: postModel.updatedAt,
        userId: postModel.userId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
