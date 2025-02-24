import 'package:flutter/services.dart';

class AndroidAPILevelChecker {
  static const MethodChannel _channel =
      MethodChannel('com.example.android_api_checker');

  static Future<bool> isCamera2APISupported() async {
    try {
      final int apiLevel = await _channel.invokeMethod<int>('getAPILevel') ?? 0;
      return apiLevel >= 21; // API 21 corresponds to LOLLIPOP
    } catch (e) {
      print('Error checking API level: $e');
      return false;
    }
  }
}
