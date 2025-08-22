import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostApiService {
  static const String baseUrl = 'https://jsonplaceholder.org';
  final http.Client _client;

  PostApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PostModel>> getPosts({int page = 1, int limit = 10}) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/posts?_page=$page&_limit=$limit'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => PostModel.fromJson(json)).toList();
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
      final response = await _client
          .get(
            Uri.parse('$baseUrl/posts/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return PostModel.fromJson(json);
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

  void dispose() {
    _client.close();
  }
}
