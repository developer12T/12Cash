import 'package:flutter/material.dart';

class BoxShadowCustom extends StatelessWidget {
  final Widget child;
  Color? color;
  Color borderColor;
  Color shadowColor;
  BoxShadowCustom({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.borderColor = Colors.white,
    this.shadowColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        color: color, // Set background color if needed
        borderRadius: BorderRadius.circular(
            16), // Rounded corners for the outer container
        boxShadow: [
          BoxShadow(
            // color:
            //     Colors.black.withOpacity(0.2), // Shadow color with transparency
            color:
                shadowColor.withOpacity(0.2), // Shadow color with transparency
            spreadRadius: 2, // Spread of the shadow
            blurRadius: 8, // Blur radius of the shadow
            offset: Offset(0, 4), // Offset of the shadow (horizontal, vertical)
          ),
        ],
      ),
      child: child,
    );
  }
}
