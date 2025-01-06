import 'dart:async';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StoreSearch extends StatefulWidget {
  final Function(Store?) onStoreSelected;
  const StoreSearch({super.key, required this.onStoreSelected});

  @override
  State<StoreSearch> createState() => _StoreSearchState();
}

class _StoreSearchState extends State<StoreSearch> {
  Store? _selectedStore;
  List<Store> storeList = [];
  bool _loading = true;

  Future<List<Store>> getStores() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/store/getStore?area=${User.area}&type=all', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("ApiService: $response}");

      // // Checking if data is not null and returning the list of CustomerModel
      if (response != null) {
        setState(() {
          _loading = false;
        });
        return Store.fromJsonList(response.data['data']);
      }
      return [];
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return DropdownSearch<Store>(
      asyncItems: (String filter) => getStores(), // Filters data as user types
      dropdownButtonProps: DropdownButtonProps(
        icon: Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: Icon(
            Icons.search,
            size: screenWidth / 20,
            color: Colors.black54,
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        baseStyle: Styles.black18(context),
        dropdownSearchDecoration: InputDecoration(
          hintText: "ค้นหาร้านค้า",
          hintStyle: Styles.grey18(context),
          labelStyle: Styles.black18(context),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 100, 100, 100),
              width: 1,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              color: Color.fromARGB(255, 100, 100, 100),
              width: 1,
            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
          // focusedBorder: const OutlineInputBorder(
          //   borderRadius: BorderRadius.all(Radius.circular(8)),
          //   borderSide: BorderSide(
          //     color: Colors.indigo,
          //     width: 1.5,
          //   ),
          // ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
      ),
      onChanged: (Store? data) => setState(() {
        setState(() {
          _selectedStore = data;
        });
        widget.onStoreSelected(data); // Notify parent about selection
      }),
      selectedItem: _selectedStore,
      popupProps: PopupProps.menu(
        searchFieldProps: TextFieldProps(style: Styles.black18(context)),
        showSearchBox: true, // Disable the popup search box
        itemBuilder: _customCustomer, // Custom item builder for dropdown items
        // constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _customCustomer(BuildContext context, Store item, bool isSelected) {
    return Skeletonizer(
      effect: const PulseEffect(
          from: Colors.grey,
          to: Color.fromARGB(255, 211, 211, 211),
          duration: Duration(seconds: 1)),
      enableSwitchAnimation: true,
      enabled: _loading,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            padding: const EdgeInsets.symmetric(vertical: 0),
            decoration: !isSelected
                ? null
                : BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
            child: ListTile(
              selected: isSelected,
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${item.name} ${item.route}\n',
                      style: Styles.kanit(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Styles.primaryColor,
                          fontSize: 24),
                    ),
                    TextSpan(
                        text: 'รหัสร้าน : ', style: Styles.black18(context)),
                    TextSpan(
                        text: '${item.storeId} \n',
                        style: Styles.black18(context)),
                    TextSpan(
                        text: 'ที่อยู่ : ', style: Styles.black18(context)),
                    TextSpan(
                        text: '${item.address}',
                        style: Styles.black18(context)),
                    TextSpan(text: ' ', style: Styles.black18(context)),
                    TextSpan(
                        text:
                            '${item.subDistrict} ${item.district} ${item.province} ${item.postCode}',
                        style: Styles.black18(context)),
                  ],
                ),
              ),
            ),
          ),
          const Divider(
            color: Colors.grey, // Color of the divider line
            thickness: 1, // Thickness of the line
            indent: 16, // Left padding for the divider line
            endIndent: 16, // Right padding for the divider line
          ),
        ],
      ),
    );
  }
}
