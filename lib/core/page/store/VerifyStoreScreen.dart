import 'dart:convert';
import 'package:_12sale_app/core/components/button/ShowPhotoButton.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyStoreScreen extends StatefulWidget {
  final Store storeData;

  VerifyStoreScreen({
    Key? key,
    required this.storeData,
  }) : super(key: key);

  @override
  State<VerifyStoreScreen> createState() => _VerifyStoreScreenState();
}

class _VerifyStoreScreenState extends State<VerifyStoreScreen> {
  Store? _storeData;
  String storeImagePath = "";
  String taxIdImagePath = "";
  String personalImagePath = "";
  @override
  void initState() {
    super.initState();
    _loadStoreFromStorage();
  }

  Future<void> _loadStoreFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Get the JSON string list from SharedPreferences
    String? jsonStore = prefs.getString("add_store");

    if (jsonStore != null) {
      setState(() {
        _storeData =
            // ignore: unnecessary_null_comparison
            (jsonStore == null ? null : Store.fromJson(jsonDecode(jsonStore)))!;
      });
      for (var value in _storeData!.imageList) {
        if (value.type == "store") {
          setState(() {
            storeImagePath = value.path;
          });
        } else if (value.type == 'tax') {
          setState(() {
            taxIdImagePath = value.path;
          });
        } else {
          setState(() {
            personalImagePath = value.path;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, size: 40),
              const SizedBox(width: 8),
              Text(
                "${"store.store_verify_screen.title".tr()}",
                style: Styles.headerBlack24(context),
              ),
            ],
          ),
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          Text.rich(
            TextSpan(
              text:
                  '${"store.store_verify_screen.name".tr()}', // This is the main text style
              style: Styles.headerBlack24(context),
              children: <TextSpan>[
                TextSpan(
                  text:
                      ' : ${widget.storeData.copyWith().name}', // Inline bold text
                  style: Styles.black24(context),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text:
                  '${"store.store_verify_screen.route".tr()}', // This is the main text style
              style: Styles.headerBlack18(context),
              children: <TextSpan>[
                TextSpan(
                  text: ' : ${widget.storeData.route}', // Inline bold text
                  style: Styles.black18(context),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text:
                  '${"store.store_verify_screen.shopType".tr()}', // This is the main text style
              style: Styles.headerBlack18(context),
              children: <TextSpan>[
                TextSpan(
                  text: ' : ${widget.storeData.typeName}', // Inline bold text
                  style: Styles.black18(context),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text:
                  '${"store.store_verify_screen.phone".tr()}', // This is the main text style
              style: Styles.headerBlack18(context),
              children: <TextSpan>[
                TextSpan(
                  text:
                      ' : ${widget.storeData.copyWith().tel}', // Inline bold text
                  style: Styles.black18(context),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text:
                  '${"store.store_verify_screen.taxId".tr()}', // This is the main text style
              style: Styles.headerBlack18(context),
              children: <TextSpan>[
                TextSpan(
                  text:
                      " : ${widget.storeData.taxId != '' ? widget.storeData.taxId : '-'}",
                  style: Styles.black18(context),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text:
                  '${"store.store_verify_screen.lineId".tr()}', // This is the main text style
              style: Styles.headerBlack18(context),
              children: <TextSpan>[
                TextSpan(
                  text:
                      ' : ${widget.storeData.lineId != '' ? widget.storeData.lineId : '-'}', // Inline bold text
                  style: Styles.black18(context),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text:
                  '${"store.store_verify_screen.note".tr()}', // This is the main text style
              style: Styles.headerBlack18(context),
              children: <TextSpan>[
                TextSpan(
                  text:
                      ' : ${widget.storeData.note != '' ? widget.storeData.note : '-'}', // Inline bold text
                  style: Styles.black18(context),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              text:
                  '${"store.store_verify_screen.address".tr()}', // This is the main text style
              style: Styles.headerBlack18(context),
              children: <TextSpan>[
                TextSpan(
                  text:
                      ' : ${widget.storeData.address} ${widget.storeData.province != 'กรุงเทพมหานคร' ? 'ต.' : 'แขวง'}${widget.storeData.subDistrict} ${widget.storeData.province != 'กรุงเทพมหานคร' ? 'อ.' : 'เขต'}${widget.storeData.district} ${widget.storeData.province != 'กรุงเทพมหานคร' ? 'จ.' : ''}${widget.storeData.province} ${widget.storeData.postCode}', // Inline bold text
                  style: Styles.black18(context),
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth / 37),
          Row(
            children: [
              const Icon(Icons.photo, size: 40),
              const SizedBox(width: 8),
              Text(
                "${"store.store_verify_screen.title_image".tr()}",
                style: Styles.headerBlack24(context),
              ),
            ],
          ),
          Divider(
            thickness: 1,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: screenWidth / 37),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ShowPhotoButton(
                label: "${"store.store_verify_screen.image_store".tr()}",
                icon: Icons.image_not_supported_outlined,
                imagePath: storeImagePath != "" ? storeImagePath : null,
              ),
              ShowPhotoButton(
                label: "${"store.store_verify_screen.image_taxId".tr()}",
                icon: Icons.image_not_supported_outlined,
                imagePath: taxIdImagePath != "" ? taxIdImagePath : null,
              ),
              ShowPhotoButton(
                label: "${"store.store_verify_screen.image_identify".tr()}",
                icon: Icons.image_not_supported_outlined,
                imagePath: personalImagePath != "" ? personalImagePath : null,
              )
            ],
          )
        ],
      ),
    );
  }
}
