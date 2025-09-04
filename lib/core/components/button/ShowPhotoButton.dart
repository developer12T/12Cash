import 'dart:io';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// ===== Image helpers: แยก http/https, file:// และ local path ธรรมดา =====
bool _isHttpUrl(String? s) {
  final u = Uri.tryParse(s ?? '');
  return u != null && (u.scheme == 'http' || u.scheme == 'https');
}

bool _isFileUri(String? s) {
  final u = Uri.tryParse(s ?? '');
  return u != null && u.scheme == 'file';
}

String _toFilePath(String s) {
  final u = Uri.tryParse(s);
  if (u != null && u.scheme == 'file') {
    // แปลง file:// URI -> path ที่ File เข้าใจ
    return u.toFilePath();
  }
  return s; // เป็น path ธรรมดาอยู่แล้ว (/data/... หรือ /storage/...)
}

ImageProvider<Object> imageProviderFor(String? path) {
  if (path == null || path.isEmpty) {
    // TODO: เปลี่ยนเป็น asset ของคุณเองถ้ามี
    return const AssetImage('assets/images/placeholder.png');
  }
  if (_isHttpUrl(path)) return NetworkImage(path);
  if (_isFileUri(path)) return FileImage(File(_toFilePath(path)));
  if (path.startsWith('/')) return FileImage(File(path)); // local absolute path
  // fallback สุดท้าย
  return FileImage(File(_toFilePath(path)));
}

/// ===== Widget หลัก =====
class ShowPhotoButton extends StatefulWidget {
  String? imagePath;
  final IconData icon;
  final String label;
  final TextStyle? labelStyle;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  bool
      checkNetwork; // ไม่จำเป็นต้องใช้แล้ว แต่คงพารามฯ ไว้เพื่อไม่ให้กระทบที่อื่น

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
    final screenWidth = MediaQuery.of(context).size.width;

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
            // เปิดรูปแบบ dialog เฉพาะตอนมีรูป
            onPressed: widget.imagePath == null
                ? null
                : () async {
                    await showDialog(
                      context: context,
                      builder: (_) => ImageDialog(
                        imagePath: widget.imagePath!,
                        checkNetwork: widget.checkNetwork,
                      ),
                    );
                  },
            child: widget.imagePath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 50),
                      Text(
                        "gobal.camera_button.no_image".tr(),
                        style: Styles.white18(context),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Image(
                      image: imageProviderFor(widget.imagePath),
                      width: screenWidth / 4,
                      height: screenWidth / 4,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(Icons.error, color: Colors.red, size: 50),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.label,
          style: widget.labelStyle ?? Styles.black18(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// ===== Dialog แสดงภาพเต็ม =====
class ImageDialog extends StatelessWidget {
  final String imagePath;
  final bool checkNetwork; // ไม่จำเป็นแล้ว แต่คงไว้เพื่อ compatibility

  const ImageDialog({
    Key? key,
    required this.imagePath,
    this.checkNetwork = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w =
        MediaMemo.of(context)?.size.width ?? MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: w,
        height: w,
        child: Image(
          image: imageProviderFor(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error, color: Colors.red, size: 50),
          ),
        ),
      ),
    );
  }
}

/// ตัวช่วย cache ขนาดหน้าจอเล็ก ๆ (optional)
class MediaMemo extends InheritedWidget {
  final Size size;
  const MediaMemo({
    super.key,
    required this.size,
    required super.child,
  });

  static MediaMemo? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MediaMemo>();

  @override
  bool updateShouldNotify(covariant MediaMemo oldWidget) =>
      size != oldWidget.size;
}
