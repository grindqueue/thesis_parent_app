import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/storage.dart';

// ── API Response Wrapper ──────────────────────────────────────────
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });
}

// ── API Exception ─────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

// ── Base API Service ──────────────────────────────────────────────
class ApiService {
  static final String _base = AppConstants.baseUrl;

  // Build headers — attach JWT if available
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await AppStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── GET ───────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) async {
    try {
      var uri = Uri.parse('$_base$path');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: await _headers(auth: auth))
          .timeout(AppConstants.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on HttpException {
      throw ApiException(message: 'Server error. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Something went wrong. Please try again.');
    }
  }

  // ── POST ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final uri = Uri.parse('$_base$path');
      final response = await http
          .post(
            uri,
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(AppConstants.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Something went wrong. Please try again.');
    }
  }

  // ── PATCH ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    try {
      final uri = Uri.parse('$_base$path');
      final response = await http
          .patch(
            uri,
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(AppConstants.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Something went wrong. Please try again.');
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
  }) async {
    try {
      final uri = Uri.parse('$_base$path');
      final response = await http
          .delete(uri, headers: await _headers(auth: auth))
          .timeout(AppConstants.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Something went wrong. Please try again.');
    }
  }

  // ── Multipart (File Upload) ───────────────────────────────────────
  static Future<Map<String, dynamic>> uploadFile(
    String path,
    File file,
    String fieldName, {
    Map<String, String>? fields,
  }) async {
    try {
      final token = await AppStorage.getToken();
      final uri = Uri.parse('$_base$path');
      final request = http.MultipartRequest('POST', uri);

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      if (fields != null) request.fields.addAll(fields);

      final streamed = await request.send().timeout(AppConstants.receiveTimeout);
      final response = await http.Response.fromStream(streamed);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'File upload failed. Please try again.');
    }
  }

  // ── Response Handler ──────────────────────────────────────────────
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    Map<String, dynamic> body = {};

    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      body = {'message': response.body};
    }

    if (statusCode >= 200 && statusCode < 300) {
      return body;
    } else if (statusCode == 401) {
      throw ApiException(
        message: body['message'] ?? 'Unauthorized. Please log in again.',
        statusCode: statusCode,
      );
    } else if (statusCode == 403) {
      throw ApiException(
        message: body['message'] ?? 'Access denied.',
        statusCode: statusCode,
      );
    } else if (statusCode == 404) {
      throw ApiException(
        message: body['message'] ?? 'Resource not found.',
        statusCode: statusCode,
      );
    } else if (statusCode == 422) {
      throw ApiException(
        message: body['message'] ?? 'Invalid data provided.',
        statusCode: statusCode,
      );
    } else if (statusCode >= 500) {
      throw ApiException(
        message: 'Server error. Please try again later.',
        statusCode: statusCode,
      );
    } else {
      throw ApiException(
        message: body['message'] ?? 'Request failed.',
        statusCode: statusCode,
      );
    }
  }
}
