import 'dart:io';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class OrderMenuListCard extends StatefulWidget {
  Product product;
  void Function()? onTap;
  OrderMenuListCard({
    required this.product,
    super.key,
    this.onTap,
  });

  @override
  State<OrderMenuListCard> createState() => _OrderMenuListCardState();
}

class _OrderMenuListCardState extends State<OrderMenuListCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        elevation: 0, // Disable shadow
        shadowColor: Colors.transparent, // Ensure no shadow color
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // No rounded corners
          side: BorderSide.none, // Remove border
        ),
      ),
      onPressed: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              8), // Optional: Add rounded corners
                          child: Image.network(
                            '${ApiService.image}/images/products/${widget.product.id}.webp',
                            width: screenWidth / 4,
                            height: screenWidth / 4,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: screenWidth / 4,
                                height: screenWidth / 4,
                                color: Colors.grey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.hide_image,
                                        color: Colors.white, size: 50),
                                    Text(
                                      "ไม่มีภาพ",
                                      style: Styles.white18(context),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${widget.product.name}',
                                      style: Styles.headerBlack20(context),
                                      overflow: TextOverflow
                                          .ellipsis, // Truncate if too long
                                      maxLines: 2, // Restrict to 1 line
                                      softWrap: false, // Avoid wrapping
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${widget.product.id}',
                                    style: Styles.grey18(context),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'รส${widget.product.flavour} ขนาด ${widget.product.size}',
                                    style: Styles.grey18(context),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'น้ำหนักสุทธิ ${widget.product.weightNet} กรัม น้ำหนักรวม ${widget.product.weightGross} กรัม',
                                    style: Styles.grey18(context),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'คงเหลือ ${widget.product.qtyPcs} ชิ้น',
                                    style: Styles.grey18(context),
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}
