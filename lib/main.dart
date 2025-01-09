import 'dart:async';
import 'dart:io';

import 'package:_12sale_app/core/components/Gird.dart';
import 'package:_12sale_app/core/page/CustomBottomBar.dart';
import 'package:_12sale_app/core/page/NotificationScreen.dart';
import 'package:_12sale_app/core/page/Ractangle3D.dart';
import 'package:_12sale_app/core/page/Square3D.dart';
import 'package:_12sale_app/core/page/announce/Announce.dart';
import 'package:_12sale_app/core/page/printer/BluetoothPrinterScreen.dart';
import 'package:_12sale_app/core/page/printer/PrinterBluetoothScreen.dart';
import 'package:_12sale_app/core/page/printer/TestPrint.dart';
import 'package:_12sale_app/core/page/printer/TestPrinterScreen.dart';
import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/LoginScreen.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/page/route/OrderScreen.dart';
import 'package:_12sale_app/core/page/route/TestGooglemap.dart';
import 'package:_12sale_app/core/page/route/TossAddToCartScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/localNotification.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:_12sale_app/data/service/requestPremission.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // For date localization
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  // Initialize the locale data for Thai language
  // Ensure the app is always in portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await PackageInfo.fromPlatform();

  // Initialize the notifications
  await initializeNotifications();
  await requestAllPermissions();
  await initializeDateFormatting('th', null);
  await dotenv.load(fileName: ".env");
  await ScreenUtil.ensureScreenSize();
  // Initialize the background service
  // final hasPermissions = await FlutterBackground.initialize(
  //   androidConfig: const FlutterBackgroundAndroidConfig(
  //     notificationTitle: "Background Service",
  //     notificationText: "This app is running in the background.",
  //     notificationImportance: AndroidNotificationImportance.high,
  //     enableWifiLock: true,
  //   ),
  // );
  // if (!hasPermissions) {
  //   print("Background permissions not granted");
  // }
  // Initialize port for communication between TaskHandler and UI.
  FlutterForegroundTask.initCommunicationPort();
  await LocationService().initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      KeyboardVisibilityProvider(
        child: EasyLocalization(
            startLocale: Locale("th", "TH"), // When need to set default
            path: 'assets/locales',
            fallbackLocale: Locale('th', 'TH'),
            supportedLocales: [Locale('en', 'US'), Locale('th', 'TH')],
            saveLocale: true,
            child: MyApp()),
      ),
    );
  });
}

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  static const String incrementCountCommand = 'incrementCount';
  int _count = 0;

  void _incrementCount() {
    _count++;

    // Update notification content.
    // FlutterForegroundTask.updateService(
    //     notificationTitle: 'Hello MyTaskHandler :)',
    //     notificationText: 'count: $_count');

    // Send data to main isolate.
    FlutterForegroundTask.sendDataToMain(_count);
  }

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print('onStart(starter: ${starter.name})');
    _incrementCount();
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    _incrementCount();
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print('onDestroy');
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');
    if (data == incrementCountCommand) {
      _incrementCount();
    }
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    print('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final ValueNotifier<Object?> _taskDataListenable = ValueNotifier(null);
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;

  final LocationService locationService = LocationService();
  double latitude = 00.00;
  double longitude = 00.00;

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _cameraController.initialize();
  }

  Future<void> _requestPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Use this utility only if you provide services that require long-term survival,
      // such as exact alarm service, healthcare service, or Bluetooth communication.
      //
      // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // Using this permission may make app distribution difficult due to Google policy.
      if (!await FlutterForegroundTask.canScheduleExactAlarms) {
        // When you call this function, will be gone to the settings page.
        // So you need to explain to the user why set it.
        await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      }
    }
  }

  void _initService() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription:
            'This notification appears when the foreground service is running.',
        onlyAlertOnce: true,
        playSound: true,
        priority: NotificationPriority.HIGH,
        showBadge: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(10000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<ServiceRequestResult> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        notificationButtons: [
          const NotificationButton(id: 'btn_hello', text: 'hello'),
        ],
        notificationInitialRoute: '/',
        callback: startCallback,
      );
    }
  }

  Future<ServiceRequestResult> _stopService() {
    return FlutterForegroundTask.stopService();
  }

  Future<void> fetchLocation() async {
    try {
      // Initialize the location service
      await locationService.initialize();

      // Get latitude and longitude
      double? lat = await locationService.getLatitude();
      double? lon = await locationService.getLongitude();

      setState(() {
        latitude = lat ?? 00.00;
        longitude = lon ?? 00.00;
      });
      print("${latitude}, ${longitude}");
    } catch (e) {
      if (mounted) {
        setState(() {
          latitude = 00.00;
          longitude = 00.00;
        });
      }
      print("Error: $e");
    }
  }

  void _onReceiveTaskData(Object data) {
    print('onReceiveTaskData: $data');
    fetchLocation();
    print("latitude: ${latitude} longitude: ${longitude}");
    _taskDataListenable.value = data;
  }

  void _incrementCount() {
    FlutterForegroundTask.sendDataToTask(MyTaskHandler.incrementCountCommand);
  }

  @override
  void initState() {
    super.initState();
    // Initialize the camera
    _initializeCamera();
    // Add a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request permissions and initialize the service.
      // _requestPermissions();
      _initService();
      // _startService();
    });
  }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    _taskDataListenable.dispose();
    _cameraController
        .dispose(); // Dispose of the camera controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base screen size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          routes: {
            // '/': (context) => const HomeScreen(
            //       index: 0,
            //     ),
            '/': (context) => const AuthCheck(),
            '/route': (context) => const HomeScreen(
                  index: 1,
                ),
            '/store': (context) => const HomeScreen(
                  index: 2,
                ),
            '/manage': (context) => const HomeScreen(
                  index: 3,
                ),
            '/announce': (context) => const Announce(),
          },
          initialRoute: '/',
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          navigatorObservers: [routeObserver], // Register RouteObserver here
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            // splashColor: Colors.transparent,
            // highlightColor: Colors.transparent,
            // hoverColor: Colors.transparent,
            // iconTheme: IconThemeData(
            //   color: Colors.transparent,
            //   opacity: 0.0,
            // ),
            primarySwatch: Colors.blue,
            extensions: const [
              SkeletonizerConfigData.dark(),
            ],
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),

          // home: PolylineWithLabels(),
          // home: SettingsScreen(),
          // home: const LoginScreen(),
          // home: const HomeScreen(
          //   index: 0,
          // ),
          // home: NotificationScreen(),
          // home: HomeScreen2(),
          // home: CustomBottomNavBar(),
          // home: BluetoothPrinterScreen4(),
          // home: AddToCartAnimationPage(),
          // home: Column(
          //   children: [
          //     Expanded(child: _buildCommunicationDataText()),
          //     _buildServiceControlButtons(),
          //   ],
          // ),
        );
      },
    );
  }

  Widget _buildCommunicationDataText() {
    return ValueListenableBuilder(
      valueListenable: _taskDataListenable,
      builder: (context, data, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You received data from TaskHandler:'),
              Text('$data', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceControlButtons() {
    buttonBuilder(String text, {VoidCallback? onPressed}) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buttonBuilder('start service', onPressed: _startService),
          buttonBuilder('stop service', onPressed: _stopService),
          buttonBuilder('increment count', onPressed: _incrementCount),
        ],
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    tranformScreen();
  }

  Future<void> tranformScreen() async {
    Timer(
      Duration(seconds: 5),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthCheck(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation/loading2.json',
              // Use the device frame rate (up to 120FPS)
              frameRate: FrameRate.max,
            ),
          ],
        ),
      ),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    // Check expiry
    int? expiryTimestamp = sharedPreferences.getInt('dataExpiry');
    if (expiryTimestamp != null) {
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      if (currentTimestamp > expiryTimestamp) {
        // Data has expired, clear it
        sharedPreferences.clear();
        print('User data has expired');
        return null;
      } else {
        setState(() {
          User.username = sharedPreferences.getString('username')!;
          User.firstName = sharedPreferences.getString('firstName')!;
          User.surName = sharedPreferences.getString('surName')!;
          User.fullName = sharedPreferences.getString('fullName')!;
          User.salePayer = sharedPreferences.getString('salePayer')!;
          User.tel = sharedPreferences.getString('tel')!;
          User.area = sharedPreferences.getString('area')!;
          User.zone = sharedPreferences.getString('zone')!;
          User.warehouse = sharedPreferences.getString('warehouse')!;
          User.role = sharedPreferences.getString('role')!;
          User.token = sharedPreferences.getString('token')!;
          userAvailable = true;
        });
        Timer(
          Duration(seconds: 3),
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                index: 0,
              ),
            ),
          ),
        );
      }
    } else {
      Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: screenWidth / 2,
              height: screenWidth / 2,
              // color: Colors.red,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo12.png'),
                  ),
                ),
              ),
            ),
            // CircularProgressIndicator(
            //   color: Styles.primaryColor,
            // ),
            // Text(
            //   '12Cash ยินดีต้อนรับ...',
            //   style: Styles.black18(context),
            // )
            // SizedBox(
            //   height: 15,
            // ),
            // Lottie.asset(
            //   width: screenWidth / 5,
            //   height: screenWidth / 5,
            //   'assets/animation/loading2.json',
            //   frameRate: FrameRate.max,
            // ),
          ],
        ),
      ),
    );
  }
}
