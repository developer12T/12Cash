import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

class BadageFilter {
  static void showFilterSheet({
    required BuildContext context,
    required String title,
    required String title2,
    required List<String> itemList,
    required List<String> selectedItems,
    required Function(String, bool) onItemSelected,
    required VoidCallback onClear,
    required VoidCallback onSearch,
    // required Future<void> Function(List<String> groups)
    //     onSearch // Updated callback type
  }) {
    double screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  width: screenWidth * 0.95,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, title),
                      Expanded(
                        child: _buildItemList(title2, context, itemList,
                            selectedItems, setModalState, onItemSelected),
                      ),
                      _buildFooter(context, setModalState, onClear, onSearch)
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static Widget _buildHeader(BuildContext context, String title) {
    return Container(
      decoration: const BoxDecoration(
        color: Styles.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 16),
          Text(title, style: Styles.white24(context)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  static Widget _buildItemList(
      String title2,
      BuildContext context,
      List<String> itemList,
      List<String> selectedItems,
      StateSetter setModalState,
      Function(String, bool) onItemSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 16),
              Text(title2, style: Styles.black24(context)),
            ],
          ),
          Divider(
              color: Colors.grey[200], thickness: 1, indent: 16, endIndent: 16),
          if (itemList.isEmpty && title2 != 'กลุ่ม')
            Center(
              child: Text(
                "กรุณาเลือกกลุ่มก่อน",
                style: Styles.grey18(context),
              ),
            ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: itemList.map((data) {
              bool isSelected = selectedItems.contains(data);
              return ChoiceChip(
                showCheckmark: false,
                label: Text(
                  data,
                  style: isSelected
                      ? Styles.pirmary18(context)
                      : Styles.black18(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                selected: isSelected,
                side: BorderSide(
                  color: isSelected ? Styles.primaryColor : Colors.black,
                  width: 1.5,
                ),
                backgroundColor: Colors.white,
                selectedColor: Colors.white,
                onSelected: (selected) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      setModalState(() => onItemSelected(data, selected));
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static Widget _buildFooter(BuildContext context, StateSetter setModalState,
      VoidCallback onClear, VoidCallback onSearch) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: ButtonFullWidth(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    setModalState(() {
                      onClear();
                    });
                    Navigator.of(context).pop();
                  }
                });
              },
              text: 'ล้างข้อมูล',
              blackGroundColor: Styles.secondaryColor,
              textStyle: Styles.black18(context),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ButtonFullWidth(
              onPressed: () async {
                onSearch();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                });
              },
              text: 'ค้นหา',
              blackGroundColor: Styles.primaryColor,
              textStyle: Styles.white18(context),
            ),
          ),
        ],
      ),
    );
  }

// Define the reusable BadgeFilter widget
}

Widget badgeFilter({
  required Widget child,
  required double width,
  bool openIcon = true,
  bool isSelected = false,
  VoidCallback? onTap, // Optional callback for tap events
}) {
  return GestureDetector(
    onTap: onTap, // Tap action can be passed in as an argument
    child: Container(
      margin: const EdgeInsets.all(8.0),
      width: width,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Styles.primaryColor : Colors.black,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child:
                      child), // The child widget will expand within the available space
              if (openIcon) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: isSelected ? Styles.primaryColor : Colors.black,
                ),
              ],
            ],
          ),
        ],
      ),
    ),
  );
}
