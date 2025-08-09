import 'dart:async';
import 'dart:io';
import 'package:_12sale_app/core/page/announce/Announce.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/LoginScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/RefundFilter.dart';
import 'package:_12sale_app/data/models/search/RouteVisitFilterLocal.dart';
import 'package:_12sale_app/data/models/search/StoreFilterLocal.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/localNotification.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:_12sale_app/data/service/requestPremission.dart';
import 'package:_12sale_app/data/service/sockertService.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:intl/date_symbol_data_local.dart'; // For date localization
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  try {
    // tz.initializeTimeZones();
    // // Configure the HTTP client to use a proxy
    // final client = HttpClient()
    //   ..findProxy = (url) {
    //     return "PROXY proxy.example.com:8080"; // Replace with your proxy server
    //   }
    //   ..badCertificateCallback =
    //       (X509Certificate cert, String host, int port) =>
    //           true; // Allow bad certificates (optional).

    // // Use the client with the http package
    // final ioClient = http.IOClient(client);
    // final response = await ioClient.get(Uri.parse('https://api.example.com'));

    // print('Response: ${response.body}');
    // Initialize the locale data for Thai lanqguage
    // Ensure the app is always in portrait mode
    WidgetsFlutterBinding.ensureInitialized();

    // bool isDev = await checkDevMode();
    // if (isDev) {
    //   runApp(DevOptionWarningApp());
    //   return;
    // }

    await Upgrader.clearSavedSettings();

    await availableCameras();
    await EasyLocalization.ensureInitialized();
    await PackageInfo.fromPlatform();
    // Initialize the notifications
    await initializeNotifications();
    await requestAllPermissions();

    await initializeDateFormatting('th', null);
    await dotenv.load(fileName: ".env");
    await ScreenUtil.ensureScreenSize();
    // Hide status bar + navigation bar for true fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

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
    // FlutterForegroundTask.initCommunicationPort();
    await LocationService().initialize();
    SocketService().connect(); // Singleton ใช้แบบนี้
  } on CameraException catch (e) {
    _logError(e.code, e.description);
  }

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
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => RouteVisitFilterLocal()),
              ChangeNotifierProvider(create: (_) => StoreLocal()),
              ChangeNotifierProvider(create: (_) => RefundfilterLocal()),
              ChangeNotifierProvider(create: (_) => SocketService()),
            ],
            child: MyApp(),
          ),
        ),
      ),
    );
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  });
}

Future<bool> isDeveloperModeOn() async {
  const platform = MethodChannel('com.onetwotrading.onetwocashapp/dev_mode');
  try {
    final bool result = await platform.invokeMethod('isDeveloperMode');
    return result;
  } on PlatformException catch (e) {
    print("Failed to get developer mode: '${e.message}'.");
    return false;
  }
}

Future<bool> checkDevMode() async {
  if (!Platform.isAndroid) return false;

  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  // 1. Emulator เช็คจาก brand หรือ product
  bool isEmulator = androidInfo.isPhysicalDevice == false ||
      androidInfo.brand.toLowerCase() == 'generic' ||
      androidInfo.product.toLowerCase().contains('sdk');

  // 2. เช็ค tags (เครื่อง dev ส่วนมากจะเป็น 'test-keys')
  bool isTestKeys = androidInfo.tags?.contains('test-keys') ?? false;

  // 3. เช็ค developer mode
  bool isDeveloperMode = await isDeveloperModeOn();

  print('isEmulator: $isEmulator');
  print('isTestKeys: $isTestKeys');
  print('isDeveloperMode: $isDeveloperMode');

  // Return ตามต้องการ เช่น ถ้าเครื่อง dev หรือ emulator หรือเปิด developer mode
  return isEmulator || isTestKeys || isDeveloperMode;
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
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
    FlutterForegroundTask.updateService(
        notificationTitle: 'Hello MyTaskHandler :)',
        notificationText: 'count: $_count');

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
  late Upgrader _upgrader;
  // This widget is the root of your application.
  final ValueNotifier<Object?> _taskDataListenable = ValueNotifier(null);
  // late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;

  final LocationService locationService = LocationService();
  double latitude = 00.00;
  double longitude = 00.00;

  DateTime? _lastVersionCheck;
  Duration versionCheckCooldown = Duration(minutes: 5);

  // Future<void> _requestPermissions() async {
  //   // Android 13+, you need to allow notification permission to display foreground service notification.
  //   //
  //   // iOS: If you need notification, ask for permission.
  //   final NotificationPermission notificationPermission =
  //       await FlutterForegroundTask.checkNotificationPermission();
  //   if (notificationPermission != NotificationPermission.granted) {
  //     await FlutterForegroundTask.requestNotificationPermission();
  //   }

  //   if (Platform.isAndroid) {
  //     // Android 12+, there are restrictions on starting a foreground service.
  //     //
  //     // To restart the service on device reboot or unexpected problem, you need to allow below permission.
  //     if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
  //       // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
  //       await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  //     }

  //     // Use this utility only if you provide services that require long-term survival,
  //     // such as exact alarm service, healthcare service, or Bluetooth communication.
  //     //
  //     // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
  //     // Using this permission may make app distribution difficult due to Google policy.
  //     if (!await FlutterForegroundTask.canScheduleExactAlarms) {
  //       // When you call this function, will be gone to the settings page.
  //       // So you need to explain to the user why set it.
  //       await FlutterForegroundTask.openAlarmsAndRemindersSettings();
  //     }
  //   }
  // }

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
    // _initializeCamera();
    // Add a callback to receive data sent from the TaskHandler.
    // FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Request permissions and initialize the service.

    //   _initService();
    //   _startService();
    // });
  }

  void checkForUpdateIfNeeded(BuildContext context) async {
    final now = DateTime.now();
    if (_lastVersionCheck == null ||
        now.difference(_lastVersionCheck!) > versionCheckCooldown) {
      _lastVersionCheck = now;

      final upgrader = Upgrader();
      await upgrader.initialize();
      if (upgrader.shouldDisplayUpgrade()) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => MyUpgradeAlert(upgrader: upgrader),
        );
      }
    }
  }

  Future<void> _initUpgrade() async {
    await _upgrader.initialize();
    // ถ้าไม่มีอัปเดต -> preload user data
    if (!_upgrader.shouldDisplayUpgrade()) {}
    // ถ้ามีอัปเดต MyUpgradeAlert จะ popup เอง และบล็อก user ไว้
    // ไม่ต้อง preload user data ตอนนี้!
  }

  @override
  void dispose() {
    // Remove a callback to receive data sent from the TaskHandler.
    // FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    // videoPlayerController.dispose(); // Dispose of VideoPlayerController
    // _taskDataListenable.dispose();
    // _cameraController
    //     .dispose(); // Dispose of the camera controller to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base screen size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GlobalLoaderOverlay(
          overlayWidgetBuilder: (dynamic progress) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Styles.white,
                ),
                Text(
                  "กรุณารอสักครู่...",
                  style: Styles.white18(context),
                ),
                // SizedBox(
                //   height: 50,
                // ),
                if (progress != null) Text(progress)
              ],
            );
          },
          overlayColor: Styles.primaryColor.withOpacity(0.8),
          child: Listener(
            onPointerDown: (_) => checkForUpdateIfNeeded(context),
            behavior: HitTestBehavior.translucent,
            child: MaterialApp(
              routes: {
                '/': (context) => AuthCheck(),
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
              // localizationsDelegates: [
              //   GlobalWidgetsLocalizations.delegate,
              //   GlobalMaterialLocalizations.delegate,
              //   MonthYearPickerLocalizations.delegate,
              // ],
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              navigatorObservers: [
                routeObserver
              ], // Register RouteObserver here
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
                textTheme:
                    Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
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
            ),
          ),
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
  const AuthCheck({Key? key}) : super(key: key);

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> with WidgetsBindingObserver {
  bool userAvailable = false;
  late SharedPreferences sharedPreferences;
  late Upgrader _upgrader;
  bool _checkedUpgrade = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _upgrader = Upgrader(debugLogging: true);
    // ตรวจสอบอัปเดตครั้งแรก
    _initUpgrade();
  }

  Future<void> _initUpgrade() async {
    await _upgrader.initialize();
    print('shouldDisplayUpgrade: ${_upgrader.shouldDisplayUpgrade()}');
    // ถ้าไม่มีอัปเดต -> preload user data
    if (!_upgrader.shouldDisplayUpgrade()) {
      setState(() {
        _checkedUpgrade = true;
      });
      getUserData();
    }
    // ถ้ามีอัปเดต MyUpgradeAlert จะ popup เอง และบล็อก user ไว้
    // ไม่ต้อง preload user data ตอนนี้!
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _upgrader.initialize();
      if (!_upgrader.shouldDisplayUpgrade()) {
        setState(() {
          _checkedUpgrade = true;
        });
        getUserData();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> getUserData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    // Check expiry
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day + 1); // 00:00 ของวันถัดไป
    int expiryTimestamp = tomorrow.millisecondsSinceEpoch;

    await sharedPreferences.setInt('dataExpiry', expiryTimestamp);
    if (expiryTimestamp != null) {
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      if (currentTimestamp > expiryTimestamp) {
        // Data has expired, clear it
        sharedPreferences.clear();
        print('User data has expired');
        // ปิดแอปทันที
        exit(0); // <-- เพิ่มบรรทัดนี้
        // return null; // ไม่จำเป็นต้อง return แล้ว
      } else {
        setState(() {
          User.username = sharedPreferences.getString('username') ?? "";
          User.firstName = sharedPreferences.getString('firstName') ?? "";
          User.surName = sharedPreferences.getString('surName') ?? "";
          User.fullName = sharedPreferences.getString('fullName') ?? "";
          User.salePayer = sharedPreferences.getString('salePayer') ?? "";
          User.tel = sharedPreferences.getString('tel') ?? "";
          User.area = sharedPreferences.getString('area') ?? "";
          User.typeTruck = sharedPreferences.getString('typeTruck') ?? "";
          User.saleCode = sharedPreferences.getString('saleCode') ?? "";
          User.zone = sharedPreferences.getString('zone') ?? "";
          User.warehouse = sharedPreferences.getString('warehouse') ?? "";
          User.role = sharedPreferences.getString('role') ?? "";
          User.token = sharedPreferences.getString('token') ?? "";
          userAvailable = true;
        });
        Timer(
          Duration(seconds: 3),
          () {
            if (!mounted) return; // เช็คก่อน Navigator
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  index: 0,
                ),
              ),
            );
          },
        );
      }
    } else {
      Timer(
        Duration(seconds: 3),
        () {
          // ไม่มีข้อมูล user -> ปิดแอปเลย
          exit(0); // <-- เพิ่มตรงนี้
          // หรือจะไป Login ก็ได้ แล้วแต่ต้องการ
          // if (!mounted) return;
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => LoginScreen(),
          //   ),
          // );
        },
      );
    }
  }

  // Future<void> getUserData() async {
  //   sharedPreferences = await SharedPreferences.getInstance();
  //   // Check expiry
  //   int? expiryTimestamp = sharedPreferences.getInt('dataExpiry');
  //   if (expiryTimestamp != null) {
  //     int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
  //     if (currentTimestamp > expiryTimestamp) {
  //       // Data has expired, clear it
  //       sharedPreferences.clear();
  //       print('User data has expired');
  //       return null;
  //     } else {
  //       setState(() {
  //         User.username = sharedPreferences.getString('username') ?? "";
  //         User.firstName = sharedPreferences.getString('firstName') ?? "";
  //         User.surName = sharedPreferences.getString('surName') ?? "";
  //         User.fullName = sharedPreferences.getString('fullName') ?? "";
  //         User.salePayer = sharedPreferences.getString('salePayer') ?? "";
  //         User.tel = sharedPreferences.getString('tel') ?? "";
  //         User.area = sharedPreferences.getString('area') ?? "";
  //         User.typeTruck = sharedPreferences.getString('typeTruck') ?? "";
  //         User.saleCode = sharedPreferences.getString('saleCode') ?? "";
  //         User.zone = sharedPreferences.getString('zone') ?? "";
  //         User.warehouse = sharedPreferences.getString('warehouse') ?? "";
  //         User.role = sharedPreferences.getString('role') ?? "";
  //         User.token = sharedPreferences.getString('token') ?? "";
  //         userAvailable = true;
  //       });
  //       Timer(
  //         Duration(seconds: 3),
  //         () {
  //           if (!mounted) return; // เช็คก่อน Navigator
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => HomeScreen(
  //                 index: 0,
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     }
  //   } else {
  //     Timer(
  //       Duration(seconds: 3),
  //       () {
  //         if (!mounted) return; // เช็คก่อน Navigator
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => LoginScreen(),
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // ... ใช้ MyUpgradeAlert หรืออะไรก็ได้ตามปกติ
    // แต่ที่สำคัญ: ต้องมี didChangeAppLifecycleState
    // เพื่อกัน user กลับเข้ามาแบบไม่อัปเดต!
    return MyUpgradeAlert(
      upgrader: _upgrader,
      child: buildSplash(context, MediaQuery.of(context).size.width),
    );
  }

  Widget buildSplash(BuildContext context, double screenWidth) {
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
              ).animate().shake(duration: 600.ms),
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

class MyUpgradeAlert extends UpgradeAlert {
  MyUpgradeAlert({
    Key? key,
    Upgrader? upgrader,
    Widget? child,
  }) : super(
          key: key,
          upgrader: upgrader,
          child: child,
          barrierDismissible: false,
          showIgnore: false,
          showLater: false,
        );

  @override
  MyUpgradeAlertState createState() => MyUpgradeAlertState();
}

class MyUpgradeAlertState extends UpgradeAlertState {
  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          key: key,
          title: Text(
            '🛠️⬆️ พบอัปเดตใหม่',
            style: Styles.headerBlack24(context),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: Styles.black18(context),
                ),
                if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    releaseNotes,
                    style: Styles.black18(context),
                  ),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            // ถ้าอยากมีปุ่มข้าม/ภายหลังให้เปิด comment ด้านล่าง
            // if (widget.showLater)
            //   TextButton(
            //     child: Text(messages.laterButtonLabel),
            //     onPressed: () {
            //       onUserLater(context, true);
            //     },
            //   ),
            // if (widget.showIgnore)
            //   TextButton(
            //     child: Text(messages.ignoreButtonLabel),
            //     onPressed: () {
            //       onUserIgnored(context, true);
            //     },
            //   ),
            TextButton(
              child: Text(
                "อัปเดต",
                style: Styles.black18(context),
              ),
              onPressed: () {
                // เรียก onUserUpdated ของ Upgrader เพื่อ handle เปิด Store
                onUserUpdated(context, !widget.upgrader.blocked());
              },
            ),
          ],
        );
      },
    );
  }
}

class DeveloperOptionsUtil {
  static const platform =
      MethodChannel('com.onetwotrading.onetwocashapp/dev_options');

  static Future<bool> isDeveloperModeEnabled() async {
    try {
      final bool isEnabled =
          await platform.invokeMethod('isDeveloperModeEnabled');
      return isEnabled;
    } on PlatformException {
      return false;
    }
  }
}

class DevOptionWarningApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AlertDialog(
            title: Text("แจ้งเตือน", style: Styles.black18(context)),
            content: Text(
                "กรุณาปิด Developer Options หรือ USB Debugging ก่อนใช้งานแอปนี้",
                style: Styles.black18(context)),
            actions: [
              TextButton(
                child: Text(
                  "ปิดแอป",
                  style: Styles.black18(context),
                ),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
