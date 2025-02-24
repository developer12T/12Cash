import 'dart:io';
import 'package:_12sale_app/core/components/button/CameraButton.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraExpand extends StatefulWidget {
  String? imagePath;
  final IconData icon;
  final String label;
  final TextStyle? labelStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Function(String imagePath)? onImageSelected; // Callback for image path
  bool checkNetwork;
  CameraExpand({
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
  _CameraExpandState createState() => _CameraExpandState();
}

class _CameraExpandState extends State<CameraExpand>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  // late CameraController _cameraController;
  // String? imagePath;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

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

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
    initPlatformState();
    // _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
      fps: 30,
    );
    controller = cameraController;
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

  Future<void> openCamera(BuildContext context) async {
    try {
      // Dispose of the existing controller if it's already initialized
      if (controller != null && controller!.value.isInitialized) {
        await controller!.dispose();
      }

      // Get the available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        showInSnackBar('No cameras available');
        return;
      }

      // Initialize the camera with the first available camera
      final firstCamera = cameras.first;
      await _initializeCameraController(firstCamera);

      // Navigate to the camera preview screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CameraPreviewScreen(
            // deviceData: _deviceData,
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
            child: widget.imagePath == null
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
                    File(widget.imagePath!), // Display the captured image here
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
