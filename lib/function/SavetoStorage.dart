import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToStorage<T>(String key, List<T> items) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Convert each item to JSON and encode it as a JSON string
  List<String> jsonItems =
      items.map((item) => jsonEncode((item as dynamic).toJson())).toList();

  // print(jsonItems);

  // Save the JSON string list to SharedPreferences
  await prefs.setStringList(key, jsonItems);
}

Future<List<T>> loadFromStorage<T>(
  String key,
  T Function(Map<String, dynamic>) fromJson,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? jsonItems = prefs.getStringList(key);

  if (jsonItems == null) return [];

  return jsonItems.map((jsonItem) => fromJson(jsonDecode(jsonItem))).toList();
}
