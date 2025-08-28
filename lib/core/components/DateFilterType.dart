import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

enum DateFilterType { day, month, year }

class DateFilter extends StatefulWidget {
  final DateFilterType initialType;
  final DateTime? initialDate;
  final ValueChanged2<DateTimeRange, DateFilterType> onRangeChanged;

  const DateFilter({
    super.key,
    this.initialType = DateFilterType.day,
    this.initialDate,
    required this.onRangeChanged,
  });

  @override
  State<DateFilter> createState() => _DateFilterState();
}

typedef ValueChanged2<T1, T2> = void Function(T1 a, T2 b);

class _DateFilterState extends State<DateFilter> {
  late DateFilterType _type;
  late DateTime _anchor; // วันที่อ้างอิง (วัน/เดือน/ปี ที่เลือกอยู่ตอนนี้)

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _anchor = (widget.initialDate ?? DateTime.now());
    _anchor = DateTime(_anchor.year, _anchor.month, _anchor.day); // ตัดเวลา
    _emitRange(); // ยิงค่าเริ่มต้น
  }

  // แปลง (_type + _anchor) -> DateTimeRange
  DateTimeRange _toRange() {
    switch (_type) {
      case DateFilterType.day:
        final start =
            DateTime(_anchor.year, _anchor.month, _anchor.day, 0, 0, 0);
        final end =
            DateTime(_anchor.year, _anchor.month, _anchor.day, 23, 59, 59, 999);
        return DateTimeRange(start: start, end: end);

      case DateFilterType.month:
        final firstDay = DateTime(_anchor.year, _anchor.month, 1);
        final firstDayNextMonth = DateTime(_anchor.year, _anchor.month + 1, 1);
        final lastMoment =
            firstDayNextMonth.subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: firstDay, end: lastMoment);

      case DateFilterType.year:
        final firstDay = DateTime(_anchor.year, 1, 1);
        final firstDayNextYear = DateTime(_anchor.year + 1, 1, 1);
        final lastMoment =
            firstDayNextYear.subtract(const Duration(milliseconds: 1));
        return DateTimeRange(start: firstDay, end: lastMoment);
    }
  }

  void _emitRange() {
    widget.onRangeChanged(_toRange(), _type);
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchor,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('th', 'TH'),
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
    if (picked != null) {
      setState(() {
        _anchor = DateTime(picked.year, picked.month, picked.day);
      });
      _emitRange();
    }
  }

  Future<void> _pickMonth() async {
    final result = await showDialog<_MonthYear?>(
      context: context,
      builder: (_) => _MonthPickerDialog(
        initialYear: _anchor.year,
        initialMonth: _anchor.month,
      ),
    );
    if (result != null) {
      setState(() {
        _anchor = DateTime(result.year, result.month, 1);
      });
      _emitRange();
    }
  }

  Future<void> _pickYear() async {
    final result = await showDialog<int?>(
      context: context,
      builder: (_) => _YearPickerDialog(initialYear: _anchor.year),
    );
    if (result != null) {
      setState(() {
        _anchor = DateTime(result, 1, 1);
      });
      _emitRange();
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = switch (_type) {
      DateFilterType.day => _formatDay(_anchor),
      DateFilterType.month => _formatMonth(_anchor),
      DateFilterType.year => _anchor.year.toString(),
    };

    return Row(
      children: [
        // เลือกประเภท
        DropdownButton<DateFilterType>(
          value: _type,
          onChanged: (v) {
            if (v == null) return;
            setState(() => _type = v);
            _emitRange();
          },
          items: [
            DropdownMenuItem(
              value: DateFilterType.day,
              child: Text(
                'วัน',
                style: Styles.black18(context),
              ),
            ),
            DropdownMenuItem(
              value: DateFilterType.month,
              child: Text(
                'เดือน',
                style: Styles.black18(context),
              ),
            ),
            DropdownMenuItem(
              value: DateFilterType.year,
              child: Text(
                'ปี',
                style: Styles.black18(context),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // ปุ่มเลือกค่า (วัน/เดือน/ปี)
        FilledButton(
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all<Color>(Styles.primaryColor),
          ),
          onPressed: () {
            switch (_type) {
              case DateFilterType.day:
                _pickDay();
                break;
              case DateFilterType.month:
                _pickMonth();
                break;
              case DateFilterType.year:
                _pickYear();
                break;
            }
          },
          child: Text(
            label,
            style: Styles.white18(context),
          ),
        ),
      ],
    );
  }

  String _formatDay(DateTime d) {
    // 17 ส.ค. 2025
    const thMonthsShort = [
      '',
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    return '${d.day} ${thMonthsShort[d.month]} ${d.year}';
  }

  String _formatMonth(DateTime d) {
    // ส.ค. 2025
    const thMonthsShort = [
      '',
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];
    return '${thMonthsShort[d.month]} ${d.year}';
  }
}

/// -------------------- Month Picker Dialog --------------------

class _MonthYear {
  final int year;
  final int month;
  _MonthYear(this.year, this.month);
}

class _MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  const _MonthPickerDialog({
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    const thMonthsShort = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.'
    ];

    return AlertDialog(
      title: Text(
        'เลือกเดือน / ปี',
        style: Styles.black24(context),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ปุ่มเลื่อนปี
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'ปีก่อนหน้า',
                  onPressed: () => setState(() => _year--),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('$_year', style: Styles.black18(context)),
                IconButton(
                  tooltip: 'ปีถัดไป',
                  onPressed: () => setState(() => _year++),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // กริด 12 เดือน
            GridView.builder(
              shrinkWrap: true,
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (_, i) {
                final m = i + 1;
                return OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_MonthYear(_year, m)),
                  child: Text(
                    thMonthsShort[i],
                    style: Styles.black18(context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'ยกเลิก',
            style: Styles.black18(context),
          ),
        ),
      ],
    );
  }
}

/// -------------------- Year Picker Dialog --------------------

class _YearPickerDialog extends StatefulWidget {
  final int initialYear;
  const _YearPickerDialog({required this.initialYear});

  @override
  State<_YearPickerDialog> createState() => _YearPickerDialogState();
}

class _YearPickerDialogState extends State<_YearPickerDialog> {
  late int _centerYear;

  @override
  void initState() {
    super.initState();
    _centerYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    // โชว์กริดปีเป็นบล็อคละ 12 ปี พร้อมเลื่อนซ้าย/ขวาได้
    final start = _centerYear - 5;
    final years = List.generate(12, (i) => start + i);

    return AlertDialog(
      title: Text(
        'เลือกปี',
        style: Styles.black24(context),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ตัวเลื่อนช่วงปี
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'ช่วงก่อนหน้า',
                  onPressed: () => setState(() => _centerYear -= 12),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('${years.first} - ${years.last}',
                    style: Styles.black18(context)),
                IconButton(
                  tooltip: 'ช่วงถัดไป',
                  onPressed: () => setState(() => _centerYear += 12),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              itemCount: years.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.1,
              ),
              itemBuilder: (_, i) {
                final y = years[i];
                return OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(y),
                  child: Text(
                    y.toString(),
                    style: Styles.black12(context),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ยกเลิก',
              style: Styles.black18(context),
            )),
      ],
    );
  }
}
