import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class User {
  static String id = "";
  static String username = "";
  static String firstName = "";
  static String surName = "";
  static String fullName = "";
  static String saleCode = "";
  static String salePayer = "";
  static String tel = "";
  static String area = "";
  static String zone = "";
  static String warehouse = "";
  static String role = "";
  static String token = '';
  static double lat = 00.000;
  static double lng = 00.000;
  static BluetoothInfo devicePrinter =
      new BluetoothInfo(macAdress: "", name: "");
  static bool connectPrinter = false;
}
