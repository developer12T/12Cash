import 'dart:io';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderMenuListVerticalCard extends StatefulWidget {
  final VoidCallback onDetailsPressed;
  final Product item;
  const OrderMenuListVerticalCard({
    super.key,
    required this.onDetailsPressed,
    required this.item,
  });

  @override
  State<OrderMenuListVerticalCard> createState() =>
      _OrderMenuListVerticalCardState();
}

class _OrderMenuListVerticalCardState extends State<OrderMenuListVerticalCard> {
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
      onPressed: widget.onDetailsPressed,
      child: Container(
        height: 350,
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(8), // Optional: Add rounded corners
              child: Image.network(
                '${ApiService.apiHost}/images/products/${widget.item.id}.webp',
                width: screenWidth / 3,
                height: screenWidth / 3,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: screenWidth / 3,
                    height: screenWidth / 3,
                    color: Colors.grey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hide_image, color: Colors.white, size: 50),
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
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: Styles.headerBlack20(context),
                          // overflow:
                          //     TextOverflow.ellipsis, // Truncate if too long
                          maxLines: 2, // Restrict to 1 line
                          softWrap: true, // Avoid wrapping
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'คงเหลือ ${widget.item.qtyPcs} ชิ้น',
                        style: Styles.grey18(context),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'รส${widget.item.flavour} ขนาด ${widget.item.size}',
                        style: Styles.grey18(context),
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
