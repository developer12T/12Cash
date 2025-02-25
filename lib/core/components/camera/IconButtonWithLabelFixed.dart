import 'dart:io';
import 'package:_12sale_app/core/components/camera/CameraButton%20copy.dart';
import 'package:_12sale_app/core/components/camera/CameraPreviewScreen.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IconButtonWithLabelFixed extends StatefulWidget {
  String? imagePath;
  final IconData icon;
  final String label;
  final TextStyle? labelStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Function(String imagePath)? onImageSelected; // Callback for image path
  bool checkNetwork;
  IconButtonWithLabelFixed({
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
  _IconButtonWithLabelFixedState createState() =>
      _IconButtonWithLabelFixedState();
}

class _IconButtonWithLabelFixedState extends State<IconButtonWithLabelFixed>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  CameraController? controller;
  // late CameraController _cameraController;
  // String? imagePath;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();

    super.initState();
    initPlatformState();
    // _initializeCamera();
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        // deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
            _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS =>
            _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          // TargetPlatform.linux =>
          //   _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          // TargetPlatform.windows =>
          //   _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          // TargetPlatform.macOS =>
          //   _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          // TargetPlatform.fuchsia => <String, dynamic>{
          //     'Error:': 'Fuchsia platform isn\'t supported'
          //   },
          // TODO: Handle this case.
          TargetPlatform.fuchsia => throw UnimplementedError(),
          // TODO: Handle this case.
          TargetPlatform.linux => throw UnimplementedError(),
          // TODO: Handle this case.
          TargetPlatform.macOS => throw UnimplementedError(),
          // TODO: Handle this case.
          TargetPlatform.windows => throw UnimplementedError(),
        };
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
    print("Device Mobile :${deviceData['brand']}");
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'modelName': data.modelName,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'isiOSAppOnMac': data.isiOSAppOnMac,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      'isLowRamDevice': build.isLowRamDevice,
    };
  }

  // Future<void> _initializeCamera() async {
  //   try {
  //     final cameras = await availableCameras();
  //     if (cameras.isNotEmpty) {
  //       final firstCamera = cameras.first;
  //       _cameraController = CameraController(
  //         firstCamera,
  //         ResolutionPreset.max,
  //         fps: 30,
  //         enableAudio: false,
  //         imageFormatGroup: ImageFormatGroup.jpeg,
  //       );
  //       _initializeControllerFuture = _cameraController.initialize();
  //       await _initializeControllerFuture;
  //     } else {
  //       print("No cameras available");
  //     }
  //   } catch (e) {
  //     print("Error initializing camera: $e");
  //   }
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   final CameraController? cameraController = controller;

  //   // App state changed before we got the chance to initialize.
  //   if (cameraController == null || !cameraController.value.isInitialized) {
  //     return;
  //   }

  //   if (state == AppLifecycleState.inactive) {
  //     cameraController.dispose();
  //   } else if (state == AppLifecycleState.resumed) {
  //     _initializeCameraController(cameraController.description);
  //   }
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (!controller!.value.isInitialized) {
        _initializeCameraController(controller!.description);
      }
    }
  }

  Future<void> _initializeCameraController(
      CameraDescription cameraDescription) async {
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      // enableAudio: false,
      // imageFormatGroup: ImageFormatGroup.yuv420,
      fps: 30,
    );
    controller = cameraController;
    // controller.s
    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();

      // await cameraController
      //     .lockCaptureOrientation(DeviceOrientation.portraitUp);
      // Lock the camera orientation to portrait
      // await cameraController
      //     .lockCaptureOrientation(DeviceOrientation.portraitUp);
      // await cameraController.lockCaptureOrientation(DeviceOrientation.)
      // Ensure portrait orientation
      // await cameraController
      //     .lockCaptureOrientation(DeviceOrientation.landscapeRight);
      // await Future.wait(<Future<Object?>>[
      //   // The exposure mode is currently not supported on the web.
      //   ...!kIsWeb
      //       ? <Future<Object?>>[
      //           cameraController.getMinExposureOffset().then(
      //               (double value) => _minAvailableExposureOffset = value),
      //           cameraController
      //               .getMaxExposureOffset()
      //               .then((double value) => _maxAvailableExposureOffset = value)
      //         ]
      //       : <Future<Object?>>[],
      //   cameraController
      //       .getMaxZoomLevel()
      //       .then((double value) => _maxAvailableZoom = value),
      //   cameraController
      //       .getMinZoomLevel()
      //       .then((double value) => _minAvailableZoom = value),
      // ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          _showCameraException(e);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      return controller!.setDescription(cameraDescription);
    } else {
      return _initializeCameraController(cameraDescription);
    }
  }

  // Future<void> openCamera(BuildContext context) async {
  //   final cameras = await availableCameras();
  //   await onNewCameraSelected(cameras.first);
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => CameraPreviewScreen(
  //         cameraController: controller!,
  //         onImageCaptured: (
  //           String imagePath,
  //         ) {
  //           setState(() {
  //             widget.imagePath = imagePath;
  //           });
  //           // Notify parent widget via callback
  //           if (widget.onImageSelected != null) {
  //             widget.onImageSelected!(imagePath);
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }

  Future<void> openCamera(BuildContext context) async {
    try {
      // Dispose of the existing controller if it's already initialized
      if (controller != null && controller!.value.isInitialized) {
        await controller!.dispose();
      }

      // Get the available cameras
      var cameras = await availableCameras();
      // cameras.first.sensorOrientation = 270;

      final camera = cameras.first;
      print('Camera sensor orientation: ${camera.sensorOrientation}');
      print('Lens facing: ${camera.lensDirection}');
      if (cameras.isEmpty) {
        showInSnackBar('No cameras available');
        return;
      }

      // Initialize the camera with the first available camera
      // Lower FPS range
      final firstCamera = cameras.first;

      cameras.clear();

      await _initializeCameraController(firstCamera);

      // Navigate to the camera preview screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CameraPreviewScreen(
            deviceData: _deviceData,
            cameraController: controller!,
            onImageCaptured: (String imagePath) {
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
    } catch (e) {
      showInSnackBar('Error opening camera: $e');
    }
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
