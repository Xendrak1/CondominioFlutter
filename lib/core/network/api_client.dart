import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../env/env.dart';

class ApiClient {
  static final Dio _dio = Dio();
  static const _storage = FlutterSecureStorage();

  static Dio get dio => _dio;

  static void configure() {
    _dio.options = BaseOptions(
      baseUrl: '${EnvConfig.baseUrl}/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Interceptor para agregar JWT automáticamente
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expirado, intentar refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Reintentar la petición original
            final token = await _getAccessToken();
            if (token != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  static Future<String?> _getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post('/auth/refresh/', data: {
        'refresh': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        await _storage.write(key: 'access_token', value: data['access']);
        await _storage.write(key: 'refresh_token', value: data['refresh']);
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return false;
  }

  static Future<void> setTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}
