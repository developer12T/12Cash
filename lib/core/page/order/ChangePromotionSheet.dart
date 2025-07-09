import 'package:flutter/material.dart';
import '../../../data/models/order/Promotion.dart';
import 'package:_12sale_app/core/styles/style.dart';

class ChangePromotionSheet extends StatefulWidget {
  final String proId;
  final String proName;
  final String proType;
  final List<PromotionListItem> availablePromotions;
  final PromotionListItem currentItem;
  final int total;
  final int totalShow;
  final String unitPromotionText;

  const ChangePromotionSheet({
    Key? key,
    required this.proId,
    required this.proName,
    required this.proType,
    required this.availablePromotions,
    required this.currentItem,
    required this.total,
    required this.totalShow,
    required this.unitPromotionText,
  }) : super(key: key);

  @override
  State<ChangePromotionSheet> createState() => _ChangePromotionSheetState();
}

class _ChangePromotionSheetState extends State<ChangePromotionSheet> {
  late List<PromotionListItem> filteredPromotions;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    filteredPromotions = widget.availablePromotions;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.98,
      builder: (context, scrollController) {
        return Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  color: Styles.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              color: Colors.white, size: 30),
                          SizedBox(width: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text('${widget.proName}',
                                    style: Styles.white16(context)),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),
                          Text('(${widget.proId})',
                              style: Styles.white16(context)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //   child: Text(
              //     "เลือกสินค้าโปรโมชั่น (ค้นหา/กรองได้)",
              //     style: Styles.black18(context),
              //   ),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: TextField(
              //     decoration: InputDecoration(
              //       hintText: "ค้นหาชื่อสินค้า",
              //       prefixIcon: Icon(Icons.search),
              //       border: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(8)),
              //     ),
              //     onChanged: (value) {
              //       setState(() {
              //         searchText = value;
              //         filteredPromotions =
              //             widget.availablePromotions.where((item) {
              //           return item.name
              //               .toLowerCase()
              //               .contains(searchText.toLowerCase());
              //         }).toList();
              //       });
              //     },
              //   ),
              // ),
              const SizedBox(height: 8),
              Divider(color: Colors.black, indent: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filteredPromotions.length,
                  itemBuilder: (context, index) {
                    final promo = filteredPromotions[index];
                    final isCurrent = promo.id == widget.currentItem.id;

                    return Column(
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://apiHost/images/products/${promo.id}.webp',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey,
                                child: Icon(Icons.hide_image,
                                    color: Colors.white, size: 30),
                              ),
                            ),
                          ),
                          title:
                              Text(promo.name, style: Styles.black18(context)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('รหัส: ${promo.id}',
                                  style: Styles.grey16(context)),
                              if (promo.group.isNotEmpty)
                                Text('กลุ่ม: ${promo.group}',
                                    style: Styles.grey16(context)),
                              if (promo.size.isNotEmpty)
                                Text('ขนาด: ${promo.size}',
                                    style: Styles.grey16(context)),
                            ],
                          ),
                          trailing: isCurrent
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : Icon(Icons.circle_outlined, color: Colors.grey),
                          selected: isCurrent,
                          onTap: isCurrent
                              ? null
                              : () {
                                  // กลับค่า item ใหม่
                                  Navigator.of(context).pop(
                                    promo.copyWith(
                                      proId: widget.currentItem.proId,
                                      proName: widget.currentItem.proName,
                                      proType: widget.currentItem.proType,
                                      qty: widget.currentItem.qty,
                                    ),
                                  );
                                },
                        ),
                        Divider(
                            color: Colors.grey[200],
                            thickness: 1,
                            indent: 16,
                            endIndent: 16),
                      ],
                    );
                  },
                ),
              ),
              Container(
                color: Styles.primaryColor,
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("จำนวนที่เหลือ", style: Styles.white24(context)),
                        Text("${widget.total} ${widget.unitPromotionText}",
                            style: Styles.white24(context)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("จำนวนที่เลือกได้",
                            style: Styles.white24(context)),
                        Text("${widget.totalShow} ${widget.unitPromotionText}",
                            style: Styles.white24(context)),
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
  }
}
