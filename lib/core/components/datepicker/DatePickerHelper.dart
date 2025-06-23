import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

class DatePickerHelper {
  static Future<void> showDatePickerDialog({
    required BuildContext context,
    required StateSetter setModalState,
    required Function(DateTime) onDateSelected,
    DateTime? initialDate,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale('th', 'TH'),
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year - 2),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              headlineSmall: Styles.white18(context),
              headlineLarge: Styles.white18(context),
              headlineMedium: Styles.white18(context),
              titleMedium: Styles.white18(context),
              titleLarge: Styles.white18(context),
              titleSmall: Styles.white18(context),
              bodyMedium: Styles.white18(context),
              bodyLarge: Styles.white18(context),
              bodySmall: Styles.white18(context),
              labelLarge: Styles.white18(context),
              labelMedium: Styles.white18(context),
              labelSmall: Styles.white18(context),
            ),
            colorScheme: const ColorScheme.light(
              surface: Styles.primaryColor,
              primary: Styles.white,
              onPrimary: Styles.primaryColor,
              onSurface: Styles.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Styles.white,
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate != null) {
      setModalState(() => onDateSelected(pickedDate));
    }
  }
}
