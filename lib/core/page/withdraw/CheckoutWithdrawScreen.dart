import 'dart:async';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/alert/AllAlert.dart';
import 'package:_12sale_app/core/page/withdraw/WithDrawScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/core/utils/tost_util.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/withdraw/OptionType.dart';
import 'package:_12sale_app/data/models/withdraw/Shipping.dart';
import 'package:_12sale_app/data/models/withdraw/Type.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:toastification/toastification.dart';

import '../../../data/models/order/Cart.dart';

class CheckoutWithdrawScreen extends StatefulWidget {
  const CheckoutWithdrawScreen({super.key});

  @override
  State<CheckoutWithdrawScreen> createState() => _CheckoutWithdrawScreenState();
}

class _CheckoutWithdrawScreenState extends State<CheckoutWithdrawScreen> {
  bool isLoading = true;
  bool _isInnerAtTop = true;
  bool _isInnerAtBottom = false;
  String isType = '';
  String isWithdrawType = '';
  String isWithdrawTypeText = '';
  String optionType = '';
  String isShippingId = '';
  String addressShipping = '';
  String nameShipping = '';
  double totalCart = 0;

  ScrollController _outerController = ScrollController();
  final ScrollController _cartScrollController = ScrollController();
  final ScrollController _typeScrollController = ScrollController();
  final ScrollController _shippingScrollController = ScrollController();
  late TextEditingController noteController;

  List<CartList> cartList = [];
  List<TypeDistribute> typeDis = [];
  List<OptionWithdraw> typeWithdraw = [];
  List<ShippingData> shippingList = [];

  final Debouncer _debouncer = Debouncer();

  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _getCart();
    _getType();
    _getWithdrawType();
    _getShipping();
    noteController = TextEditingController();
  }

  @override
  void dispose() {
    noteController.dispose();
    _cartScrollController.dispose();
    _typeScrollController.dispose();
    _shippingScrollController.dispose();
    super.dispose();
  }

  String latitude = '';
  String longitude = '';
  final LocationService locationService = LocationService();

  Future<void> fetchLocation() async {
    try {
      // Initialize the location service
      await locationService.initialize();

      // Get latitude and longitude
      double? lat = await locationService.getLatitude();
      double? lon = await locationService.getLongitude();

      setState(() {
        latitude = lat?.toString() ?? "Unavailable";
        longitude = lon?.toString() ?? "Unavailable";
      });
      print("${latitude}, ${longitude}");
    } catch (e) {
      if (mounted) {
        setState(() {
          latitude = "Error fetching latitude";
          longitude = "Error fetching longitude";
        });
      }
      print("Error: $e");
    }
  }

  Future<void> _reduceCart(CartList cart) async {
    const duration = Duration(seconds: 1);
    try {
      _debouncer.debounce(
        duration: duration,
        onDebounce: () async {
          ApiService apiService = ApiService();
          await apiService.init();
          var response = await apiService.request(
            endpoint: 'api/cash/cart/reduce',
            method: 'PATCH',
            body: {
              "type": "withdraw",
              "area": "${User.area}",
              "id": "${cart.id}",
              "qty": cart.qty,
              "unit": "${cart.unit}"
            },
          );
          if (response.statusCode == 200) {
            toastification.show(
              autoCloseDuration: const Duration(seconds: 5),
              context: context,
              primaryColor: Colors.green,
              type: ToastificationType.success,
              style: ToastificationStyle.flatColored,
              title: Text(
                "แก้ไขข้อมูลสำเร็จ",
                style: Styles.green18(context),
              ),
            );
            _getCart();
          }
        },
      );
    } catch (e) {
      toastification.show(
        autoCloseDuration: const Duration(seconds: 5),
        context: context,
        primaryColor: Colors.red,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          "เกิดข้อผิดพลาด $e",
          style: Styles.red18(context),
        ),
      );
      print("Error $e");
    }
  }

  Future<void> _deleteCart(CartList cart) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/delete',
        method: 'POST',
        body: {
          "type": "withdraw",
          "area": "${User.area}",
          "id": "${cart.id}",
          "unit": "${cart.unit}"
        },
      );
      if (response.statusCode == 200) {
        await _getCart();
        toastification.show(
          autoCloseDuration: const Duration(seconds: 5),
          context: context,
          primaryColor: Colors.green,
          type: ToastificationType.success,
          style: ToastificationStyle.flatColored,
          title: Text(
            "ลบข้อมูลสำเร็จ",
            style: Styles.green18(context),
          ),
        );
        if (cartList.length == 0) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error : $e");
    }
  }

  Future<void> _getCart() async {
    try {
      print("Get Cart is Loading");
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/cart/get?type=withdraw&area=${User.area}',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'][0]['listProduct'];

        setState(() {
          totalCart = response.data['data'][0]['total'].toDouble();
          cartList = data.map((item) => CartList.fromJson(item)).toList();
        });
        Timer(const Duration(milliseconds: 500), () {
          setState(() {
            isLoading = false;
          });
        });
      }
    } catch (e) {
      setState(() {
        totalCart = 0;
        cartList = [];
      });

      print("Error $e");
    }
  }

  Future<void> _checkout() async {
    try {
      List<String> missingFields = [];
      if (isType != "T04") {
        if (addressShipping.isEmpty) {
          missingFields.add("ที่อยู่");
        }
      }
      if (isShippingId.isEmpty) {
        missingFields.add("");
      }
      if (isWithdrawType.isEmpty) {
        missingFields.add("ประเภทการเบิก");
      }
      if (_selectedDate == null) {
        missingFields.add("วันที่");
      }
      if (noteController.text.isEmpty) {
        missingFields.add("หมายเหตุ");
      }
      if (missingFields.isNotEmpty) {
        showToast(
          context: context,
          message: 'กรุณาใส่ ${missingFields.join(', ')}',
          type: ToastificationType.error,
          primaryColor: Colors.red,
        );
      } else {
        context.loaderOverlay.show();
        await fetchLocation();
        ApiService apiService = ApiService();
        await apiService.init();
        var response = await apiService.request(
            endpoint: 'api/cash/distribution/checkout',
            method: 'POST',
            body: {
              "type": "withdraw",
              "area": "${User.area}",
              "shippingId": "${isShippingId}",
              "withdrawType": "${isWithdrawType}",
              "sendDate": "${DateFormat("yyyy-MM-dd").format(_selectedDate!)}",
              "note": "${noteController.text}",
              "latitude": "${latitude}",
              "longitude": "${longitude}"
            });
        if (response.statusCode == 200) {
          toastification.show(
            autoCloseDuration: const Duration(seconds: 5),
            context: context,
            primaryColor: Colors.green,
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            title: Text(
              "ส่งเบิกสินค้าสำเร็จ",
              style: Styles.green18(context),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const WithDrawScreen(),
            ),
            (route) => route.isFirst, // Keeps only the first route
          );
        }
      }
    } catch (e) {
      toastification.show(
        autoCloseDuration: const Duration(seconds: 5),
        context: context,
        primaryColor: Colors.red,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          "เกิดข้อผิดพลาด $e",
          style: Styles.red18(context),
        ),
      );

      print("Error $e");
    }
  }

  Future<void> _getType() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint: 'api/cash/distribution/getType',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          typeDis = data.map((item) => TypeDistribute.fromJson(item)).toList();
          isType = typeDis[0].type;
        });
      }
    } catch (e) {
      setState(() {
        typeDis = [];
      });

      print("Error $e");
    }
  }

  Future<void> _getWithdrawType() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/manage/option/get?module=withdraw&type=withdrawType',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          typeWithdraw =
              data.map((item) => OptionWithdraw.fromJson(item)).toList();
        });
      }
    } catch (e) {
      setState(() {
        typeWithdraw = [];
      });

      print("Error $e");
    }
  }

  Future<void> _getShipping() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/distribution/place/get?area=${User.area}&type=${isType}',
        method: 'GET',
      );
      // print(response.data['data']['listAddress']);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['listAddress'];
        // print(response.data['data'][0]);
        setState(() {
          shippingList =
              data.map((item) => ShippingData.fromJson(item)).toList();
        });
        if (isType == "T04") {
          setState(() {
            isShippingId = shippingList[0].shippingId;
          });
        }
      }
    } catch (e) {
      setState(() {
        shippingList = [];
      });
      print("Error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppbarCustom(
          title: " เบิกสินค้า",
          icon: Icons.local_shipping,
        ),
      ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Styles.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    AllAlert.customAlert(
                        context,
                        "store.processtimeline_screen.alert.title".tr(),
                        "คุณต้องการจะเบิกสินค้าใช่หรือไม่ ?", () async {
                      await _checkout();
                      // print({
                      //   "type": "withdraw",
                      //   "area": "${User.area}",
                      //   "shippingId": "${isShippingId}",
                      //   "withdrawType": "${isWithdrawType}",
                      //   "sendDate":
                      //       "${DateFormat("yyyy-MM-dd").format(_selectedDate!)}",
                      //   "note": "${noteController.text}",
                      //   "latitude": "${latitude}",
                      //   "longitude": "${longitude}"
                      // });
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white),
                              child: Text(
                                "${cartList.length}",
                                style: Styles.headerPirmary18(context),
                              ),
                            ),
                            Text(
                              " เบิกสินค้า",
                              style: Styles.headerWhite18(context),
                            ),
                          ],
                        ),
                        Text(
                          "${totalCart.toStringAsFixed(0)} หีบ",
                          style: Styles.headerWhite18(context),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is OverscrollNotification) {
                if (_isInnerAtTop && notification.overscroll < 0) {
                  _outerController.jumpTo(
                      _outerController.offset + notification.overscroll);
                } else if (_isInnerAtBottom && notification.overscroll > 0) {
                  _outerController.jumpTo(
                      _outerController.offset + notification.overscroll);
                }
              }
              return false;
            },
            child: ListView(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              controller: _outerController,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        typeDis.length > 0
                            ? CustomSlidingSegmentedControl<String>(
                                initialValue: "T04",
                                isStretch: true,
                                children: {
                                  for (int index = 0;
                                      index < typeDis.length;
                                      index++)
                                    typeDis[index].type: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 8),
                                        Text(
                                          typeDis[index]
                                              .typeNameTH, // Access name from typeDis list
                                          style: isType == typeDis[index].type
                                              ? Styles.headerPirmary18(context)
                                              : Styles.headerWhite18(context),
                                        ),
                                      ],
                                    )
                                },
                                onValueChanged: (v) {
                                  setState(() {
                                    isType = v;
                                  });

                                  _getShipping();
                                  print(v);
                                },
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                thumbDecoration: BoxDecoration(
                                  color: Styles.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                duration: const Duration(milliseconds: 300),
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 10,
                        ),
                        BoxShadowCustom(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(8),

                                            elevation: 0, // Disable shadow
                                            shadowColor: Colors
                                                .transparent, // Ensure no shadow color
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1),
                                            ),
                                          ),
                                          onPressed: () {
                                            _showDatePicker(context);
                                          },
                                          child: Text(
                                            _selectedDate == null
                                                ? "กรุณาเลือกวันที่รับของ"
                                                : "${DateFormat("dd-MM-yyyy").format(_selectedDate!)}",
                                            style: Styles.black18(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(8),
                                            elevation: 0, // Disable shadow
                                            shadowColor: Colors
                                                .transparent, // Ensure no shadow color
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              side: BorderSide(
                                                  color: Colors.grey[300]!,
                                                  width: 1),
                                            ),
                                          ),
                                          onPressed: () {
                                            _showTypeSheet(context);
                                          },
                                          child: Text(
                                            isWithdrawTypeText != ""
                                                ? isWithdrawTypeText
                                                : "กรุณาเลือกประเภทการเบิก",
                                            style: Styles.black18(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                isType != 'T04'
                                    ? Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  elevation:
                                                      0, // Disable shadow
                                                  shadowColor: Colors
                                                      .transparent, // Ensure no shadow color
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius
                                                        .zero, // No rounded corners
                                                    side: BorderSide
                                                        .none, // Remove border
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .location_on_outlined,
                                                              color:
                                                                  Colors.black,
                                                              size: 30,
                                                            ),
                                                            Text(
                                                              " ที่อยู่จัดส่ง",
                                                              style:
                                                                  Styles.grey18(
                                                                      context),
                                                            )
                                                          ],
                                                        ),
                                                        Text(
                                                          " แก้ไข้ที่อยู่จัดส่ง",
                                                          style: Styles.grey18(
                                                              context),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              isShippingId != ''
                                                                  ? Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              35,
                                                                        ),
                                                                        Text(
                                                                          nameShipping,
                                                                          style:
                                                                              Styles.grey18(context),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : SizedBox(),
                                                              isShippingId != ''
                                                                  ? Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              35,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            "${addressShipping}",
                                                                            style:
                                                                                Styles.grey18(context),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              35,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            "โปรดเลือกที่อยู่จัดส่ง",
                                                                            style:
                                                                                Styles.grey18(context),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    )
                                                            ],
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios_rounded,
                                                          color: Colors.black,
                                                          size: 20,
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  _showAddressSheet(context);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.all(8),
                                            elevation: 0, // Disable shadow
                                            shadowColor: Colors
                                                .transparent, // Ensure no shadow color
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero,
                                                side: BorderSide.none),
                                          ),
                                          onPressed: () {
                                            _showNoteSheet(context);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  "หมายเหตุ :",
                                                  style:
                                                      Styles.black18(context),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  noteController.text != ''
                                                      ? noteController.text
                                                      : "กรุณาใส่หมายเหตุ...",
                                                  style: Styles.grey18(context),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[200],
                                  thickness: 1,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          child: BoxShadowCustom(
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "รายการที่สั่ง",
                                        style: Styles.black18(context),
                                      ),
                                      Text(
                                        "จำนวน ${cartList.length} รายการ",
                                        style: Styles.black18(context),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                      child: Scrollbar(
                                    controller: _cartScrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    thickness: 10,
                                    radius: Radius.circular(16),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      controller: _cartScrollController,
                                      itemCount: cartList.length,
                                      itemBuilder: (context, index) {
                                        return LoadingSkeletonizer(
                                          loading: isLoading,
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: Image.network(
                                                      'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                                                      width: screenWidth / 8,
                                                      height: screenWidth / 8,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
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
                                                  Expanded(
                                                    flex: 3,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  cartList[
                                                                          index]
                                                                      .name,
                                                                  style: Styles
                                                                      .black16(
                                                                          context),
                                                                  softWrap:
                                                                      true,
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'รหัส: ${cartList[index].id}',
                                                                        style: Styles.black16(
                                                                            context),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        'จำนวน : ${cartList[index].qty.toStringAsFixed(0)} ${cartList[index].unitName}',
                                                                        style: Styles.black16(
                                                                            context),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  // Row(
                                                                  //   children: [
                                                                  //     Text(
                                                                  //       'ราคา : ${cartList[index].price}',
                                                                  //       style: Styles.black16(
                                                                  //           context),
                                                                  //     ),
                                                                  //   ],
                                                                  // ),
                                                                ],
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        if (cartList[index].qty >
                                                                            1) {
                                                                          cartList[index]
                                                                              .qty--;
                                                                        }
                                                                      });
                                                                      await _reduceCart(
                                                                          cartList[
                                                                              index]);
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      shape:
                                                                          const CircleBorder(
                                                                        side: BorderSide(
                                                                            color:
                                                                                Colors.grey,
                                                                            width: 1),
                                                                      ), // ✅ Makes the button circular
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white, // Button color
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .remove,
                                                                      size: 24,
                                                                      color: Colors
                                                                          .grey,
                                                                    ), // Example
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(4),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              16),
                                                                    ),
                                                                    width: 75,
                                                                    child: Text(
                                                                      '${cartList[index].qty.toStringAsFixed(0)}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: Styles
                                                                          .black18(
                                                                        context,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await _reduceCart(
                                                                          cartList[
                                                                              index]);

                                                                      setState(
                                                                          () {
                                                                        cartList[index]
                                                                            .qty++;
                                                                      });
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      shape:
                                                                          const CircleBorder(
                                                                        side: BorderSide(
                                                                            color:
                                                                                Colors.grey,
                                                                            width: 1),
                                                                      ), // ✅ Makes the button circular
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white, // Button color
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons.add,
                                                                      size: 24,
                                                                      color: Colors
                                                                          .grey,
                                                                    ), // Example
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      await _deleteCart(
                                                                          cartList[
                                                                              index]);

                                                                      setState(
                                                                        () {
                                                                          cartList.removeWhere((item) =>
                                                                              (item.id == cartList[index].id && item.unit == cartList[index].unit));
                                                                        },
                                                                      );
                                                                      // await _getTotalCart(setModalState);
                                                                    },
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      shape:
                                                                          const CircleBorder(
                                                                        side: BorderSide(
                                                                            color:
                                                                                Colors.red,
                                                                            width: 1),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white, // Button color
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .delete,
                                                                      size: 24,
                                                                      color: Colors
                                                                          .red,
                                                                    ), // Example
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // Container(
                                                  //   color: Colors.red,
                                                  //   width: 50,
                                                  //   height: 100,
                                                  //   child: Center(
                                                  //     child: Icon(
                                                  //       Icons.delete,
                                                  //       color: Colors.white,
                                                  //       size: 25,
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                              Divider(
                                                color: Colors.grey[200],
                                                thickness: 1,
                                                indent: 16,
                                                endIndent: 16,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ))
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      locale: Locale('th', 'TH'),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 3),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              headlineSmall: Styles.white18(context), // Month & Year in header
              headlineLarge: Styles.white18(context),
              headlineMedium: Styles.white18(context),
              titleMedium: Styles.white18(context), // Selected date
              titleLarge: Styles.white18(context),
              titleSmall: Styles.white18(context),
              bodyMedium: Styles.white18(context), // Day numbers in calendar
              bodyLarge: Styles.white18(context),
              bodySmall: Styles.white18(context),
              labelLarge: Styles.white18(context), // OK / Cancel buttons
              labelMedium: Styles.white18(context),
              labelSmall: Styles.white18(context),
            ),
            colorScheme: const ColorScheme.light(
              surface: Styles.primaryColor,

              primary: Styles.white, // Header background color
              onPrimary: Styles.primaryColor, // Header text color
              onSurface: Styles.white, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Styles.white, // Button text color
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      // widget.onDateSelected(pickedDate);
    }
  }

  void _showNoteSheet(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                width: screenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              Text('หมายเหตุ', style: Styles.white24(context)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _getCart();
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            autofocus: true,
                            style: Styles.black18(context),
                            controller: noteController,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(8),
                                    elevation: 0, // Disable shadow
                                    shadowColor: Colors
                                        .transparent, // Ensure no shadow color
                                    backgroundColor: Styles.primaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide.none),
                                  ),
                                  onPressed: () {
                                    // _showNoteSheet(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "ตกลง",
                                    style: Styles.white18(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  void _showAddressSheet(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                width: screenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              Text('เลือกวันที่ต้องการรับของ',
                                  style: Styles.white24(context)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Expanded(
                                child: Scrollbar(
                              controller: _shippingScrollController,
                              thickness: 10,
                              thumbVisibility: true,
                              trackVisibility: true,
                              radius: Radius.circular(16),
                              child: ListView.builder(
                                controller: _shippingScrollController,
                                itemCount: shippingList.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.all(8),

                                                  elevation:
                                                      0, // Disable shadow
                                                  shadowColor: Colors
                                                      .transparent, // Ensure no shadow color
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.zero,
                                                      side: BorderSide.none),
                                                ),
                                                onPressed: () {
                                                  setModalState(() {
                                                    isShippingId =
                                                        shippingList[index]
                                                            .shippingId;
                                                  });
                                                  setState(() {
                                                    nameShipping =
                                                        shippingList[index]
                                                            .name;
                                                    addressShipping =
                                                        "${shippingList[index].address} ${shippingList[index].district} ${shippingList[index].subDistrict} ${shippingList[index].province} ${shippingList[index].postcode}";
                                                  });
                                                },
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                shippingList[
                                                                        index]
                                                                    .typeNameTH,
                                                                style: Styles
                                                                    .black18(
                                                                        context),
                                                              ),
                                                              shippingList[index]
                                                                          .name !=
                                                                      ''
                                                                  ? Text(
                                                                      shippingList[
                                                                              index]
                                                                          .name,
                                                                      style: Styles
                                                                          .black18(
                                                                              context),
                                                                    )
                                                                  : SizedBox(),
                                                              shippingList[index]
                                                                          .tel !=
                                                                      ''
                                                                  ? Text(
                                                                      shippingList[
                                                                              index]
                                                                          .tel,
                                                                      style: Styles
                                                                          .black18(
                                                                              context),
                                                                    )
                                                                  : SizedBox(),
                                                              shippingList[index]
                                                                          .address !=
                                                                      ""
                                                                  ? Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            "${shippingList[index].address} ${shippingList[index].district} ${shippingList[index].subDistrict}  ${shippingList[index].province} ${shippingList[index].postcode}",
                                                                            style:
                                                                                Styles.black18(context),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : SizedBox(),
                                                            ],
                                                          ),
                                                        ),
                                                        isShippingId ==
                                                                shippingList[
                                                                        index]
                                                                    .shippingId
                                                            ? Icon(
                                                                Icons
                                                                    .check_circle_outline_rounded,
                                                                color: Styles
                                                                    .success,
                                                                size: 25,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .keyboard_arrow_right_sharp,
                                                                color:
                                                                    Colors.grey,
                                                                size: 25,
                                                              )
                                                      ],
                                                    ),
                                                    Divider(
                                                      color: Colors.grey[200],
                                                      thickness: 1,
                                                      indent: 16,
                                                      endIndent: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }

  void _showTypeSheet(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height and scrolling
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return DraggableScrollableSheet(
            expand: false, // Allows dragging but does not expand fully
            initialChildSize: 0.6, // 60% of screen height
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                width: screenWidth * 0.95,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Styles.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 30,
                              ),
                              Text('เลือกประเภทของการเบิก',
                                  style: Styles.white24(context)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            Expanded(
                                child: Scrollbar(
                              controller: _typeScrollController,
                              thickness: 10,
                              thumbVisibility: true,
                              trackVisibility: true,
                              radius: Radius.circular(16),
                              child: ListView.builder(
                                controller: _typeScrollController,
                                itemCount: typeWithdraw.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.all(8),

                                                  elevation:
                                                      0, // Disable shadow
                                                  shadowColor: Colors
                                                      .transparent, // Ensure no shadow color
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.zero,
                                                      side: BorderSide.none),
                                                ),
                                                onPressed: () {
                                                  setModalState(() {
                                                    isWithdrawType =
                                                        typeWithdraw[index]
                                                            .value;
                                                  });
                                                  setState(() {
                                                    isWithdrawTypeText =
                                                        typeWithdraw[index]
                                                            .name;
                                                  });
                                                },
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          typeWithdraw[index]
                                                              .name,
                                                          style: Styles.black18(
                                                              context),
                                                        ),
                                                        isWithdrawType ==
                                                                typeWithdraw[
                                                                        index]
                                                                    .value
                                                            ? Icon(
                                                                Icons
                                                                    .check_circle_outline_rounded,
                                                                color: Styles
                                                                    .success,
                                                                size: 25,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .keyboard_arrow_right_sharp,
                                                                color:
                                                                    Colors.grey,
                                                                size: 25,
                                                              )
                                                      ],
                                                    ),
                                                    Divider(
                                                      color: Colors.grey[200],
                                                      thickness: 1,
                                                      indent: 16,
                                                      endIndent: 16,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        });
      },
    );
  }
}
