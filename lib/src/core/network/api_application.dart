import 'package:dio/dio.dart';

class ApiApplication {
  final Dio _dio = Dio();

  ApiApplication() {
    // _dio.options.baseUrl = 'http://10.0.2.2:3000'; // Para emulador Android
    _dio.options.baseUrl =
        'http://SEU_IP_AQUI:3000'; // IP da máquina na rede local
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Dio get dio => _dio;
}
