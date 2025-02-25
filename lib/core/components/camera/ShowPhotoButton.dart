import 'dart:io';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ShowPhotoButton extends StatefulWidget {
  String? imagePath;
  final IconData icon;
  final String label;
  final TextStyle? labelStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  bool checkNetwork;

  ShowPhotoButton({
    super.key,
    required this.icon,
    this.imagePath,
    required this.label,
    this.labelStyle,
    this.backgroundColor = Colors.blue,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.checkNetwork = false,
  });

  @override
  _ShowPhotoButtonState createState() => _ShowPhotoButtonState();
}

class _ShowPhotoButtonState extends State<ShowPhotoButton> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(
          width: screenWidth / 4,
          height: screenWidth / 4,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: widget.padding,
              backgroundColor: widget.imagePath == null
                  ? Colors.grey[400]
                  : Styles.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
            ),
            onPressed: () {},
            child: widget.imagePath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 50),
                      Text(
                        "gobal.camera_button.no_image".tr(),
                        style: Styles.white18(context),
                      )
                    ],
                  )
                : GestureDetector(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => ImageDialog(
                          imagePath: widget.imagePath!,
                          checkNetwork: widget.checkNetwork,
                        ),
                      );
                    },
                    child: ClipRRect(
                      child: widget.checkNetwork == false
                          ? Image.file(
                              File(widget.imagePath!),
                              width: screenWidth / 4,
                              height: screenWidth / 4,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.imagePath!,
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
          ),
        ),
        Text(
          widget.label,
          style: Styles.black18(context),
        ),
      ],
    );
  }
}

class ImageDialog extends StatelessWidget {
  final String imagePath;
  final bool checkNetwork;

  const ImageDialog({
    Key? key,
    required this.imagePath,
    this.checkNetwork = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      child: Container(
        width: screenWidth,
        height: screenWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: checkNetwork == false
                ? FileImage(File(imagePath))
                : NetworkImage(imagePath), // Use FileImage for file paths
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
