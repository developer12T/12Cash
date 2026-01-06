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
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Upgrader.clearSavedSettings();
  await availableCameras();
  await EasyLocalization.ensureInitialized();
  await initializeNotifications();
  await requestAllPermissions();
  await initializeDateFormatting('th', null);
  await dotenv.load(fileName: ".env");
  await ScreenUtil.ensureScreenSize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await LocationService().initialize();
  SocketService().connect();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (_) => runApp(
      KeyboardVisibilityProvider(
        child: EasyLocalization(
          startLocale: const Locale("th", "TH"),
          path: 'assets/locales',
          fallbackLocale: const Locale('th', 'TH'),
          supportedLocales: const [Locale('en', 'US'), Locale('th', 'TH')],
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
    ),
  );
}

/* ================================================= */
/* Version Check → FORCE LOGOUT WHEN APP UPDATED     */
/* ================================================= */
class VersionCheck {
  static const String lastVersionKey = 'last_version';

  static Future<bool> shouldForceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();

    final currentVersion = info.version;
    final savedVersion = prefs.getString(lastVersionKey);

    if (savedVersion == null) {
      await prefs.setString(lastVersionKey, currentVersion);
      return false;
    }

    if (savedVersion != currentVersion) {
      await prefs.clear(); // 🔥 clear session
      await prefs.setString(lastVersionKey, currentVersion);
      return true;
    }

    return false;
  }
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return GlobalLoaderOverlay(
          overlayWidgetBuilder: (_) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              Text("กรุณารอสักครู่...", style: Styles.white18(context)),
            ],
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorObservers: [routeObserver],
            routes: {
              '/': (_) => const AuthCheck(),
              '/route': (_) => const HomeScreen(index: 1),
              '/store': (_) => const HomeScreen(index: 2),
              '/manage': (_) => const HomeScreen(index: 3),
              '/announce': (_) => const Announce(),
            },
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              extensions: const [SkeletonizerConfigData.dark()],
            ),
          ),
        );
      },
    );
  }
}

/* ====================== */
/* AUTH CHECK + VERSION   */
/* ====================== */
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  late Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    _upgrader = Upgrader(debugLogging: true);
    _init();
  }

  Future<void> _init() async {
    await _upgrader.initialize();

    if (_upgrader.shouldDisplayUpgrade()) {
      return;
    }

    final forceLogout = await VersionCheck.shouldForceLogout();
    if (forceLogout) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
      return;
    }

    await _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final info = await PackageInfo.fromPlatform();

    User.username = prefs.getString('username') ?? "";
    User.firstName = prefs.getString('firstName') ?? "";
    User.surName = prefs.getString('surName') ?? "";
    User.fullName = prefs.getString('fullName') ?? "";
    User.salePayer = prefs.getString('salePayer') ?? "";
    User.tel = prefs.getString('tel') ?? "";
    User.area = prefs.getString('area') ?? "";
    User.typeTruck = prefs.getString('typeTruck') ?? "";
    User.saleCode = prefs.getString('saleCode') ?? "";
    User.zone = prefs.getString('zone') ?? "";
    User.warehouse = prefs.getString('warehouse') ?? "";
    User.role = prefs.getString('role') ?? "";
    User.token = prefs.getString('token') ?? "";
    User.versionApp = info.version;

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen(index: 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: _upgrader,
      barrierDismissible: false,
      showIgnore: false,
      showLater: false,
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
