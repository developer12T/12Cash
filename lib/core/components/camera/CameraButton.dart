import 'package:_12sale_app/core/components/Appbar.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class CameraButtonWidget extends StatefulWidget {
  // final String buttonText;
  // final Color buttonColor;
  // final TextStyle textStyle;

  const CameraButtonWidget({
    super.key,
    // required this.buttonText,
    // required this.buttonColor,
    // required this.textStyle,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CameraButtonWidgetState createState() => _CameraButtonWidgetState();
}

class _CameraButtonWidgetState extends State<CameraButtonWidget> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  String? imagePath; // Path to store the captured image

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize the camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.max,
    );

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
        builder: (context) => CameraPreviewScreen(
          initFuture:
              _initializeControllerFuture!, // ส่ง future แทนการ init ใหม่
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
    return GestureDetector(
      onTap: () => openCamera(context),
      child: Column(
        children: [
          // Display image if available, otherwise show the camera icon placeholder
          Container(
            // margin: EdgeInsets.all(20),
            height: screenWidth / 2,
            width: double.infinity,
            color:
                Colors.grey[300], // Background color before image is captured
            child: imagePath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 50,
                        color: Colors.black54,
                      ),
                      Text(
                        "gobal.camera_button.button".tr(),
                        style: Styles.black24(context),
                      )
                    ],
                  )
                : Image.file(
                    height: 200,
                    width: 200,
                    File(imagePath!), // Display the captured image here
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Screen to display the camera preview and allow the user to take a picture
// class CameraPreviewScreen extends StatelessWidget {
//   final CameraController cameraController;
//   final Function(String) onImageCaptured;

//   const CameraPreviewScreen({
//     super.key,
//     required this.cameraController,
//     required this.onImageCaptured,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(70),
//         child: AppbarCustom(
//             icon: Icons.camera_alt, title: "gobal.camera_button.appbar".tr()),
//       ),
//       body: FutureBuilder<void>(
//         future: cameraController.initialize(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Stack(
//               children: [
//                 Center(
//                   child: CameraPreview(cameraController),
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: FloatingActionButton(
//                       backgroundColor: Colors.white,
//                       onPressed: () async {
//                         try {
//                           // Capture the picture
//                           final image = await cameraController.takePicture();

//                           // Pass the file path back to the previous screen
//                           onImageCaptured(image.path);

//                           // Pop the current screen after the photo is taken
//                           // ignore: use_build_context_synchronously
//                           Navigator.pop(context);
//                         } catch (e) {
//                           print(e);
//                         }
//                       },
//                       child: const Icon(
//                         Icons.camera_alt,
//                         color: Styles.primaryColorIcons,
//                         size: 40,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }

class CameraPreviewScreen extends StatelessWidget {
  final CameraController cameraController;
  final Future<void> initFuture;
  final Function(String) onImageCaptured;

  const CameraPreviewScreen({
    super.key,
    required this.cameraController,
    required this.initFuture,
    required this.onImageCaptured,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppbarCustom(
            icon: Icons.camera_alt, title: "gobal.camera_button.appbar".tr()),
      ),
      body: FutureBuilder<void>(
        future: initFuture, // ใช้ future ที่ส่งมา
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              cameraController.value.isInitialized) {
            return Stack(
              children: [
                Center(child: CameraPreview(cameraController)),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        try {
                          final image = await cameraController.takePicture();
                          onImageCaptured(image.path);
                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          debugPrint("takePicture error: $e");
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ถ่ายรูปไม่สำเร็จ')),
                            );
                          }
                        }
                      },
                      child: const Icon(Icons.camera_alt,
                          color: Styles.primaryColorIcons, size: 40),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
