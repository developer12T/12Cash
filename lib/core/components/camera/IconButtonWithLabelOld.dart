import 'dart:io';
import 'package:_12sale_app/core/components/camera/CameraButton.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class IconButtonWithLabelOld extends StatefulWidget {
  final String? imagePath;
  final IconData icon;
  final String label;
  final TextStyle? labelStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Function(String imagePath)? onImageSelected;
  final bool checkNetwork;

  IconButtonWithLabelOld({
    super.key,
    required this.icon,
    this.imagePath,
    required this.label,
    this.labelStyle,
    this.backgroundColor = Colors.blue,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.onImageSelected,
    this.checkNetwork = false,
  });

  @override
  _IconButtonWithLabelOldState createState() => _IconButtonWithLabelOldState();
}

class _IconButtonWithLabelOldState extends State<IconButtonWithLabelOld> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  String? imagePath;
  bool _isInitializingCamera = false;

  @override
  void initState() {
    super.initState();
    imagePath = widget.imagePath;
    // *** ไม่ต้อง initialize ที่นี่ ***
  }

  // ปิดกล้องเก่า
  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      _initializeControllerFuture = null;
    }
  }

  // เปิดกล้องใหม่ทุกครั้ง
  Future<bool> _initializeCamera() async {
    setState(() => _isInitializingCamera = true);
    await _disposeCamera();
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.max,
        );
        _initializeControllerFuture = _cameraController!.initialize();
        await _initializeControllerFuture;
        setState(() => _isInitializingCamera = false);
        return true;
      } else {
        setState(() => _isInitializingCamera = false);
        return false;
      }
    } catch (e) {
      setState(() => _isInitializingCamera = false);
      print("Error initializing camera: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _disposeCamera();
    super.dispose();
  }

  Future<void> openCamera(BuildContext context) async {
    if (_isInitializingCamera) {
      // กำลังเปิดกล้อง
      return;
    }
    final ok = await _initializeCamera();
    if (!ok || _cameraController == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเปิดกล้องได้')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraPreviewScreen(
          initFuture:
              _initializeControllerFuture!, // ส่ง future แทนการ init ใหม่
          cameraController: _cameraController!,
          onImageCaptured: (String path) {
            setState(() {
              imagePath = path;
            });
            if (widget.onImageSelected != null) {
              widget.onImageSelected!(path);
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
          width: screenWidth / 4,
          height: screenWidth / 4,
          child: ElevatedButton(
            onPressed: _isInitializingCamera ? null : () => openCamera(context),
            style: ElevatedButton.styleFrom(
              padding: widget.padding,
              backgroundColor:
                  imagePath == null ? Colors.grey[400] : Styles.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            child: _isInitializingCamera
                ? const CircularProgressIndicator()
                : imagePath == null
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
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        child: widget.checkNetwork == false
                            ? Image.file(
                                File(imagePath!),
                                width: screenWidth / 4,
                                height: screenWidth / 4,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                imagePath!,
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
          style: widget.labelStyle ?? Styles.black18(context),
        ),
      ],
    );
  }
}
