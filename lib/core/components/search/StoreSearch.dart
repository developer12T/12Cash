import 'dart:async';
import 'dart:convert';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/search/StoreFilterLocal.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:collection/collection.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StoreSearch extends StatefulWidget {
  final Function(Store?) onStoreSelected;
  const StoreSearch({
    required this.onStoreSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<StoreSearch> createState() => _StoreSearchState();
}

class _StoreSearchState extends State<StoreSearch> {
  Store? _selectedStore;
  List<Store> storeList = [];
  bool _loading = true;
  List<StoreFavoriteLocal> _storeFavoriteLocal = [];

  @override
  void initState() {
    super.initState();
    _loadStoreFromStorage();
  }

  Future<void> _loadStoreFromStorage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? jsonStore = prefs.getStringList('StoreFavoriteLocal');
      if (jsonStore != null) {
        setState(() {
          // Decode each JSON string and convert it to an Order object
          _storeFavoriteLocal = jsonStore
              .map((jsonStore) =>
                  StoreFavoriteLocal.fromJson(jsonDecode(jsonStore)))
              .toList();
        });
        print("_storeFavoriteLocal ${_storeFavoriteLocal}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> _saveStoreFavoriteStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convert the list of Order objects to a list of maps (JSON)
    List<String> storeFavorites =
        _storeFavoriteLocal.map((store) => jsonEncode(store.toJson())).toList();

    // Save the JSON string list to SharedPreferences
    await prefs.setStringList('StoreFavoriteLocal', storeFavorites);
  }

  Future<List<Store>> getStores(String filter) async {
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
    final storeState = Provider.of<StoreLocal>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    return DropdownSearch<Store>(
      // clearButtonProps: ClearButtonProps(isVisible: true),
      asyncItems: (String filter) =>
          getStores(filter), // Filters data as user types
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
          labelText: 'ค้นหาร้านค้า',
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

      onChanged: (Store? data) {
        if (data != null) {
          storeState.addStoreFavorite(data);
          if (_storeFavoriteLocal
              .any((element) => element.store_id == data.storeId)) {
            _storeFavoriteLocal
                .firstWhere((element) => element.store_id == data.storeId)
                .count++;
          } else {
            _storeFavoriteLocal.add(
              StoreFavoriteLocal(
                store_id: data.storeId,
                count: 1,
              ),
            );
          }

          _saveStoreFavoriteStorage();
          setState(() {
            _selectedStore = data;
          });
          widget.onStoreSelected(data);
        }
      },
      selectedItem: _selectedStore,
      popupProps: PopupPropsMultiSelection.modalBottomSheet(
        favoriteItemProps: FavoriteItemProps(
          showFavoriteItems: true,
          favoriteItems: (us) {
            if (_storeFavoriteLocal.isNotEmpty) {
              if (_storeFavoriteLocal == null) {
                return [];
              }

              final sortedFavorites = (_storeFavoriteLocal
                    ..sort((a, b) {
                      return b.count.compareTo(a.count); // Descending order
                    }))
                  .take(4)
                  .toList();
              // Limit to 4 items
              // // Sort the favorite list by `count` in descending order if `count` exists
              // final sortedFavorites = _storeFavoriteLocal
              //   ..sort((a, b) {
              //     final aCount = a.count;
              //     final bCount = b.count;
              //     return bCount.compareTo(aCount);
              //   });
              // if (sortedFavorites.length > 5) {
              //   print("sortedFavorites1 ${sortedFavorites[0].count}");
              //   print("sortedFavorites2  ${sortedFavorites[1].count}");
              //   print("sortedFavorites3  ${sortedFavorites[2].count}");
              //   print("sortedFavorites4  ${sortedFavorites[3].count}");
              //   print("sortedFavorites5  ${sortedFavorites[4].count}");
              //   print("sortedFavorites Length  ${sortedFavorites.length}");
              //   // print(sortedFavorites.length);
              // }

              final filteredStores = us
                  .where((store) {
                    return sortedFavorites
                        .any((favorite) => favorite.store_id == store.storeId);
                  })
                  .take(4)
                  .toList();

              return filteredStores;
            } else {
              if (storeState.storesFavoriteList == null) {
                return [];
              }
              // Sort the favorite list by `count` in descending order if `count` exists
              // final sortedFavorites = storeState.storesFavoriteList
              //   ..sort((a, b) {
              //     final aCount = a.count;
              //     final bCount = b.count;
              //     return bCount.compareTo(aCount);
              //   });
              // print("sortedFavorites ${sortedFavorites}");

              // sortedFavorites
              //     .where((e) => us.contains(e))
              //     .take(4)
              //     .toList()
              //     .sort((a, b) => b.count
              //         .compareTo(a.count)); // Sort by `count` descending;;

              final sortedFavorites = (storeState.storesFavoriteList
                    ..sort((a, b) {
                      return b.count.compareTo(a.count); // Descending order
                    }))
                  .take(4)
                  .toList();

              final filteredStores = us
                  .where((store) {
                    return sortedFavorites
                        .any((favorite) => favorite.store_id == store.storeId);
                  })
                  .take(4)
                  .toList();

              return filteredStores;
            }
          },
          favoriteItemBuilder: (context, item, isSelected) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(16),
                color: Styles.primaryColor,
              ),
              child: Row(
                children: [
                  Text(
                    item.name,
                    textAlign: TextAlign.center,
                    style: Styles.white18(context),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 8)),
                  isSelected
                      ? const Icon(Icons.check_box_outlined)
                      : const SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
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
          child: Text('ค้นหาร้านค้า', style: Styles.white18(context)),
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
                      text: '${item.name} \n',
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
                        text: 'เส้นทาง : ', style: Styles.black18(context)),
                    TextSpan(
                        text: '${item.route} \n',
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
                      style: Styles.black18(context),
                    ),
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
