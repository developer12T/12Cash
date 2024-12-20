import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio dio = Dio();

  // Load the .env file in the constructor
  ApiService() {
    dotenv.load(fileName: ".env");
  }
  // Init function to load .env file asynchronously
  Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  Future<dynamic> request({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      String baseUrl = dotenv.env['API_URL'] ?? ''; // Load base URL from .env
      String url = '$baseUrl/$endpoint'; // Construct the full URL

      Options options = Options(
        method: method,
        headers: headers ??
            {
              'Content-Type': 'application/json',
            },
      );

      Response response;

      // Handle GET and POST requests
      if (method == 'GET') {
        response =
            await dio.get(url, queryParameters: queryParams, options: options);
      } else {
        response = await dio.post(url,
            data: body, queryParameters: queryParams, options: options);
      }

      print('Response: ${response}');
      return response; // Return the response data
    } catch (e) {
      print('Error occurred: $e');
      return null; // Return null or handle errors based on your need
    }
  }

  Future<dynamic> requestMongoDB({
    required String endpoint,
    String method = 'GET',
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      String baseUrl = "http://192.168.44.116:3030"; // Load base URL from .env
      String url = '$baseUrl/$endpoint'; // Construct the full URL

      Options options = Options(
        method: method,
        headers: headers ??
            {
              'Content-Type': 'application/json',
            },
      );

      Response response;

      // Handle GET and POST requests
      if (method == 'GET') {
        response =
            await dio.get(url, queryParameters: queryParams, options: options);
      } else {
        response = await dio.post(url,
            data: body, queryParameters: queryParams, options: options);
      }

      print('Response: ${response.data}');
      return response.data; // Return the response data
    } catch (e) {
      print('Error occurred: $e');
      return null; // Return null or handle errors based on your need
    }
  }
}
