import 'dart:io';
import 'package:_12sale_app/core/components/camera/CameraFirst.dart';
import 'package:_12sale_app/core/components/camera/CameraPreviewScreen.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class IconButtonWithLabelFirst extends StatefulWidget {
  String? imagePath;
  final IconData icon;
  final String label;
  final TextStyle? labelStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Function(String imagePath)? onImageSelected; // Callback for image path
  bool checkNetwork;
  IconButtonWithLabelFirst({
    super.key,
    required this.icon,
    this.imagePath,
    required this.label,
    this.labelStyle,
    this.backgroundColor = Colors.blue,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.onImageSelected, // Optional parameter for callback
    this.checkNetwork = false,
  });

  @override
  _IconButtonWithLabelFirstState createState() =>
      _IconButtonWithLabelFirstState();
}

class _IconButtonWithLabelFirstState extends State<IconButtonWithLabelFirst>
    with WidgetsBindingObserver {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  String? imagePath;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(firstCamera, ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg);

    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController
        .dispose(); // Dispose of the camera controller to free resources
    super.dispose();
  }

  Future<void> openCamera(BuildContext context) async {
    await _initializeControllerFuture; // Wait for the camera to initialize
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraPreviewScreenFirst(
          cameraController: _cameraController,
          onImageCaptured: (String imagePath) {
            setState(() {
              this.imagePath = imagePath; // Store the image path when captured
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          width: screenWidth / 4,
          height: screenWidth / 4,
          child: ElevatedButton(
            onPressed: () => openCamera(context),
            style: ElevatedButton.styleFrom(
              padding: widget.padding,
              backgroundColor: widget.imagePath == null
                  ? Colors.grey[400]
                  : Styles.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            child: widget.imagePath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 50),
                      Text(
                        "gobal.camera_button.button".tr(),
                        style: Styles.white18(context),
                      )
                    ],
                  )
                : ClipRRect(
                    child: widget.checkNetwork == false
                        ? Image.file(
                            File(widget.imagePath!),
                            width: screenWidth / 4,
                            height: screenWidth / 4,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.imagePath!,
                            width: screenWidth / 4,
                            height: screenWidth / 4,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ),
        Text(
          widget.label,
          style: Styles.black18(context),
        ),
      ],
    );
  }
}
