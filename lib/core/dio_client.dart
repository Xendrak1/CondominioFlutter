import 'package:dio/dio.dart';

class DioClientFactory {
  static Dio create({required String baseUrl, Interceptor? authInterceptor}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    if (authInterceptor != null) {
      dio.interceptors.add(authInterceptor);
    }

    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
    ));

    return dio;
  }
}
