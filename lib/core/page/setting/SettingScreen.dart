import 'dart:convert';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/dropdown/DropDownStandarad.dart';
import 'package:_12sale_app/core/components/search/CustomerDropdownSearch.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/LoginScreen.dart';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

// import 'package:dart_config/default_server.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late Map<String, String> languages = {};
  bool light = true;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  String? selectedLanguageCode;
  @override
  void initState() {
    super.initState();
    _loadData();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  Future<void> _loadData() async {
    final String jsonString =
        await rootBundle.loadString('assets/locales/languages.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      languages = Map<String, String>.from(jsonData);
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedLanguageCode = context.locale.toString().split("_")[0];
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(title: " การตั้งค่า", icon: Icons.settings_sharp),
      ),
      body: Container(
        // color: Colors.deepOrange,
        padding: EdgeInsets.symmetric(vertical: screenWidth / 15),
        // margin: const EdgeInsets.only(top: 30),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: screenWidth / 5,
                // width: screenWidth,
                decoration: const BoxDecoration(
                  // color: Colors.red,
                  image: DecorationImage(
                    image: AssetImage('assets/images/12CashLogo.png'),
                    // fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "12 Cash App",
                    style: Styles.black24(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${User.fullName}",
                    style: Styles.black24(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    child: Text(
                      "  ข้อมูลส่วนตัว",
                      style: Styles.black18(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth / 10),
                          Text(
                            "ข้อมูลส่วนตัว",
                            style: Styles.black18(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth / 10),
                          Text(
                            "สรุปการทำงาน",
                            style: Styles.black18(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    child: Text(
                      "  การตั้งค่า",
                      style: Styles.black18(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white,
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth / 10),
                          // Text("เปลี่ยนภาษา ", style: Styles.black18(context)),
                          // Switch(
                          //   // This bool value toggles the switch.
                          //   value: light,

                          //   activeColor: Styles.primaryColor,
                          //   onChanged: (bool value) {
                          //     setState(() {
                          //       light = value;
                          //     });
                          //   },
                          // )
                          Container(
                            child: DropdownButton<String>(
                              icon: const Icon(
                                Icons.chevron_left,
                              ),
                              // isExpanded: true,
                              value: selectedLanguageCode,
                              hint: Text(
                                'เปลี่ยนภาษา เลือกภาษา',
                                style: Styles.black18(context),
                              ),
                              items: languages.entries
                                  .map(
                                    (entry) => DropdownMenuItem<String>(
                                      value: entry.key,
                                      child: Text(
                                        entry.value,
                                        style: Styles.black18(context),
                                      ),
                                      // Display language name
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) async {
                                switch (value) {
                                  case "en":
                                    await context
                                        .setLocale(const Locale('en', 'US'));
                                    break;
                                  case "th":
                                    await context
                                        .setLocale(const Locale('th', 'TH'));
                                    break;
                                  default:
                                }
                                //  log(locale.toString(), name: toString());
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen(
                                            index: 0,
                                          )),
                                );
                                print(context.locale.toString().split("_")[0]);
                                setState(() {
                                  selectedLanguageCode = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white,
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth / 10),
                          Text(
                            "การตั้งค่า",
                            style: Styles.black18(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    child: Text(
                      "  ข้อมูลอื่นๆ",
                      style: Styles.black18(context),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white,
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth / 10),
                          Text(
                            "ข่าวประกาศ",
                            style: Styles.black18(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white,
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth / 10),
                          Text(
                            "เวอร์ชั่นปัจจุบัน : ${_packageInfo.version} ",
                            style: Styles.black18(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        await preferences.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        color: Colors.white,
                        child: Row(
                          children: [
                            SizedBox(width: screenWidth / 10),
                            Text(
                              "ออกจากระบบ",
                              style: Styles.black18(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
