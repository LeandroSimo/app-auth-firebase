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
              title: model.title,
              body: model.body,
              userId: model.userId,
              userName: model.userName,
              userAvatar: model.userAvatar,
              image: model.image,
              likes: model.likes,
              comments: model.comments,
              createdAt: model.createdAt,
              tags: model.tags,
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
        title: postModel.title,
        body: postModel.body,
        userId: postModel.userId,
        userName: postModel.userName,
        userAvatar: postModel.userAvatar,
        image: postModel.image,
        likes: postModel.likes,
        comments: postModel.comments,
        createdAt: postModel.createdAt,
        tags: postModel.tags,
      );
    } catch (e) {
      rethrow;
    }
  }
}
