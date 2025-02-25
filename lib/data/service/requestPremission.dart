import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestAllPermissions() async {
  // List of permissions to request
  final permissions = [
    Permission.notification,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.locationWhenInUse,
    Permission.camera,
    Permission.nearbyWifiDevices,
    Permission.locationAlways,
    Permission.photos,
    Permission.storage,
  ];

  for (var permission in permissions) {
    // Check if the permission is denied
    if (await permission.isDenied) {
      final status = await permission.request();
      if (status.isGranted) {
        print("${permission.toString()} permission granted!");
      } else {
        print("${permission.toString()} permission denied!");
      }
    } else if (await permission.isGranted) {
      print("${permission.toString()} permission already granted.");
    }
  }
}
