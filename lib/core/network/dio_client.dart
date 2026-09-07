// lib/core/network/dio_client.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_constants.dart';
import 'mock_interceptor.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: AppConstants.keyAuthToken);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    options.headers['X-Client'] = 'KrishiSetuRider/1.0';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired — caller should redirect to login
    }
    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final retries = (options.extra['retries'] as int?) ?? 0;

    if (retries < maxRetries &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError)) {
      options.extra['retries'] = retries + 1;
      await Future.delayed(Duration(seconds: (retries + 1) * 2));
      try {
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        // continue to original error
      }
    }
    handler.next(err);
  }
}

class DioClient {
  DioClient._();
  static final DioClient instance = DioClient._();

  late Dio _dio;
  bool _initialized = false;

  void initialize(FlutterSecureStorage storage) {
    if (_initialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        responseType: ResponseType.plain,
      ),
    );

    if (AppConstants.useMockApi) {
      _dio.interceptors.add(MockInterceptor());
    } else {
      _dio.interceptors.add(AuthInterceptor(storage));
      _dio.interceptors.add(RetryInterceptor(dio: _dio));
    }

    _initialized = true;
  }

  Dio get dio => _dio;

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParams}) async {
    final response =
        await _dio.get(path, queryParameters: queryParams);
    return _parse(response);
  }

  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? data}) async {
    final response = await _dio.post(path, data: jsonEncode(data ?? {}));
    return _parse(response);
  }

  Future<Map<String, dynamic>> put(String path,
      {Map<String, dynamic>? data}) async {
    final response = await _dio.put(path, data: jsonEncode(data ?? {}));
    return _parse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
      String path, FormData formData) async {
    final response = await _dio.post(path, data: formData);
    return _parse(response);
  }

  Map<String, dynamic> _parse(Response response) {
    if (response.data is String) {
      return jsonDecode(response.data as String) as Map<String, dynamic>;
    }
    return response.data as Map<String, dynamic>;
  }
}
