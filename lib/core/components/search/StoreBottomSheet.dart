import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class StoreBottomSheet extends StatefulWidget {
  final List<Store> storeList;
  final String? selectedStoreId;
  final Function(Store selectedStore) onStoreSelected;

  const StoreBottomSheet({
    super.key,
    required this.storeList,
    required this.onStoreSelected,
    this.selectedStoreId,
  });

  @override
  State<StoreBottomSheet> createState() => _StoreBottomSheetState();
}

class _StoreBottomSheetState extends State<StoreBottomSheet> {
  late TextEditingController _searchController;
  // late List<Store> _filteredStores;
  final ScrollController _scrollController = ScrollController();
  String? _tempSelectedStoreId;

  List<Store> _stores = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMore = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadStores();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);
    // _filteredStores = List.from(widget.storeList);
    _tempSelectedStoreId = widget.selectedStoreId;
  }

  // void _filterStores(String query) {
  //   setState(() {
  //     _filteredStores = widget.storeList.where((store) {
  //       final lower = query.toLowerCase();
  //       return store.name.toLowerCase().contains(lower) ||
  //           store.address.toLowerCase().contains(lower) ||
  //           store.province.toLowerCase().contains(lower) ||
  //           store.tel.toLowerCase().contains(lower) ||
  //           store.typeName.toLowerCase().contains(lower);
  //     }).toList();
  //   });
  // }

  Future<void> _loadStores({bool reset = false}) async {
    if (_isLoading || (!_hasMore && !reset)) return;

    setState(() => _isLoading = true);
    if (reset) {
      _page = 1;
      _stores.clear();
      _hasMore = true;
    }

    try {
      final fetched = await StoreService.fetchStores(
        area: User.area,
        page: _page,
        q: _query,
      );
      setState(() {
        _stores.addAll(fetched);
        _isLoading = false;
        _hasMore = fetched.isNotEmpty;
        if (_hasMore) _page++;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error fetching stores: $e");
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadStores();
    }
  }

  void _onSearch(String query) {
    _query = query.trim();
    _loadStores(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      builder: (context, controller) {
        return Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            Expanded(
              child: _isLoading && _stores.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _stores.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _stores.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: SizedBox(),
                          );
                        }
                        final store = _stores[index];
                        final isSelected =
                            store.storeId == _tempSelectedStoreId;
                        return _buildStoreTile(context, store, isSelected);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearch,
          autofocus: true,
          style: Styles.black18(context),
          decoration: InputDecoration(
            hintStyle: Styles.grey18(context),
            hintText: 'ค้นหาร้านค้า...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
          ),
        ),
      );

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Styles.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: Colors.white, size: 30),
              const SizedBox(width: 8),
              Text('เลือกร้านค้า', style: Styles.white24(context)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Widget _buildSearchBar() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: TextField(
  //       controller: _searchController,
  //       autofocus: true,
  //       onChanged: _filterStores,
  //       style: Styles.black18(context),
  //       decoration: InputDecoration(
  //         hintText: "ค้นหาร้านค้า...",
  //         hintStyle: Styles.grey18(context),
  //         prefixIcon: const Icon(Icons.search),
  //         border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
  //         filled: true,
  //         fillColor: Colors.white,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStoreTile(BuildContext context, Store store, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          setState(() {
            _tempSelectedStoreId = store.storeId;
          });
          widget.onStoreSelected(store);
          Navigator.pop(context); // auto close
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.storeId, style: Styles.black18(context)),
            if (store.typeName.isNotEmpty)
              Text(store.typeName, style: Styles.black18(context)),
            if (store.name.isNotEmpty)
              Text(store.name, style: Styles.black18(context)),
            if (store.tel.isNotEmpty)
              Text(store.tel, style: Styles.black18(context)),
            if (store.address.isNotEmpty)
              Text(
                "${store.address} ${store.district} ${store.subDistrict} ${store.province} ${store.postCode}",
                style: Styles.black18(context),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                isSelected
                    ? Icons.check_circle_outline_rounded
                    : Icons.keyboard_arrow_right_sharp,
                color: isSelected ? Styles.success : Colors.grey,
              ),
            ),
            Divider(color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}

class StoreService {
  static Future<List<Store>> fetchStores({
    String? area,
    String? route,
    String? type = 'all',
    int page = 1,
    int limit = 20,
    String? q,
    String channel = 'cash', // ตัวอย่าง channel
  }) async {
    ApiService apiService = ApiService();
    await apiService.init();

    var response = await apiService.request(
      endpoint:
          'api/cash/store/getStorePage?area=${User.area}&type&page=${page}&limit=${limit}&q=${q}',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => Store.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load stores');
    }
  }
}
