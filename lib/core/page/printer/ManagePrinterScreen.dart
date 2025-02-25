import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:toastification/toastification.dart';

class ManagePrinterScreen extends StatefulWidget {
  const ManagePrinterScreen({super.key});

  @override
  State<ManagePrinterScreen> createState() => _ManagePrinterScreenState();
}

class _ManagePrinterScreenState extends State<ManagePrinterScreen> {
  List<BluetoothInfo> _devices = [];

  @override
  void initState() {
    super.initState();
    _fetchPairedDevices();
  }

  Future<void> _fetchPairedDevices() async {
    try {
      await _disconnectPrinter2();
      // await _connectToPrinter(User.devicePrinter);
      final List<BluetoothInfo> pairedDevices =
          await PrintBluetoothThermal.pairedBluetooths;
      // print(User.devicePrinter.macAdress);
      // print(User.devicePrinter.name);
      // print(User.connectPrinter);
      if (pairedDevices.isNotEmpty) {
        setState(() {
          _devices = pairedDevices;
          User.devicePrinter =
              _devices.first; // Safe way to access the first item
        });
      } else {
        setState(() {
          _devices = [];
          User.devicePrinter =
              BluetoothInfo(name: "Unknown", macAdress: "00:00:00:00:00:00");
        });
      }
      // setState(() {
      //   _devices = pairedDevices;
      //   User.devicePrinter = _devices[0];
      // });
    } catch (e) {
      print("Error fetching paired devices: $e");
    }
  }

  Future<void> _disconnectPrinter() async {
    bool result = await PrintBluetoothThermal.disconnect;
    print("Printer disconnected ($result)");
    setState(() {
      User.connectPrinter = !result;
    });
    toastification.show(
      autoCloseDuration: const Duration(seconds: 5),
      context: context,
      primaryColor: Colors.red,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(
        "ยกเลิกการเชื่อมต่อ",
        style: Styles.red18(context),
      ),
    );
  }

  Future<void> _disconnectPrinter2() async {
    bool result = await PrintBluetoothThermal.disconnect;
    print("Printer disconnected ($result)");
    setState(() {
      User.connectPrinter = !result;
    });
  }

  Future<void> _connectToPrinter(BluetoothInfo device) async {
    try {
      bool result = await PrintBluetoothThermal.connect(
          macPrinterAddress: device.macAdress);
      if (mounted) {
        setState(() {
          User.connectPrinter = result;
        });
      }

      // toastification.show(
      //   autoCloseDuration: const Duration(seconds: 5),
      //   context: context,
      //   primaryColor: Colors.green,
      //   type: ToastificationType.success,
      //   style: ToastificationStyle.flatColored,
      //   title: Text(
      //     "เชื่อมต่อแล้วกับ ${device.name}",
      //     style: Styles.green18(context),
      //   ),
      // );
      toastification.show(
        autoCloseDuration: const Duration(seconds: 5),
        context: context,
        primaryColor: result ? Colors.green : Colors.red,
        type: result ? ToastificationType.success : ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          result
              ? "เชื่อมต่อแล้วกับ ${device.name}"
              : "เชื่อมต่อไม่ได้กับ ${device.name}",
          style: result ? Styles.green18(context) : Styles.red18(context),
        ),
      );
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " จัดการเครื่องปริ้น",
          icon: Icons.print_rounded,
        ),
      ),
      body: RefreshIndicator(
        edgeOffset: 0,
        color: Colors.white,
        backgroundColor: Styles.primaryColor,
        onRefresh: () async {
          _fetchPairedDevices();
        },
        child: ListView(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    BoxShadowCustom(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Hero(
                                  transitionOnUserGestures: true,
                                  tag: 'printerScreen',
                                  child: Icon(
                                    Icons.print_rounded,
                                    color: Styles.primaryColor,
                                    size: 40,
                                  ),
                                ),
                                Text(
                                  ' รายละเอียดอุปกรณ์ที่เชื่อมอยู่ล่าสุด',
                                  style: Styles.black18(context),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ' ชื่ออุปกรณ์: ${User.devicePrinter.name}',
                                  style: Styles.black18(context),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      ' สถานะ: ',
                                      style: Styles.black18(context),
                                    ),
                                    Text(
                                      '${User.connectPrinter ? "เชื่อมต่ออยู่" : "ไม่ได้เชื่อมต่อ"}',
                                      style: User.connectPrinter
                                          ? Styles.green18(context)
                                          : Styles.red18(context),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    _devices.isNotEmpty
                        ? Expanded(
                            child: BoxShadowCustom(
                              child: Container(
                                // color: Colors.red,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "อุปกรณ์ที่พบ",
                                            style: Styles.black18(context),
                                          ),
                                          Text(
                                            "${_devices.length} รายการ",
                                            style: Styles.black18(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        itemCount: _devices.length,
                                        itemBuilder: (context, index) {
                                          final device = _devices[index];
                                          return ListTile(
                                              title: Text(
                                                device.name ?? "Unknown Device",
                                                style: Styles.black18(context),
                                              ),
                                              subtitle: Text(
                                                device.macAdress,
                                                style: Styles.black18(context),
                                              ),
                                              trailing: User.connectPrinter &&
                                                      User.devicePrinter ==
                                                          device
                                                  ? Icon(Icons.check,
                                                      color: Colors.green)
                                                  : null,
                                              onTap: () {
                                                if (!User.connectPrinter) {
                                                  _connectToPrinter(
                                                      User.devicePrinter);
                                                } else {
                                                  _disconnectPrinter();
                                                }
                                              });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text("No paired devices found"),
                          ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
