import 'dart:async';
import 'dart:convert';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/search/StoreFilterLocal.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductSearch extends StatefulWidget {
  final Function(Product?) onStoreSelected;
  const ProductSearch({
    required this.onStoreSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<ProductSearch> {
  Product? _selectedStore;
  List<Product> storeList = [];
  bool _loading = true;
  // List<StoreFavoriteLocal> _storeFavoriteLocal = [];

  @override
  void initState() {
    super.initState();
    // _loadStoreFromStorage();
  }

  // Future<void> _loadStoreFromStorage() async {
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     List<String>? jsonStore = prefs.getStringList('StoreFavoriteLocal');
  //     if (jsonStore != null) {
  //       setState(() {
  //         // Decode each JSON string and convert it to an Order object
  //         _storeFavoriteLocal = jsonStore
  //             .map((jsonStore) =>
  //                 StoreFavoriteLocal.fromJson(jsonDecode(jsonStore)))
  //             .toList();
  //       });
  //       print("_storeFavoriteLocal ${_storeFavoriteLocal}");
  //     }
  //   } catch (e) {
  //     print("Error occurred: $e");
  //   }
  // }

  // Future<void> _saveStoreFavoriteStorage() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // Convert the list of Order objects to a list of maps (JSON)
  //   List<String> storeFavorites =
  //       _storeFavoriteLocal.map((store) => jsonEncode(store.toJson())).toList();

  //   // Save the JSON string list to SharedPreferences
  //   await prefs.setStringList('StoreFavoriteLocal', storeFavorites);
  // }

  Future<List<Product>> getData() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/product/get?type=sale', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      print("ApiService: $response}");
      // // Checking if data is not null and returning the list of CustomerModel
      if (response != null) {
        setState(() {
          _loading = false;
        });
        return Product.fromJsonList(response.data['data']);
      }
      return [];
    } catch (e) {
      print("Error occurred: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeState = Provider.of<StoreLocal>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return DropdownSearch<Product>(
      clearButtonProps: ClearButtonProps(isVisible: true),
      asyncItems: (String filter) => getData(), // Filters data as user types
      dropdownButtonProps: DropdownButtonProps(
        color: Colors.white,
        icon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
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
          fillColor: Colors.white,
          // prefixIcon: widget.icon,
          labelText: 'ค้นหาสินค้า',
          labelStyle: Styles.grey18(context),
          // hintText: widget.hint,
          hintStyle: Styles.grey18(context),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Colors.blue, width: 1.5),
          ),
        ),
      ),

      onChanged: (Product? data) {
        if (data != null) {
          // storeState.addStoreFavorite(data);
          //   if (_storeFavoriteLocal
          //       .any((element) => element.store_id == data.storeId)) {
          //     _storeFavoriteLocal
          //         .firstWhere((element) => element.store_id == data.storeId)
          //         .count++;
          //   } else {
          //     _storeFavoriteLocal.add(
          //       StoreFavoriteLocal(
          //         store_id: data.storeId,
          //         count: 1,
          //       ),
          //     );
          //   }

          //   _saveStoreFavoriteStorage();
          //   setState(() {
          //     _selectedStore = data;
          //   });
          //   widget.onStoreSelected(data);
          // }
        }
      },
      selectedItem: _selectedStore,
      popupProps: PopupPropsMultiSelection.modalBottomSheet(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: screenWidth * 0.95, // Set maximum width
        ),
        title: Container(
          decoration: const BoxDecoration(
            color: Styles.primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('ค้นหาสินค้า', style: Styles.white18(context)),
        ),
        showSearchBox: true,
        itemBuilder: _customCustomer,
        searchFieldProps: TextFieldProps(
          style: Styles.black18(context),
          autofocus: true,
        ),
      ),
    );
  }

  Widget _customCustomer(BuildContext context, Product item, bool isSelected) {
    double screenWidth = MediaQuery.of(context).size.width;
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
              // minTileHeight: screenWidth / 2.5,
              leading: ClipRRect(
                borderRadius:
                    BorderRadius.circular(8), // Optional: Add rounded corners
                child: Image.network(
                  'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                  width: screenWidth / 4,
                  // height: screenWidth / 3,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
              selected: isSelected,
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${item.name} \n',
                      style: Styles.kanit(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Styles.primaryColor,
                          fontSize: 24),
                    ),
                    TextSpan(
                        text: 'รหัสร้าน : ', style: Styles.black18(context)),
                    TextSpan(
                        text: '${item.id} \n', style: Styles.black18(context)),
                    TextSpan(text: 'กลุ่ม : ', style: Styles.black18(context)),
                    TextSpan(
                        text: '${item.group} \n',
                        style: Styles.black18(context)),
                    TextSpan(text: 'แบรนด์ : ', style: Styles.black18(context)),
                    TextSpan(
                        text: '${item.brand}', style: Styles.black18(context)),
                    // TextSpan(text: ' ', style: Styles.black18(context)),
                    // TextSpan(
                    //   text:
                    //       '${item.subDistrict} ${item.district} ${item.province} ${item.postCode}',
                    //   style: Styles.black18(context),
                    // ),
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
