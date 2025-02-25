import 'package:_12sale_app/core/components/Appbar.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

// class CameraButtonWidgetFixed extends StatefulWidget {
//   // final String buttonText;
//   // final Color buttonColor;
//   // final TextStyle textStyle;

//   const CameraButtonWidgetFixed({
//     super.key,
//     // required this.buttonText,
//     // required this.buttonColor,
//     // required this.textStyle,
//   });

//   @override
//   // ignore: library_private_types_in_public_api
//   _CameraButtonWidgetFixedState createState() =>
//       _CameraButtonWidgetFixedState();
// }

// class _CameraButtonWidgetFixedState extends State<CameraButtonWidgetFixed> {
//   late CameraController _cameraController;
//   Future<void>? _initializeControllerFuture;
//   String? imagePath; // Path to store the captured image

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   // Initialize the camera
//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final firstCamera = cameras.first;

//     _cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.max,
//     );

//     _initializeControllerFuture = _cameraController.initialize();
//   }

//   @override
//   void dispose() {
//     _cameraController
//         .dispose(); // Dispose of the camera controller to free resources
//     super.dispose();
//   }

//   Future<void> openCamera(BuildContext context) async {
//     await _initializeControllerFuture; // Wait for the camera to initialize
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => CameraPreviewScreen(
//           cameraController: _cameraController,
//           onImageCaptured: (String imagePath) {
//             setState(() {
//               this.imagePath = imagePath; // Store the image path when captured
//             });
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return GestureDetector(
//       onTap: () => openCamera(context),
//       child: Column(
//         children: [
//           // Display image if available, otherwise show the camera icon placeholder
//           Container(
//             // margin: EdgeInsets.all(20),
//             height: screenWidth / 2,
//             width: double.infinity,
//             color:
//                 Colors.grey[300], // Background color before image is captured
//             child: imagePath == null
//                 ? Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.camera_alt_outlined,
//                         size: 50,
//                         color: Colors.black54,
//                       ),
//                       Text(
//                         "gobal.camera_button.button".tr(),
//                         style: Styles.black24(context),
//                       )
//                     ],
//                   )
//                 : Image.file(
//                     height: 200,
//                     width: 200,
//                     File(imagePath!), // Display the captured image here
//                     fit: BoxFit.contain,
//                   ),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }

// Screen to display the camera preview and allow the user to take a picture
class CameraPreviewScreenFixed extends StatefulWidget {
  // final CameraController cameraController;
  final Function(String) onImageCaptured;

  const CameraPreviewScreenFixed({
    super.key,
    // required this.cameraController,
    required this.onImageCaptured,
  });

  @override
  State<CameraPreviewScreenFixed> createState() =>
      _CameraPreviewScreenFixedState();
}

class _CameraPreviewScreenFixedState extends State<CameraPreviewScreenFixed>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // void _handleScaleStart(ScaleStartDetails details) {
  //   _baseScale = _currentScale;
  // }

  // void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
  //   if (controller == null) {
  //     return;
  //   }

  //   final CameraController cameraController = controller!;

  //   final Offset offset = Offset(
  //     details.localPosition.dx / constraints.maxWidth,
  //     details.localPosition.dy / constraints.maxHeight,
  //   );
  //   cameraController.setExposurePoint(offset);
  //   cameraController.setFocusPoint(offset);
  // }

  // Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
  //   // When there are not exactly two fingers on screen don't scale
  //   if (controller == null || _pointers != 2) {
  //     return;
  //   }

  //   _currentScale = (_baseScale * details.scale)
  //       .clamp(_minAvailableZoom, _maxAvailableZoom);

  //   await controller!.setZoomLevel(_currentScale);
  // }

  // Future<void> _initializeCameraController(
  //   CameraDescription cameraDescription) async {
  // final CameraController cameraController = CameraController(
  //   cameraDescription,
  //   kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
  //   enableAudio: fla,
  //   imageFormatGroup: ImageFormatGroup.jpeg,
  // );

  // controller = cameraController;

  // // If the controller is updated then update the UI.
  // cameraController.addListener(() {
  //   if (mounted) {
  //     setState(() {});
  //   }
  //   if (cameraController.value.hasError) {
  //     print(
  //         'Camera error ${cameraController.value.errorDescription}');
  //   }
  // });
  // @override
  // void initState() {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   super.initState();
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(cameraController.description);
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    controller = cameraController;
    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      // Camera camera = Camera.open();
      // final cameras = await availableCameras();
      // await onNewCameraSelected(cameras.first);
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb
            ? <Future<Object?>>[
                cameraController.getMinExposureOffset().then(
                    (double value) => _minAvailableExposureOffset = value),
                cameraController
                    .getMaxExposureOffset()
                    .then((double value) => _maxAvailableExposureOffset = value)
              ]
            : <Future<Object?>>[],
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          print('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          print('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          print('Camera access is restricted.');
        case 'AudioAccessDenied':
          print('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          print('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          print('Audio access is restricted.');
        default:
          print(e);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            icon: Icons.camera_alt, title: "gobal.camera_button.appbar".tr()),
      ),
      // body: FutureBuilder<void>(
      //   future: widget.cameraController.initialize(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.done) {
      //       return Stack(
      //         children: [
      //           Center(
      //             child: CameraPreview(widget.cameraController),
      //           ),
      //           Align(
      //             alignment: Alignment.bottomCenter,
      //             child: Padding(
      //               padding: const EdgeInsets.all(20.0),
      //               child: FloatingActionButton(
      //                 onPressed: () async {
      //                   try {
      //                     // Capture the picture
      //                     final image =
      //                         await widget.cameraController.takePicture();
      //                     // Pass the file path back to the previous screen
      //                     widget.onImageCaptured(image.path);
      //                     // Pop the current screen after the photo is taken
      //                     // ignore: use_build_context_synchronously
      //                     Navigator.pop(context);
      //                     // widget.cameraController.dispose();
      //                   } catch (e) {
      //                     print(e);
      //                   }
      //                 },
      //                 child: const Icon(Icons.camera_alt),
      //               ),
      //             ),
      //           ),
      //         ],
      //       );
      //     } else {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //   },
      // ),
      body: Stack(
        children: [
          (controller != null)
              ? Center(
                  child: CameraPreview(controller!),
                )
              : SizedBox()
        ],
      ),
      //   body: Column(
      //     children: [
      //       Container(
      //         child: Listener(
      //           onPointerDown: (_) => _pointers++,
      //           onPointerUp: (_) => _pointers--,
      //           child: CameraPreview(
      //             widget.cameraController,
      //             child: LayoutBuilder(builder:
      //                 (BuildContext context, BoxConstraints constraints) {
      //               return GestureDetector(
      //                 behavior: HitTestBehavior.opaque,
      //                 onScaleStart: _handleScaleStart,
      //                 onScaleUpdate: _handleScaleUpdate,
      //                 onTapDown: (TapDownDetails details) =>
      //                     onViewFinderTap(details, constraints),
      //               );
      //             }),
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
    );
  }
}
