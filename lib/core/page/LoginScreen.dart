import 'dart:convert';
import 'dart:io';

import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late SharedPreferences sharedPreferences;

  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  vaildateUserEmail() async {
    try {
      var dio = Dio();
      var response = await dio.post(
        "http://192.168.44.64:8003/erp/customer/",
        data: jsonEncode(
          {
            "username": _userNameController.text.trim(),
          },
        ),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      // showSnackBar('Error orred');
    }
  }

  void showCommonAlert(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Styles.headerRed24(context),
          ),
          content: Text(
            content,
            style: Styles.red18(context),
          ),
          actions: [
            TextButton(
              child: Text("ตกลง", style: Styles.black18(context)),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> saveUserData(Map<String, dynamic> resBody) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // Set the current timestamp and expiry duration in seconds
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    // int expiryDuration = 60 * 60 * 1000; // 1 hour in milliseconds
    int expiryDuration = 24 * 60 * 60 * 1000; // 1 hour in milliseconds

    sharedPreferences.setString('username', resBody['username']);
    sharedPreferences.setString('firstName', resBody['firstName']);
    sharedPreferences.setString('surName', resBody['surName']);
    sharedPreferences.setString('fullName', resBody['fullName']);
    sharedPreferences.setString('saleCode', resBody['saleCode']);
    sharedPreferences.setString('salePayer', resBody['salePayer']);
    sharedPreferences.setString('tel', resBody['tel']);
    sharedPreferences.setString('area', resBody['area']);
    sharedPreferences.setString('zone', resBody['zone']);
    sharedPreferences.setString('warehouse', resBody['warehouse']);
    sharedPreferences.setString('role', resBody['role']);
    sharedPreferences.setString('token', resBody['token']);

    // Save the expiry timestamp
    sharedPreferences.setInt('dataExpiry', currentTimestamp + expiryDuration);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: screenWidth / 2,
                      height: screenWidth / 4,
                      // color: Colors.red,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/images/12TradingLogo.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: screenWidth / 25),
                      TextField(
                        controller: _userNameController,
                        style: Styles.black18(context),
                        decoration: InputDecoration(
                          labelText: 'ชื่อผู้ใช้งาน',
                          labelStyle: Styles.black24(context),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: screenWidth / 25),
                      TextField(
                        controller: _passwordController,
                        style: Styles.black18(context),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'รหัสผ่าน',
                          labelStyle: Styles.black24(context),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      SizedBox(height: screenWidth / 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Styles.primaryColor,
                        ),
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          String username = _userNameController.text.trim();
                          String password = _passwordController.text.trim();
                          if (username.isEmpty) {
                            showCommonAlert(
                                context, "แจ้งเตือน", "กรุณากรอกชื่อผู้ใช้งาน");
                          } else if (password.isEmpty) {
                            showCommonAlert(
                                context, "แจ้งเตือน", "กรุณากรอกรหัสผ่าน");
                          } else {
                            print(_userNameController.text);
                            print(_passwordController.text);
                            try {
                              var dio = Dio();
                              var response = await dio.post(
                                "http://192.168.44.57:8005/api/cash/login",
                                data: jsonEncode(
                                  {
                                    "username": _userNameController.text.trim(),
                                    "password": _passwordController.text.trim(),
                                  },
                                ),
                              );
                              print('Status Code: ${response.statusCode}');
                              if (response.statusCode == 200) {
                                // print(
                                //     'Username ${response.data['data'][0]['username']}');
                                var resBody = response.data['data'][0];
                                // if (resBody['success'] == true) {

                                // }
                                print(resBody['username']);
                                await saveUserData(resBody);

                                sharedPreferences =
                                    await SharedPreferences.getInstance();
                                // sharedPreferences.setString(
                                //     'username', resBody['username']);
                                // sharedPreferences.setString(
                                //     'firstName', resBody['firstName']);
                                // sharedPreferences.setString(
                                //     'surName', resBody['surName']);
                                // sharedPreferences.setString(
                                //     'fullName', resBody['fullName']);
                                // sharedPreferences.setString(
                                //     'saleCode', resBody['saleCode']);
                                // sharedPreferences.setString(
                                //     'salePayer', resBody['salePayer']);
                                // sharedPreferences.setString(
                                //     'tel', resBody['tel']);
                                // sharedPreferences.setString(
                                //     'area', resBody['area']);
                                // sharedPreferences.setString(
                                //     'zone', resBody['zone']);
                                // sharedPreferences.setString(
                                //     'warehouse', resBody['warehouse']);
                                // sharedPreferences.setString(
                                //     'role', resBody['role']);
                                // sharedPreferences.setString(
                                //     'token', resBody['token']);

                                setState(() {
                                  User.username =
                                      sharedPreferences.getString('username')!;
                                  User.firstName =
                                      sharedPreferences.getString('firstName')!;
                                  User.surName =
                                      sharedPreferences.getString('surName')!;
                                  User.fullName =
                                      sharedPreferences.getString('fullName')!;
                                  User.salePayer =
                                      sharedPreferences.getString('salePayer')!;
                                  User.tel =
                                      sharedPreferences.getString('tel')!;
                                  User.area =
                                      sharedPreferences.getString('area')!;
                                  User.zone =
                                      sharedPreferences.getString('zone')!;
                                  User.warehouse =
                                      sharedPreferences.getString('warehouse')!;
                                  User.role =
                                      sharedPreferences.getString('role')!;
                                  User.token =
                                      sharedPreferences.getString('token')!;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(
                                      index: 0,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              showCommonAlert(context, "เกิดข้อผิดพลาด",
                                  "โปรดเช็คข้อมูลอีกครั้ง");
                            }
                          }
                        },
                        child: Text(
                          'เข้าสู่ระบบ',
                          style: Styles.white24(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
