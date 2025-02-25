import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class CameraPreviewScreen extends StatefulWidget {
  final CameraController cameraController;
  final Function(String) onImageCaptured;
  Map<String, dynamic>? deviceData;

  CameraPreviewScreen({
    Key? key,
    required this.cameraController,
    required this.onImageCaptured,
    this.deviceData,
  }) : super(key: key);

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  // static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  // Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    widget.cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final rotationAngle =
        widget.cameraController.description.sensorOrientation == 270
            ? 1.5708 // 90 degrees in radians
            : 0.0; // No rotation for other orientations
    final isLandscape =
        widget.cameraController.description.sensorOrientation == 90 ||
            widget.cameraController.description.sensorOrientation == 270;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            icon: Icons.camera_alt, title: "gobal.camera_button.appbar".tr()),
      ),
      body: FutureBuilder<void>(
        future: widget.cameraController.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Center(child: CameraPreview(widget.cameraController)),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: () async {
                        try {
                          // Capture the picture
                          final image =
                              await widget.cameraController.takePicture();

                          // Pass the file path back to the previous screen
                          widget.onImageCaptured(image.path);

                          // Pop the current screen after the photo is taken
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          debugPrint('Error capturing image: $e');
                        }
                      },
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
