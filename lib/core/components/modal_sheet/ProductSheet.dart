import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/filter/BadageFilter.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

import '../../../data/models/order/Product.dart';

class ProductSheet extends StatefulWidget {
  final Product product;
  final Function(Product product, String selectedSize, String selectedUnit,
      int count, double total) onAddToCart;

  const ProductSheet({
    required this.product,
    required this.onAddToCart,
    Key? key,
  }) : super(key: key);

  @override
  _ProductSheetState createState() => _ProductSheetState();
}

class _ProductSheetState extends State<ProductSheet> {
  String selectedSize = '';
  String selectedUnit = '';
  double price = 0.0;
  int count = 1;
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize price based on the first product unit if needed
    if (widget.product.listUnit.isNotEmpty) {
      selectedSize = widget.product.listUnit.first.name;
      selectedUnit = widget.product.listUnit.first.unit;
      price = widget.product.listUnit.first.price;
      total = price * count;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          width: screenWidth * 0.95,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildProductDetails(
                  context, scrollController, screenWidth, screenHeight),
              _buildFooter(context),
            ],
          ),
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
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('รายละเอียดสินค้า', style: Styles.white24(context)),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(
      BuildContext context,
      ScrollController scrollController,
      double screenWidth,
      double screenHeight) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        controller: scrollController,
        child: Container(
          height: screenHeight * 0.9,
          color: Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              children: [
                _buildProductImage(screenWidth),
                _buildProductInfo(),
                _buildSizeSelector(screenWidth),
                _buildPriceRow(),
                _buildTotalRow(),
                Divider(
                    color: Colors.grey[200],
                    thickness: 1,
                    indent: 16,
                    endIndent: 16),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            widget.product.image,
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: Styles.black24(context),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
                Text('กลุ่ม : ${widget.product.group}',
                    style: Styles.black16(context)),
                Text('แบรนด์ : ${widget.product.brand}',
                    style: Styles.black16(context)),
                Text('ขนาด : ${widget.product.size}',
                    style: Styles.black16(context)),
                Text('รสชาติ : ${widget.product.flavour}',
                    style: Styles.black16(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ข้อมูลเพิ่มเติม:', style: Styles.black18(context)),
        Text('รายละเอียด: ${widget.product.brand}',
            style: Styles.black16(context)),
        // Add more product information as necessary
      ],
    );
  }

  Widget _buildSizeSelector(double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.product.listUnit.map((data) {
                return Container(
                  margin: EdgeInsets.all(8),
                  child: badgeFilter(
                    child: Text(
                      data.name,
                      style: selectedSize == data.name
                          ? Styles.pirmary18(context)
                          : Styles.grey18(context),
                    ),
                    width: screenWidth / 4,
                    isSelected: selectedSize == data.name,
                    onTap: () {
                      setState(() {
                        selectedSize = data.name;
                        selectedUnit = data.unit;
                        price = data.price;
                        total = price * count;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('ราคา', style: Styles.black18(context)),
        Text(
          "฿${price.toStringAsFixed(2)} บาท",
          style: Styles.black18(context),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('รวม', style: Styles.black18(context)),
        Text('฿${total.toStringAsFixed(2)} บาท',
            style: Styles.black18(context)),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  if (count > 1) {
                    setState(() {
                      count--;
                      total = price * count;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.grey, width: 1)),
                  padding: const EdgeInsets.all(8),
                  backgroundColor: Colors.white,
                ),
                child: const Icon(Icons.remove, size: 24, color: Colors.grey),
              ),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                width: 75,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: Styles.black18(context),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    count++;
                    total = price * count;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(
                      side: BorderSide(color: Colors.grey, width: 1)),
                  padding: const EdgeInsets.all(8),
                  backgroundColor: Colors.white,
                ),
                child: const Icon(Icons.add, size: 24, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: ButtonFullWidth(
            text: 'ใส่ตะกร้า',
            blackGroundColor: Styles.primaryColor,
            textStyle: Styles.white18(context),
            onPressed: () {
              widget.onAddToCart(
                  widget.product, selectedSize, selectedUnit, count, total);
            },
          ),
        ),
      ],
    );
  }
}
