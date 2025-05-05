import 'dart:io';

import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/order/Product.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

class ProductStockCard extends StatefulWidget {
  Product product;
  void Function()? onTap;
  ProductStockCard({
    required this.product,
    super.key,
    this.onTap,
  });

  @override
  State<ProductStockCard> createState() => _ProductStockCardState();
}

class _ProductStockCardState extends State<ProductStockCard> {
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
                            'https://jobbkk.com/upload/employer/0D/53D/03153D/images/202045.webp',
                            width: screenWidth / 4,
                            height: screenWidth / 4,
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
                                      style: Styles.headerBlack24(context),
                                      overflow: TextOverflow
                                          .ellipsis, // Truncate if too long
                                      maxLines: 1, // Restrict to 1 line
                                      softWrap: false, // Avoid wrapping
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${widget.product.totalQtyPcs} ชิ้น | ${widget.product.totalQtyCtn} หีบ',
                                    style: Styles.grey18(context),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${widget.product.flavour} | ${widget.product.size}',
                                    style: Styles.grey18(context),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Net ${widget.product.weightNet} | Gross ${widget.product.weightGross}',
                                    style: Styles.grey18(context),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${widget.product.type}',
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
