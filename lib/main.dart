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
import 'package:intl/date_symbol_data_local.dart';
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
    WidgetsFlutterBinding.ensureInitialized();

    await Upgrader.clearSavedSettings();
    await availableCameras();
    await EasyLocalization.ensureInitialized();
    await PackageInfo.fromPlatform();
    await initializeNotifications();
    await requestAllPermissions();
    await initializeDateFormatting('th', null);
    await dotenv.load(fileName: ".env");
    await ScreenUtil.ensureScreenSize();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    await LocationService().initialize();
    SocketService().connect();
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
          startLocale: const Locale("th", "TH"),
          path: 'assets/locales',
          fallbackLocale: const Locale('th', 'TH'),
          supportedLocales: const [Locale('en', 'US'), Locale('th', 'TH')],
          saveLocale: true,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => RouteVisitFilterLocal()),
              ChangeNotifierProvider(create: (_) => StoreLocal()),
              ChangeNotifierProvider(create: (_) => RefundfilterLocal()),
              ChangeNotifierProvider(create: (_) => SocketService()),
            ],
            child: const MyApp(),
          ),
        ),
      ),
    );
  });
}

void _logError(String code, String? message) {
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  static const String incrementCountCommand = 'incrementCount';
  int _count = 0;

  void _incrementCount() {
    _count++;
    FlutterForegroundTask.updateService(
        notificationTitle: 'Hello MyTaskHandler :)',
        notificationText: 'count: $_count');
    FlutterForegroundTask.sendDataToMain(_count);
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _incrementCount();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _incrementCount();
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  @override
  void onReceiveData(Object data) {
    if (data == incrementCountCommand) {
      _incrementCount();
    }
  }

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {}

  @override
  void onNotificationDismissed() {}
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _logoutTimer;

  DateTime nextLocalMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  Future<void> forceLogout(BuildContext context) async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    // if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> scheduleAutoLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMs = prefs.getInt('sessionExpiry');
    _logoutTimer?.cancel();
    if (expiryMs == null) return;

    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    final now = DateTime.now();
    final diff = expiry.difference(now);

    if (diff.isNegative) {
      await forceLogout(context);
    } else {
      _logoutTimer = Timer(diff, () => forceLogout(context));
    }
  }

  @override
  void dispose() {
    _logoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GlobalLoaderOverlay(
          overlayWidgetBuilder: (_) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Styles.white),
              Text("กรุณารอสักครู่...", style: Styles.white18(context)),
            ],
          ),
          overlayColor: Styles.primaryColor.withOpacity(0.8),
          child: MaterialApp(
            routes: {
              '/': (context) => const AuthCheck(),
              '/route': (context) => const HomeScreen(index: 1),
              '/store': (context) => const HomeScreen(index: 2),
              '/manage': (context) => const HomeScreen(index: 3),
              '/announce': (context) => const Announce(),
            },
            initialRoute: '/',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            navigatorObservers: [routeObserver],
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              extensions: const [SkeletonizerConfigData.dark()],
              textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
            ),
          ),
        );
      },
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
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthCheck()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/animation/loading2.json',
            frameRate: FrameRate.max),
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
  late SharedPreferences sharedPreferences;
  late Upgrader _upgrader;
  bool _checkedUpgrade = false;

  DateTime nextLocalMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  Future<void> getUserData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    // final expiryMs = sharedPreferences.getInt('sessionExpiry');

    // if (expiryMs == null) {
    //   if (!mounted) return;
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const LoginScreen()),
    //   );
    //   return;
    // }

    // final isExpired =
    //     DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(expiryMs));
    // if (isExpired) {
    //   await sharedPreferences.clear();
    //   if (!mounted) return;
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const LoginScreen()),
    //   );
    //   return;
    // }

    // Still valid → load user
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

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen(index: 0)),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _upgrader = Upgrader(debugLogging: true);
    _initUpgrade();
  }

  Future<void> _initUpgrade() async {
    await _upgrader.initialize();
    if (!_upgrader.shouldDisplayUpgrade()) {
      setState(() => _checkedUpgrade = true);
      getUserData();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // final prefs = await SharedPreferences.getInstance();
      // final expiryMs = prefs.getInt('sessionExpiry');
      // if (expiryMs != null &&
      //     DateTime.now()
      //         .isAfter(DateTime.fromMillisecondsSinceEpoch(expiryMs))) {
      //   await prefs.clear();
      //   if (!mounted) return;
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(builder: (_) => const LoginScreen()),
      //     (_) => false,
      //   );
      //   return;
      // }
      await _upgrader.initialize();
      if (!_upgrader.shouldDisplayUpgrade()) {
        setState(() => _checkedUpgrade = true);
        getUserData();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyUpgradeAlert(
      upgrader: _upgrader,
      child: Scaffold(
        backgroundColor: Styles.primaryColor,
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.width / 2,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logo12.png'),
              ),
            ),
          ).animate().shake(duration: 600.ms),
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
      builder: (_) => AlertDialog(
        key: key,
        title: Text('🛠️⬆️ พบอัปเดตใหม่', style: Styles.headerBlack24(context)),
        content: SingleChildScrollView(
          child: ListBody(children: <Widget>[
            Text(message, style: Styles.black18(context)),
            if (releaseNotes != null && releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(releaseNotes, style: Styles.black18(context)),
            ],
          ]),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("อัปเดต", style: Styles.black18(context)),
            onPressed: () => onUserUpdated(context, !widget.upgrader.blocked()),
          ),
        ],
      ),
    );
  }
}
