import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:app_test/src/features/posts/data/services/post_api_service.dart';
import 'package:app_test/src/core/network/api_application.dart';

import 'post_api_service_test.mocks.dart';

@GenerateMocks([ApiApplication, Dio])
void main() {
  group('PostApiService Tests', () {
    late PostApiService postApiService;
    late MockApiApplication mockApiApplication;
    late MockDio mockDio;

    setUp(() {
      mockApiApplication = MockApiApplication();
      mockDio = MockDio();

      when(mockApiApplication.dio).thenReturn(mockDio);
      postApiService = PostApiService(apiApplication: mockApiApplication);
    });

    group('getPosts', () {
      test(
        'should return list of PostModel when API call is successful',
        () async {
          // Arrange
          final mockJsonResponse = [
            {
              'id': 1,
              'title': 'Primeiro Post',
              'body': 'Conteúdo do primeiro post de João Silva',
              'userId': 1,
              'userName': 'João Silva',
              'userAvatar': 'https://example.com/joao.jpg',
              'image': 'https://example.com/post1.jpg',
              'likes': 42,
              'comments': 15,
              'createdAt': '2024-01-15T10:30:00Z',
              'tags': ['tecnologia', 'flutter'],
            },
            {
              'id': 2,
              'title': 'Segundo Post',
              'body': 'Conteúdo do segundo post de Maria Santos',
              'userId': 2,
              'userName': 'Maria Santos',
              'userAvatar': 'https://example.com/maria.jpg',
              'image': 'https://example.com/post2.jpg',
              'likes': 28,
              'comments': 8,
              'createdAt': '2024-01-14T15:20:00Z',
              'tags': ['dart', 'mobile'],
            },
          ];

          final response = Response(
            data: mockJsonResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/posts'),
          );

          when(mockDio.get('/posts')).thenAnswer((_) async => response);

          // Act
          final result = await postApiService.getPosts();

          // Assert
          expect(result, hasLength(2));
          expect(result[0].title, equals('Primeiro Post'));
          expect(result[0].userName, equals('João Silva'));
          expect(result[1].title, equals('Segundo Post'));
          expect(result[1].userName, equals('Maria Santos'));
          verify(mockDio.get('/posts')).called(1);
        },
      );

      test('should handle empty response correctly', () async {
        // Arrange
        final response = Response(
          data: [],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/posts'),
        );

        when(mockDio.get('/posts')).thenAnswer((_) async => response);

        // Act
        final result = await postApiService.getPosts();

        // Assert
        expect(result, isEmpty);
      });

      test('should throw exception when API returns error status', () async {
        // Arrange
        final response = Response(
          data: null,
          statusCode: 500,
          requestOptions: RequestOptions(path: '/posts'),
        );

        when(mockDio.get('/posts')).thenAnswer((_) async => response);

        // Act & Assert
        expect(() => postApiService.getPosts(), throwsA(isA<Exception>()));
      });

      test('should throw exception when network connection fails', () async {
        // Arrange
        when(
          mockDio.get('/posts'),
        ).thenThrow(const SocketException('No internet connection'));

        // Act & Assert
        expect(() => postApiService.getPosts(), throwsA(isA<Exception>()));
      });

      test('should handle malformed JSON data gracefully', () async {
        // Arrange
        final mockJsonResponse = [
          {
            'id': 1,
            'title': 'Post Válido',
            'body': 'Conteúdo válido',
            'userId': 1,
            'userName': 'José',
            'userAvatar': 'https://example.com/jose.jpg',
            'image': 'https://example.com/post1.jpg',
            'likes': 5,
            'comments': 2,
            'createdAt': '2024-01-15T10:30:00Z',
            'tags': ['válido'],
          },
          {
            // Missing required fields
            'id': 2,
            'title': null,
            // Other fields missing
          },
        ];

        final response = Response(
          data: mockJsonResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/posts'),
        );

        when(mockDio.get('/posts')).thenAnswer((_) async => response);

        // Act
        final result = await postApiService.getPosts();

        // Assert
        expect(result, hasLength(2));
        expect(result[0].title, equals('Post Válido'));
        expect(result[0].userName, equals('José'));
        expect(result[1].title, isEmpty); // Should handle null gracefully
        expect(result[1].userName, isEmpty);
      });
    });

    group('getPostById', () {
      test('should return PostModel when post exists', () async {
        // Arrange
        final mockJsonResponse = {
          'id': 1,
          'title': 'Post Específico',
          'body': 'Conteúdo detalhado do post específico de Carlos Eduardo',
          'userId': 1,
          'userName': 'Carlos Eduardo',
          'userAvatar': 'https://example.com/carlos.jpg',
          'image': 'https://example.com/specific-post.jpg',
          'likes': 75,
          'comments': 23,
          'createdAt': '2024-01-15T10:30:00Z',
          'tags': ['específico', 'detalhado'],
        };

        final response = Response(
          data: mockJsonResponse,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/posts/1'),
        );

        when(mockDio.get('/posts/1')).thenAnswer((_) async => response);

        // Act
        final result = await postApiService.getPostById(1);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(1));
        expect(result.title, equals('Post Específico'));
        expect(result.userName, equals('Carlos Eduardo'));
        expect(result.likes, equals(75));
        verify(mockDio.get('/posts/1')).called(1);
      });

      test('should return null when post does not exist', () async {
        // Arrange
        final response = Response(
          data: null,
          statusCode: 404,
          requestOptions: RequestOptions(path: '/posts/999'),
        );

        when(mockDio.get('/posts/999')).thenAnswer((_) async => response);

        // Act
        final result = await postApiService.getPostById(999);

        // Assert
        expect(result, isNull);
      });

      test('should throw exception when API returns server error', () async {
        // Arrange
        final response = Response(
          data: null,
          statusCode: 500,
          requestOptions: RequestOptions(path: '/posts/1'),
        );

        when(mockDio.get('/posts/1')).thenAnswer((_) async => response);

        // Act & Assert
        expect(() => postApiService.getPostById(1), throwsA(isA<Exception>()));
      });

      test('should throw exception when network connection fails', () async {
        // Arrange
        when(
          mockDio.get('/posts/1'),
        ).thenThrow(const SocketException('Network error'));

        // Act & Assert
        expect(() => postApiService.getPostById(1), throwsA(isA<Exception>()));
      });

      test('should handle unexpected errors gracefully', () async {
        // Arrange
        when(mockDio.get('/posts/1')).thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(() => postApiService.getPostById(1), throwsA(isA<Exception>()));
      });
    });

    group('Default Constructor', () {
      test(
        'should create service with default ApiApplication when none provided',
        () {
          // Act
          final service = PostApiService();

          // Assert
          expect(service, isNotNull);
          // Service should be created successfully with default dependencies
        },
      );
    });

    group('Error Handling Edge Cases', () {
      test('should handle DioException correctly', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/posts'),
          type: DioExceptionType.connectionTimeout,
        );
        when(mockDio.get('/posts')).thenThrow(dioException);

        // Act & Assert
        expect(() => postApiService.getPosts(), throwsA(isA<Exception>()));
      });

      test('should handle null response data correctly', () async {
        // Arrange
        final response = Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/posts'),
        );

        when(mockDio.get('/posts')).thenAnswer((_) async => response);

        // Act & Assert
        expect(() => postApiService.getPosts(), throwsA(isA<Exception>()));
      });

      test('should handle invalid JSON format gracefully', () async {
        // Arrange
        final response = Response(
          data: 'invalid json format',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/posts'),
        );

        when(mockDio.get('/posts')).thenAnswer((_) async => response);

        // Act & Assert
        expect(() => postApiService.getPosts(), throwsA(isA<Exception>()));
      });
    });
  });
}
