/*
  @author   : Gayathri
  @created  : 08/11/2025
  @desc     : Refactored ApiClient with improved error handling and dependency injection
*/

import 'dart:math' as Math;

import 'package:sysmo_verification/kyc_validation.dart';
import 'package:sysmo_verification/src/Utils/aes_utils.dart';

/// HttpHeaderConfig holds default headers for API requests
class HttpHeaderConfig {
  static const Map<String, String> defaultHeaders = {
    // 'clientID': '220',
    // 'productID': '1',
    // 'appno': '100050000000004',
    // 'module': 'MSME',
    // 'branch': 'Chennai',
    // 'user': 'user845',
    // 'cp-client-trans-id': '1763037635616',
    // 'cbsid': '',

      "Accept": "application/json",
        "Content-Type": "application/json",
        'token': "U2FsdGVkX18JsMjl/kms7Q3a2rtD/YgqDLmV74wiIsqy8OtDJa1wYGd7dvlWVwYI",
        'deviceId': 'U2FsdGVkX180KT9qN6Y67G1lw9hDybHtn/+Ud28GUrioyRQBjav6ui2BgXBGv4nz',
        'userid': 'SAIGANESH',
  };
}

/// Refactored ApiClient with better separation of concerns
class ApiClient {
  final Dio dio;
  final bool enableLogging;

  ApiClient({
    Dio? dioInstance,
    this.enableLogging = true,
  }) : dio = dioInstance ?? Dio() {
    _configureClient();
  }

  /// Configure Dio with default headers and interceptors
  void _configureClient() {
    dio.options.headers = HttpHeaderConfig.defaultHeaders;

    if (enableLogging) {
      dio.interceptors.add(
        PrettyDioLogger(
          responseHeader: true,
          responseBody: true,
          requestHeader: true,
          requestBody: true,
          request: true,
          compact: false,
        ),
      );
    }

    dio.interceptors.add(TokenInterceptor());
  }

  /// Perform POST request with optional data
  Future<Response> post(String url, {dynamic data}) async {
    try {
      return await dio.post(url, data: data);
    } catch (e) {
      rethrow;
    }
  }

  /// Perform GET request
  Future<Response> get(String url) async {
    try {
      return await dio.get(url);
    } catch (e) {
      rethrow;
    }
  }

  /// Deprecated methods kept for backward compatibility
  @Deprecated('Use post() instead')
  Future<Response> callPost(String url, {data}) => post(url, data: data);

  @Deprecated('Use get() instead')
  Future<Response> callGet(String url) => get(url);
}

String? expectedTokenValue;

String generateToken() {
  var timestamp = DateTime.now();
  var ranNum = Math.Random().nextInt(90000000) + 10000000;
  String token = "${timestamp.toString()}_${ranNum.toString()}";
  expectedTokenValue = token;
  return encryptString(inputText: token);
}

Map<String, dynamic> _encryptRequestBody(Map<String, dynamic> body) {
  final jsonBody = jsonEncode(body);
  final cipherText = encryptString(inputText: jsonBody);
  return {'data': cipherText};
}

Map<String, dynamic>? _decryptResponseBody(dynamic data) {
  try {
    if (data is Map && data['data'] is String) {
      final decrypted = decryptString(encryptedText: data['data']);
      final decoded = jsonDecode(decrypted);
      return decoded is Map<String, dynamic> ? decoded : null;
    }
  } catch (_) {}
  return null;
}

// Custom Interceptor for Token Handling
class TokenInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Generate token
    String token = generateToken();

    // Add token to headers
    options.headers['token'] = token;

    // Add encrypted token to body and encrypt body (for JSON requests)
    if (options.data is Map<String, dynamic>) {
      final body = Map<String, dynamic>.from(options.data);
      body['token'] = token;
      // body['token'] = encryptString(inputText: token);
      options.data = _encryptRequestBody(body);
    } else if (options.data is FormData) {
      // FormData is not encrypted here
      options.data.fields.add(
        // MapEntry('token', encryptString(inputText: token)),
        MapEntry('token', token),
      );
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      // Decrypt body
      final decryptedBody = _decryptResponseBody(response.data);
      if (decryptedBody != null) {
        response.data = decryptedBody;
      }

      // Getting response token (from decrypted body or header)
      String? responseToken;
      final tokenSource = decryptedBody ?? response.data;

      if (response.realUri.path.contains('/getMpinDetails') &&
          tokenSource is Map &&
          tokenSource['map'] is Map) {
        final res = tokenSource['map'] as Map;
        if (res['token'] != null) {
          responseToken = res['token'].toString();
        } else if (response.headers['token'] != null &&
            response.headers['token']!.isNotEmpty) {
          responseToken = response.headers['token']!.first;
        }
      } else {
        if (tokenSource is Map && tokenSource['token'] != null) {
          responseToken = tokenSource['token'].toString();
        } else if (response.headers['token'] != null &&
            response.headers['token']!.isNotEmpty) {
          responseToken = response.headers['token']!.first;
        }
      }

      // Decrypting response token for comparison
      String? decryptedResponseToken = responseToken != null
          ? decryptString(encryptedText: responseToken)
          : null;

      if (decryptedResponseToken != null &&
          decryptedResponseToken == expectedTokenValue) {
        handler.next(response);
      } else {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            error: 'TokenMismatchException',
            message: 'Token does not match expected value',
            response: response,
          ),
        );
      }
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: 'TokenCheckException',
          message: 'Error during token check: $e',
          response: response,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}