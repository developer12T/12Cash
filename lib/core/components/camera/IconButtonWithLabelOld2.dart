import 'dart:io';
import 'package:_12sale_app/core/components/camera/CameraButton.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class IconButtonWithLabelOld2 extends StatefulWidget {
  String? imagePath;
  final IconData icon;
  final String label;
  final TextStyle? labelStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Function(String imagePath)? onImageSelected; // Callback for image path
  bool checkNetwork;
  IconButtonWithLabelOld2({
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
  _IconButtonWithLabelOld2State createState() =>
      _IconButtonWithLabelOld2State();
}

class _IconButtonWithLabelOld2State extends State<IconButtonWithLabelOld2> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  // String? imagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      // print("cameras.length:${cameras.length}");
      if (cameras.isNotEmpty) {
        final firstCamera = cameras.first;
        _cameraController = CameraController(
          firstCamera,
          ResolutionPreset.max,
        );
        _initializeControllerFuture = _cameraController.initialize();
        await _initializeControllerFuture;
      } else {
        print("No cameras available");
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> openCamera(BuildContext context) async {
    await _initializeControllerFuture;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraPreviewScreen(
          initFuture:
              _initializeControllerFuture!, // ส่ง future แทนการ init ใหม่
          cameraController: _cameraController,
          onImageCaptured: (
            String imagePath,
          ) {
            setState(() {
              widget.imagePath = imagePath;
            });
            // Notify parent widget via callback
            if (widget.onImageSelected != null) {
              widget.onImageSelected!(imagePath);
            }
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
          width: screenWidth / 2,
          height: screenWidth / 2,
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
                            width: screenWidth / 1.5,
                            height: screenWidth / 1.5,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.imagePath!,
                            width: screenWidth / 1.5,
                            height: screenWidth / 1.5,
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
