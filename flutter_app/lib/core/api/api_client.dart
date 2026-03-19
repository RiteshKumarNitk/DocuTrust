import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Ensure this matches the port your backend is running on (e.g. 3000 or 3001).
  static const _baseUrl = 'http://localhost:3000/api';
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // TODO: navigate to login screen
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<String> uploadDocument({
    required String docType,
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    final formData = FormData.fromMap({
      'file': fileBytes != null
          ? MultipartFile.fromBytes(fileBytes, filename: fileName)
          : await MultipartFile.fromFile(filePath!),
      'type': docType,
    });

    final response = await _dio.post('/document/upload', data: formData);
    return response.data['data']['id'] as String;
  }

  Future<Map<String, dynamic>> getDocumentResult(String id) async {
    final response = await _dio.get('/document/$id');
    return response.data['data'] as Map<String, dynamic>;
  }
}
