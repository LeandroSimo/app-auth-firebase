import 'dart:io';
import '../../../../core/network/api_application.dart';
import '../../../../core/utils/api_constants.dart';
import '../models/post_model.dart';

class PostApiService {
  final ApiApplication _apiApplication;

  PostApiService({ApiApplication? apiApplication})
    : _apiApplication = apiApplication ?? ApiApplication();

  Future<List<PostModel>> getPosts({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiApplication.dio.get(ApiConstants.allPosts);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;
        final allPosts = jsonList
            .map((json) => PostModel.fromJson(json))
            .toList();

        // Simula paginação
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;

        if (startIndex >= allPosts.length) {
          return [];
        }

        return allPosts.sublist(
          startIndex,
          endIndex > allPosts.length ? allPosts.length : endIndex,
        );
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sem conexão com a internet');
    } on FormatException {
      throw Exception('Erro ao processar dados do servidor');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<PostModel?> getPostById(int id) async {
    try {
      final response = await _apiApplication.dio.get(
        ApiConstants.postById.replaceFirst('{id}', id.toString()),
      );

      if (response.statusCode == 200) {
        return PostModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        return null; // Post não encontrado
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Sem conexão com a internet');
    } on FormatException {
      throw Exception('Erro ao processar dados do servidor');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
