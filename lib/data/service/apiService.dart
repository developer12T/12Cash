import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    return 'ApiException: $message (Status Code: $statusCode)';
  }
}

class ApiService {
  final Dio dio = Dio();

  static final String apiHost =
      dotenv.env['API_URL'] ?? 'https://default.host.com';

  // Load the .env file in the constructor
  ApiService() {
    dotenv.load(fileName: ".env");
  }
  // Init function to load .env file asynchronously
  Future<void> init() async {
    await dotenv.load(fileName: ".env");

    // ✅ Set default headers
    dio.options.headers = {
      'Accept': 'application/json',
      'User-Agent': 'PostmanRuntime/7.32.3',
      'Content-Type': 'application/json',
      'x-channel': 'cash',
    };

    // ✅ Allow all SSL certificates (for debug only!)
    // ignore: deprecated_member_use
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  Future<dynamic> request({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      String baseUrl = dotenv.env['API_URL'] ?? 'https://default.host.com';
      String url = '$baseUrl/$endpoint';
      print("➡️ Requesting: $url");
      print("➡️ Method: $method");
      print("➡️ Params: $queryParams");
      print("➡️ Body: $body");

      Options options = Options(
        method: method,
        headers: headers ??
            {
              'Accept': 'application/json',
              'User-Agent': 'PostmanRuntime/7.32.3',
              'Content-Type': 'application/json',
              'x-channel': 'cash',
            },
      );

      Response response;

      if (method == 'GET') {
        response =
            await dio.get(url, queryParameters: queryParams, options: options);
      } else if (method == 'POST') {
        response = await dio.post(url,
            data: body, queryParameters: queryParams, options: options);
      } else {
        response = await dio.patch(url,
            data: body, queryParameters: queryParams, options: options);
      }

      return response; // Return the data from the response
    } on DioError catch (dioError) {
      String errorMessage = 'An error occurred during the request.';
      int? statusCode = dioError.response?.statusCode;

      // Customize error messages based on status code
      if (statusCode == 400) {
        errorMessage = 'Bad Request';
      } else if (statusCode == 401) {
        errorMessage = 'Unauthorized. Please log in again.';
      } else if (statusCode == 500) {
        errorMessage = 'Server error. Please try again later.';
      }

      // Throw a custom exception
      throw ApiException(errorMessage, statusCode);
    } catch (e) {
      // Handle other types of errors
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<dynamic> request2({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? queryParams,
    dynamic body, // ✅ <-- was Map<String, dynamic>?
    Map<String, String>? headers,
  }) async {
    try {
      String url = '$apiHost/$endpoint';

      Options options = Options(
        method: method,
        headers: headers ?? dio.options.headers,
      );

      Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await dio.get(url,
              queryParameters: queryParams, options: options);
          break;
        case 'POST':
          response = await dio.post(url,
              data: body, queryParameters: queryParams, options: options);
          break;
        case 'PATCH':
          response = await dio.patch(url,
              data: body, queryParameters: queryParams, options: options);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return response;
    } on DioException catch (dioError) {
      int? statusCode = dioError.response?.statusCode;
      String errorMessage = dioError.message ?? 'Unknown Dio error';

      if (statusCode == 400) {
        errorMessage = 'Bad Request';
      } else if (statusCode == 401) {
        errorMessage = 'Unauthorized';
      } else if (statusCode == 500) {
        errorMessage = 'Server error';
      }

      throw ApiException(errorMessage, statusCode);
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }
}
