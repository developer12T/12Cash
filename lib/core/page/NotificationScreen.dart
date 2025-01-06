import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:_12sale_app/data/service/requestPremission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  int count = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the FlutterLocalNotificationsPlugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification interaction here
        print("Notification clicked: ${response.payload}");
      },
    );
  }

  Future<String> rotateImage(String imagePath) async {
    // Read the image file as bytes
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();

    // Decode the image
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Failed to decode image");
    }

    // Rotate the image (90 degrees clockwise as an example)
    final rotatedImage = img.copyRotate(originalImage, angle: 360);

    // Save the rotated image to a new file
    final rotatedImagePath = '${imagePath}_rotated.png';
    final rotatedFile = File(rotatedImagePath);
    await rotatedFile.writeAsBytes(img.encodePng(rotatedImage));

    return rotatedImagePath;
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    print(filePath);
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<Uint8List> _getBitmapFromAsset(String assetPath) async {
    final ByteData byteData = await rootBundle.load(assetPath);
    return byteData.buffer.asUint8List();
  }

  // Show a simple notification
  Future<void> _showNotification() async {
    // Load the image as a Bitmap
    final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(
      await _getBitmapFromAsset('assets/images/ic_launcher.png'),
    );
    final String largeIconPath =
        await _downloadAndSaveFile('https://dummyimage.com/48x48', 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(
        'http://192.168.44.57:8000/image/stores/BE211/1734681031885-20241220-store.jpg',
        'bigPicture');
    final rotatedBigPicturePath = await rotateImage(bigPicturePath);
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(FilePathAndroidBitmap(rotatedBigPicturePath),
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            contentTitle: 'overridden <b>big</b> content title',
            htmlFormatContentTitle: true,
            summaryText: 'summary <i>text</i>',
            htmlFormatSummaryText: true);
    // Create AndroidNotificationDetails with the dynamic count
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id', // Unique channel ID
      'channel_name', // Channel name for display
      sound: RawResourceAndroidNotificationSound('notification'),
      playSound: true,
      // color: const Color(0xFF123456), // Custom color
      largeIcon: largeIcon, // Your large icon resource
      // importance: Importance.high, // Importance level
      // priority: Priority.high, // Priority level
      // ticker: 'Custom Notification', // Ticker text displayed briefly
      // styleInformation: BigTextStyleInformation(
      //   'This is a long notification message. Count: $count', // Dynamically include count
      //   contentTitle: '<b>Dynamic Count: $count</b>', // Use count in title
      //   summaryText:
      //       'Notification Summary with Count: $count', // Include count in summary
      //   htmlFormatContent: true, // Enable HTML formatting for content
      //   htmlFormatContentTitle: true, // Enable HTML formatting for title
      // ),
      styleInformation: bigPictureStyleInformation,
    );

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);
    await requestNotificationPermission();

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Hello! 1', // Notification title
      'This is a test notification.', // Notification body
      platformDetails,
      payload: 'Custom Payload', // Optional data to pass
    );
    setState(() {
      count++;
    });
    await flutterLocalNotificationsPlugin.show(
      1, // Notification ID
      'Hello! 2', // Notification title
      'This is a test notification.', // Notification body
      platformDetails,
      payload: 'Custom Payload', // Optional data to pass
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Local Notifications")),
      body: Center(
        child: ElevatedButton(
          onPressed: _showNotification,
          child: Text("Show Notification"),
        ),
      ),
    );
  }
}
