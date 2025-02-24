import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

class CalendarPicker extends StatefulWidget {
  final String label;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateSelected;

  const CalendarPicker({
    Key? key,
    required this.label,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _CalendarPickerState createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      locale: Locale('th', 'TH'),
      context: context,
      initialDate: _selectedDate ?? widget.initialDate,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
              // colorScheme: const ColorScheme.light(
              //   surface: Styles.primaryColor,

              //   primary: Styles.white, // Header background color
              //   onPrimary: Styles.primaryColor, // Header text color
              //   onSurface: Styles.white, // Body text color
              // ),
              // textButtonTheme: TextButtonThemeData(
              //   style: TextButton.styleFrom(
              //     foregroundColor: Styles.white, // Button text color
              //   ),
              // ),
              ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Styles.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null
                  ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                  : widget.label,
              style: Styles.black18(context),
            ),
            const Icon(Icons.calendar_today,
                size: 20, color: Styles.primaryColor),
          ],
        ),
      ),
    );
  }
}
