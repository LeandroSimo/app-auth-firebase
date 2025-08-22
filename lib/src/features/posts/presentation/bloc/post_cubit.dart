import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/domain/repositories/post_repository.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository _postRepository;
  static const int _postsPerPage = 10;

  PostCubit({required PostRepository postRepository})
    : _postRepository = postRepository,
      super(PostInitial());

  Future<void> loadPosts() async {
    try {
      emit(PostLoading());

      final posts = await _postRepository.getPosts(
        page: 1,
        limit: _postsPerPage,
      );

      emit(
        PostLoaded(
          posts: posts,
          hasReachedMax: posts.length < _postsPerPage,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(PostError(message: _getErrorMessage(e)));
    }
  }

  Future<void> loadMorePosts() async {
    final currentState = state;
    if (currentState is PostLoaded && !currentState.hasReachedMax) {
      try {
        final nextPage = currentState.currentPage + 1;
        final newPosts = await _postRepository.getPosts(
          page: nextPage,
          limit: _postsPerPage,
        );

        if (newPosts.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              posts: [...currentState.posts, ...newPosts],
              hasReachedMax: newPosts.length < _postsPerPage,
              currentPage: nextPage,
            ),
          );
        }
      } catch (e) {
        emit(PostError(message: _getErrorMessage(e)));
      }
    }
  }

  Future<void> refreshPosts() async {
    try {
      final posts = await _postRepository.getPosts(
        page: 1,
        limit: _postsPerPage,
      );

      emit(
        PostLoaded(
          posts: posts,
          hasReachedMax: posts.length < _postsPerPage,
          currentPage: 1,
        ),
      );
    } catch (e) {
      emit(PostError(message: _getErrorMessage(e)));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Sem conexão com a internet')) {
      return 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
    } else if (error.toString().contains('Erro ao processar dados')) {
      return 'Erro ao processar dados do servidor. Tente novamente mais tarde.';
    } else {
      return 'Erro ao carregar posts. Tente novamente.';
    }
  }
}

class PostDetailCubit extends Cubit<PostDetailState> {
  final PostRepository _postRepository;

  PostDetailCubit({required PostRepository postRepository})
    : _postRepository = postRepository,
      super(PostDetailInitial());

  Future<void> loadPost(int postId) async {
    try {
      emit(PostDetailLoading());

      final post = await _postRepository.getPostById(postId);

      if (post != null) {
        emit(PostDetailLoaded(post: post));
      } else {
        emit(const PostDetailError(message: 'Post não encontrado'));
      }
    } catch (e) {
      emit(PostDetailError(message: _getErrorMessage(e)));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Sem conexão com a internet')) {
      return 'Sem conexão com a internet. Verifique sua conexão e tente novamente.';
    } else if (error.toString().contains('Erro ao processar dados')) {
      return 'Erro ao processar dados do servidor. Tente novamente mais tarde.';
    } else {
      return 'Erro ao carregar post. Tente novamente.';
    }
  }
}
