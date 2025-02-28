import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Styles {
  static double getResponsiveFontSize(BuildContext context, double fontSize) {
    return fontSize *
        MediaQuery.of(context).size.width /
        600; // Assuming 375 is the base screen width
  }

  static TextStyle kanit(BuildContext context) => GoogleFonts.kanit();

  static TextStyle green10(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 10),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF198754),
        ),
      );

  static TextStyle green18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF198754),
        ),
      );

  static TextStyle red10(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 10),
          fontWeight: FontWeight.normal,
          color: Colors.red,
        ),
      );

  static TextStyle grey12(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 12),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B7280),
        ),
      );

  static TextStyle grey16(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B7280),
        ),
      );

  static TextStyle headerBlack18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      );

  static TextStyle headerBlack16(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      );

  static TextStyle strikeBlack18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333),
        ),
      );

  static TextStyle black18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333),
        ),
      );

  static TextStyle black16(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333),
        ),
      );
  static TextStyle black20(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 20),
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333),
        ),
      );

  static TextStyle headerBlack20(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 20),
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      );

  static TextStyle black12(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 12),
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333),
        ),
      );

  static TextStyle red12(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 12),
          fontWeight: FontWeight.normal,
          color: Colors.red,
        ),
      );
  static TextStyle red18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.normal,
          color: Colors.red,
        ),
      );

  static TextStyle red24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.normal,
          color: Colors.red,
        ),
      );
  static TextStyle headerBlack24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      );

  static TextStyle headerRed18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      );

  static TextStyle headerRed24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      );

  static TextStyle headerRed32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      );

  static TextStyle headerAmber32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.w600,
          color: Colors.amber,
        ),
      );

  static TextStyle headerGreen32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.w600,
          color: Colors.green[600],
        ),
      );

  static TextStyle headerGreen24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.w600,
          color: Colors.green[600],
        ),
      );

  static TextStyle headerGreen16(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.w600,
          color: Colors.green[600],
        ),
      );

  static TextStyle headerGreen18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: Colors.green[600],
        ),
      );
  static TextStyle strikeBlack24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333),
        ),
      );
  static TextStyle black24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333),
        ),
      );

  // static TextStyle headerBlack20(BuildContext context) => GoogleFonts.kanit(
  //       textStyle: TextStyle(
  //         fontSize: getResponsiveFontSize(context, 24),
  //         fontWeight: FontWeight.bold,
  //         color: Color(0xFF333333),
  //       ),
  //     );
  static TextStyle headerBlack32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      );
  static TextStyle strikeBlack32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333),
        ),
      );
  static TextStyle black32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.normal,
          color: Color(0xFF333333),
        ),
      );
  static TextStyle headergrey18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6B7280),
        ),
      );
  static TextStyle strikeGrey18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B7280),
        ),
      );
  static TextStyle grey18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B7280),
        ),
      );
  static TextStyle headergrey24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6B7280),
        ),
      );
  static TextStyle strikeGrey24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B7280),
        ),
      );
  static TextStyle grey24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6B7280),
        ),
      );

  static TextStyle green24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF198754),
        ),
      );

  static TextStyle headergrey32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.w600,
          color: const Color(0xFF6B7280),
        ),
      );
  static TextStyle strikeGrey32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B7280),
        ),
      );
  static TextStyle grey32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      );
  static TextStyle headerWhite18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
  static TextStyle strikeWhite18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B7280),
        ),
      );
  static TextStyle white18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      );

  static TextStyle white16(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 16),
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      );

  static TextStyle headerWhite24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
  static TextStyle strikeWhite24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
          decorationThickness: 2.0,
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B7280),
        ),
      );

  static TextStyle white24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      );

  static TextStyle headerWhite32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );

  static TextStyle headerPirmary32(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 32),
          fontWeight: FontWeight.w600,
          color: Color(0xFF00569D),
        ),
      );

  static TextStyle headerPirmary24(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 24),
          fontWeight: FontWeight.w600,
          color: Color(0xFF00569D),
        ),
      );

  static TextStyle pirmary18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.normal,
          color: Color(0xFF00569D),
        ),
      );

  static TextStyle headerPirmary18(BuildContext context) => GoogleFonts.kanit(
        textStyle: TextStyle(
          fontSize: getResponsiveFontSize(context, 18),
          fontWeight: FontWeight.w600,
          color: Color(0xFF00569D),
        ),
      );

// --------------------- Primary Color ---------------------------------
  static const Color primaryColor = Color(0xFF00569D);
  static const Color primaryColorIcons = Color(0xFF00569D);
  static const Color secondaryColor = Color(0xFF8fd7f5);

  // static const Color primaryColor = Color(0xFF7554ae);
  // static const Color primaryColorIcons = Color(0xFFbd98e0);
  // static const Color secondaryColor = Color(0xFFbd98e0);

  static const Color grey = Color(0xFF999999);
  static const Color white = Colors.white;

  // --------------------- Common Color --------------------------------
  static const Color backgroundTableColor = Color(0xFFF9FAFB);
  static const Color successBackgroundColor = Color(0xFFDEF7EC);
  static const Color successTextColor = Color(0xFF03543F);

  static const Color failBackgroundColor = Color(0xFFFBD5D5);
  static const Color failTextColor = Color(0xFF9B1C1C);

  static const Color paddingBackgroundColor = Color(0xFFE1EFFE);
  static const Color paddingTextColor = Color(0xFF1E429F);

  static const Color warningBackgroundColor = Color(0xFFFFF3CD);
  static const Color warningTextColor = Color(0xFFEDB900);

  static const Color accentColor = Colors.orange;

  // --------------------- Button Color --------------------------------
  static const Color successButtonColor = Color(0xFF198754);

  //  --------------------- Pastel Color --------------------------------
  static const Color greenPastel = Color(0xFF0F5E5F);
  static const Color bluePastel = Color(0xFF48B8D0);
  static const Color skybluePastel = Color(0xFF8AE1FC);
  static const Color redPastel = Color(0xFFC08497);

  //  --------------------- Status Color --------------------------------
  static Color? success = Colors.green[600];
  static Color? fail = Colors.red;
  static Color? warning = Colors.amber[600];
}
