import 'dart:async';
import 'dart:convert';
import 'package:_12sale_app/core/components/input/CustomTextInput.dart';
import 'package:_12sale_app/core/components/search/DropdownSearchGroup.dart';
import 'package:_12sale_app/core/page/dashboard/DashboardScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Location.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

class StoreAddressScreen extends StatefulWidget {
  TextEditingController storeAddressController;
  TextEditingController storePoscodeController;
  Location initialSelectedLocation;

  StoreAddressScreen({
    Key? key,
    required this.storeAddressController,
    required this.storePoscodeController,
    required this.initialSelectedLocation,
  }) : super(key: key);

  @override
  State<StoreAddressScreen> createState() => _StoreAddressScreenState();
}

class _StoreAddressScreenState extends State<StoreAddressScreen> {
  String province = "";
  String amphoe = "";
  String district = "";
  List<Location> districts = []; // Filtered list of districts
  List<Location> subDistricts = []; // Filtered list of districts
  List<Location> poscode = []; // Filtered list of districts
  Location? selectedDistrict;
  Location? selectedsubDistricts;
  Store? _storeData;
  Timer? _throttle;

  @override
  void initState() {
    super.initState();
    _loadStoreFromStorage();
    _loadDistrictsFromJson(widget.initialSelectedLocation.province);
    _loadSubDistrictsFromJson(widget.initialSelectedLocation.province,
        widget.initialSelectedLocation.amphoe);
    _loadPoscodeFromJson(
        widget.initialSelectedLocation.province,
        widget.initialSelectedLocation.amphoe,
        widget.initialSelectedLocation.district);
  }

  Future<void> _loadStoreFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the JSON string list from SharedPreferences
    String? jsonStore = prefs.getString("add_store");

    if (jsonStore != null) {
      setState(() {
        _storeData =
            (jsonStore == null ? null : Store.fromJson(jsonDecode(jsonStore)))!;
      });
      print(_storeData?.address);
      // province = _storeData.province!;
    }
  }

  Future<List<Location>> _fetchProvince(String filter) async {
    Map<String, List<Location>> groupedDatasets =
        await getProvince(filter, province);

    // Flatten the grouped results for display
    return groupedDatasets.values.expand((datalist) => datalist).toList();
  }

  Future<List<Location>> _fetchDistricts(String filter) async {
    Map<String, List<Location>> groupedDatasets =
        await getDistrict(filter, widget.initialSelectedLocation.province);

    // Flatten the grouped results for display
    return groupedDatasets.values.expand((datalist) => datalist).toList();
  }

  Future<List<Location>> _fetchSubDistricts(String filter) async {
    Map<String, List<Location>> groupedDatasets = await getSubDistrict(
        filter,
        widget.initialSelectedLocation.province,
        widget.initialSelectedLocation.amphoe);

    // Flatten the grouped results for display
    return groupedDatasets.values.expand((datalist) => datalist).toList();
  }

  Future<Map<String, List<Location>>> getSubDistrict(
      String filter, String province, String amphoe) async {
    try {
      // Load the JSON file for districts
      final String response = await rootBundle.loadString('data/location.json');
      final data = json.decode(response);

      // Filter and map JSON data to District model based on selected province and filter
      final List<Location> districts = (data as List)
          .map((json) => Location.fromJson(json))
          .where((district) =>
              district.province == province &&
              district.amphoe == amphoe &&
              district.district
                  .toLowerCase()
                  .contains(filter.toLowerCase())) // Apply both filters
          .toList();
      Map<String, List<Location>> groupedData =
          groupBy(districts, (Location location) => location.district);

      // Group districts by amphoe
      return groupedData;
    } catch (e) {
      print("Error occurred: $e");
      return {};
    }
  }

  Future<Map<String, List<Location>>> getProvince(
      String filter, String province) async {
    try {
      // Load the JSON file for districts
      final String response = await rootBundle.loadString('data/location.json');
      final data = json.decode(response);

      // Filter and map JSON data to District model based on selected province and filter
      final List<Location> districts = (data as List)
          .map((json) => Location.fromJson(json))
          .where((district) => district.province
              .toLowerCase()
              .contains(filter.toLowerCase())) // Apply both filters
          .toList();
      Map<String, List<Location>> groupedData =
          groupBy(districts, (Location location) => location.province);

      // Group districts by amphoe
      return groupedData;
    } catch (e) {
      print("Error occurred: $e");
      return {};
    }
  }

  Future<Map<String, List<Location>>> getDistrict(
      String filter, String province) async {
    try {
      // Load the JSON file for districts
      final String response = await rootBundle.loadString('data/location.json');
      final data = json.decode(response);

      // Filter and map JSON data to District model based on selected province and filter
      final List<Location> districts = (data as List)
          .map((json) => Location.fromJson(json))
          .where((district) =>
              district.province == province &&
              district.amphoe
                  .toLowerCase()
                  .contains(filter.toLowerCase())) // Apply both filters
          .toList();
      Map<String, List<Location>> groupedData =
          groupBy(districts, (Location location) => location.amphoe);

      // Group districts by amphoe
      return groupedData;
    } catch (e) {
      print("Error occurred: $e");
      return {};
    }
  }

  Future<void> _loadDistrictsFromJson(String province) async {
    // Load the JSON file for districts
    final String response = await rootBundle.loadString('data/location.json');
    final data = json.decode(response);

    // Filter districts by selected province
    if (mounted) {
      setState(() {
        districts = (data as List)
            .map((json) => Location.fromJson(json))
            .where((district) => district.province == province)
            .toList();

        // Reset selected district if not in filtered list
        selectedDistrict =
            districts.contains(selectedDistrict) ? selectedDistrict : null;
      });
    }
  }

  Future<void> _loadSubDistrictsFromJson(String province, String amphoe) async {
    // Load the JSON file for districts

    final String response = await rootBundle.loadString('data/location.json');
    final data = json.decode(response);

    // Filter districts by selected province
    if (mounted) {
      setState(() {
        subDistricts = (data as List)
            .map((json) => Location.fromJson(json))
            .where((subDistrict) =>
                subDistrict.province == province &&
                subDistrict.amphoe == amphoe)
            // .where((subDistrict) =>
            //     // (subDistrict.province == province) &&
            //     (subDistrict.amphoe == amphoe))
            .toList();

        // Reset selected district if not in filtered list
        selectedsubDistricts = subDistricts.contains(selectedsubDistricts)
            ? selectedsubDistricts
            : null;
      });
    }
  }

  Future<void> _loadPoscodeFromJson(
      String province, String amphoe, String district) async {
    // Load the JSON file for districts
    final String response = await rootBundle.loadString('data/location.json');
    final data = json.decode(response);

    // Filter districts by selected province
    if (mounted) {
      setState(() {
        poscode = (data as List)
            .map((json) => Location.fromJson(json))
            .where((poscode) =>
                poscode.province == province && poscode.amphoe == amphoe)
            // .where((subDistrict) =>
            //     // (subDistrict.province == province) &&
            //     (subDistrict.amphoe == amphoe))
            .toList();
        if (poscode.isEmpty) {
          widget.storePoscodeController.text = '';
        } else {
          setState(() {
            widget.storePoscodeController.text = poscode.first.zipcode!;
            _storeData = _storeData?.copyWithDynamicField(
                'postCode', poscode.first.zipcode!);
          });

          print(widget.storePoscodeController.text);
          widget.storePoscodeController.text = poscode.first.zipcode!;
          _saveStoreToStorage();
        }
      });
    }
  }

  Future<void> _saveStoreToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert Store object to JSON string
    String jsonStoreString = json.encode(_storeData!.toJson());

    // Save the JSON string list to SharedPreferences
    await prefs.setString('add_store', jsonStoreString);
  }

  void _onTextChanged(String text, String field) {
    // Set a new timer for 3 milliseconds
    setState(() {
      _storeData = _storeData?.copyWithDynamicField(field, text);
    });
    _saveStoreToStorage();
    // _throttle = Timer(const Duration(milliseconds: 3000), () {
    //   print(
    //       'Throttled text: $text'); // This will print the text with throttling

    //   // Cancel any existing timer to reset the delay
    //   if (_throttle?.isActive ?? false) {
    //     _throttle!.cancel();
    //   }
    // });
  }

  @override
  void dispose() {
    _throttle?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenWidth / 80),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 40),
              const SizedBox(width: 8),
              Text(
                " ${"store.store_address_screen.title".tr()}",
                style: Styles.headerBlack24(context),
              ),
            ],
          ),
          SizedBox(height: screenWidth / 80),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenWidth / 37),
                Customtextinput(
                  max: 36,
                  controller: widget.storeAddressController,
                  onChanged: (value) => _onTextChanged(value, 'address'),
                  context,
                  label:
                      '${"store.store_address_screen.input_address.name".tr()} *',
                  hint:
                      '${"store.store_address_screen.input_address.hint".tr()}',
                ),
                SizedBox(height: screenWidth / 37),
                DropdownSearchCustomGroup<Location>(
                  label:
                      '${"store.store_address_screen.input_province.name".tr()} *',
                  titleText:
                      "${"store.store_address_screen.input_province.name".tr()}",
                  fetchItems: (filter) async {
                    // Replace with your district fetching logic
                    return await _fetchProvince(filter);
                  },
                  groupByKey: (Location location) =>
                      location.province, // Group by amphoe
                  transformGroup: (String province) => Location(
                    amphoe: '',
                    province: province,
                    district: '',
                    zipcode: '',
                    id: '',
                    amphoeCode: '',
                    districtCode: '',
                    provinceCode: '',
                  ), // Transform group key into Location
                  itemAsString: (Location location) =>
                      location.province, // Display amphoe name
                  itemBuilder: (context, item, isSelected) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            " ${item.province}",
                            style: Styles.black18(context),
                          ),
                          selected: isSelected,
                        ),
                        Divider(
                          color: Colors.grey[200], // Color of the divider line
                          thickness: 1, // Thickness of the line
                          indent: 16, // Left padding for the divider line
                          endIndent: 16, // Right padding for the divider line
                        ),
                      ],
                    );
                  },
                  onChanged: (Location? selected) {
                    if (selected != null) {
                      setState(() {
                        province = selected.province;
                        widget.initialSelectedLocation.province =
                            selected.province;
                        widget.initialSelectedLocation.district = '';
                        widget.initialSelectedLocation.amphoe = '';
                        widget.storePoscodeController.text = '';
                        _storeData = _storeData?.copyWithDynamicField(
                            'province', selected.province);
                        _storeData =
                            _storeData?.copyWithDynamicField('district', '');
                        _storeData =
                            _storeData?.copyWithDynamicField('subDistrict', '');
                        _storeData =
                            _storeData?.copyWithDynamicField('postCode', '');
                      });
                      _saveStoreToStorage();
                    }
                  },
                  initialSelectedValue:
                      widget.initialSelectedLocation.province == ''
                          ? null
                          : widget.initialSelectedLocation,
                ),
                SizedBox(height: screenWidth / 37),
                DropdownSearchCustomGroup<Location>(
                  key: ValueKey('DistrictSearch-$province'),
                  label:
                      "${"store.store_address_screen.input_district.name".tr()}",
                  titleText:
                      "${"store.store_address_screen.input_district.name".tr()}",
                  fetchItems: (filter) async {
                    // Replace with your district fetching logic
                    return await _fetchDistricts(filter);
                  },
                  groupByKey: (Location location) =>
                      location.amphoe, // Group by amphoe
                  transformGroup: (String amphoe) => Location(
                    amphoe: amphoe,
                    province: '',
                    district: '',
                    zipcode: '',
                    id: '',
                    amphoeCode: '',
                    districtCode: '',
                    provinceCode: '',
                  ), // Transform group key into Location
                  itemAsString: (Location location) =>
                      location.amphoe, // Display amphoe name
                  itemBuilder: (context, item, isSelected) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            " ${item.amphoe}",
                            style: Styles.black18(context),
                          ),
                          selected: isSelected,
                        ),
                        Divider(
                          color: Colors.grey[200], // Color of the divider line
                          thickness: 1, // Thickness of the line
                          indent: 16, // Left padding for the divider line
                          endIndent: 16, // Right padding for the divider line
                        ),
                      ],
                    );
                  },
                  onChanged: (Location? selected) {
                    if (selected != null) {
                      setState(() {
                        amphoe = selected.amphoe;
                        widget.initialSelectedLocation.amphoe = selected.amphoe;
                        widget.storePoscodeController.text = '';
                        widget.initialSelectedLocation.district = '';
                        _storeData = _storeData?.copyWithDynamicField(
                            'district', selected.amphoe);
                        _storeData =
                            _storeData?.copyWithDynamicField('subDistrict', '');
                        _storeData =
                            _storeData?.copyWithDynamicField('postCode', '');
                      });

                      _saveStoreToStorage();
                    }
                  },
                  initialSelectedValue:
                      widget.initialSelectedLocation.amphoe == ''
                          ? null
                          : widget.initialSelectedLocation,
                ),
                SizedBox(height: screenWidth / 37),
                DropdownSearchCustomGroup<Location>(
                  key: ValueKey('SubDistrictDropdown-$province$amphoe'),
                  label:
                      "${"store.store_address_screen.input_subdistrict.name".tr()} *",
                  titleText:
                      "${"store.store_address_screen.input_subdistrict.name".tr()}",
                  fetchItems: (filter) async {
                    // Replace with your district fetching logic
                    return await _fetchSubDistricts(filter);
                  },
                  groupByKey: (Location location) =>
                      location.district, // Group by amphoe
                  transformGroup: (String district) => Location(
                    amphoe: '',
                    province: '',
                    district: district,
                    zipcode: '',
                    id: '',
                    amphoeCode: '',
                    districtCode: '',
                    provinceCode: '',
                  ), // Transform group key into Location
                  itemAsString: (Location location) =>
                      location.district, // Display amphoe name
                  itemBuilder: (context, item, isSelected) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            " ${item.district}",
                            style: Styles.black18(context),
                          ),
                          selected: isSelected,
                        ),
                        Divider(
                          color: Colors.grey[200], // Color of the divider line
                          thickness: 1, // Thickness of the line
                          indent: 16, // Left padding for the divider line
                          endIndent: 16, // Right padding for the divider line
                        ),
                      ],
                    );
                  },
                  onChanged: (Location? selected) {
                    if (selected != null) {
                      setState(() {
                        district = selected.district;
                        widget.initialSelectedLocation.district =
                            selected.district;
                        _storeData = _storeData?.copyWithDynamicField(
                            'subDistrict', selected.district);
                        _storeData = _storeData?.copyWithDynamicField(
                            'postCode', widget.storePoscodeController.text);
                      });
                      _loadPoscodeFromJson(
                          widget.initialSelectedLocation.province,
                          widget.initialSelectedLocation.amphoe,
                          widget.initialSelectedLocation.district);
                      _saveStoreToStorage();
                    }
                  },
                  initialSelectedValue:
                      widget.initialSelectedLocation.district == ''
                          ? null
                          : widget.initialSelectedLocation,
                ),
                SizedBox(height: screenWidth / 37),
                Customtextinput(
                  readonly: true,
                  key: ValueKey('postCode-$province'),
                  context,
                  onChanged: (value) => _onTextChanged(value, 'postCode'),
                  // readonly: true,
                  controller:
                      widget.storePoscodeController, // Pass the controller here
                  label:
                      "${"store.store_address_screen.input_poscode.name".tr()}",
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth / 80),
        ],
      ),
    );
  }
}
