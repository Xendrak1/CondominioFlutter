import 'package:dio/dio.dart';

typedef TokenFetcher = Future<String?> Function();
typedef RefreshHandler = Future<bool> Function();

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.getAccessToken, required this.tryRefresh, required this.dio});

  final TokenFetcher getAccessToken;
  final RefreshHandler tryRefresh;
  final Dio dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await tryRefresh();
      if (refreshed) {
        final requestOptions = err.requestOptions;
        // Clonar petición y reintentar
        final newOptions = Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
          followRedirects: requestOptions.followRedirects,
          receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
          sendTimeout: requestOptions.sendTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
          validateStatus: requestOptions.validateStatus,
        );
        try {
          final response = await dio.request(
            requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            options: newOptions,
            cancelToken: requestOptions.cancelToken,
            onReceiveProgress: requestOptions.onReceiveProgress,
            onSendProgress: requestOptions.onSendProgress,
          );
          return handler.resolve(response);
        } catch (e) {
          return handler.reject(e is DioException ? e : DioException(requestOptions: requestOptions, error: e));
        }
      }
    }
    handler.next(err);
  }
}
