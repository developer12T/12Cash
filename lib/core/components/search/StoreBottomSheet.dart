import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Store.dart';
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
  late List<Store> _filteredStores;
  final ScrollController _scrollController = ScrollController();
  String? _tempSelectedStoreId;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredStores = List.from(widget.storeList);
    _tempSelectedStoreId = widget.selectedStoreId;
  }

  void _filterStores(String query) {
    setState(() {
      _filteredStores = widget.storeList.where((store) {
        final lower = query.toLowerCase();
        return store.name.toLowerCase().contains(lower) ||
            store.address.toLowerCase().contains(lower) ||
            store.province.toLowerCase().contains(lower) ||
            store.tel.toLowerCase().contains(lower) ||
            store.typeName.toLowerCase().contains(lower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thickness: 8,
                radius: const Radius.circular(16),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = _filteredStores[index];
                    final isSelected = store.storeId == _tempSelectedStoreId;
                    return _buildStoreTile(context, store, isSelected);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: _filterStores,
        style: Styles.black18(context),
        decoration: InputDecoration(
          hintText: "ค้นหาร้านค้า...",
          hintStyle: Styles.grey18(context),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

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
