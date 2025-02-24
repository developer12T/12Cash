import 'package:flutter/material.dart';

class MonthYearPickerExample extends StatefulWidget {
  @override
  _MonthYearPickerExampleState createState() => _MonthYearPickerExampleState();
}

class _MonthYearPickerExampleState extends State<MonthYearPickerExample> {
  DateTime? _selectedDate;

  Future<void> _showMonthYearPicker() async {
    final DateTime? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Month and Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: _selectedDate ?? DateTime.now(),
              selectedDate: _selectedDate ?? DateTime.now(),
              onChanged: (DateTime date) {
                Navigator.pop(context); // Close the year picker
                _showMonthPicker(
                    date.year); // Show month picker for the selected year
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _showMonthPicker(int year) async {
    final DateTime? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Month',
            style: TextStyle(color: Colors.black),
          ),
          content: SizedBox(
            width: 300,
            height: 300,
            child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(12, (index) {
                final month = index + 1;
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, DateTime(year, month));
                  },
                  child: Center(
                    child: Text(
                      '${_getMonthName(month)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _selectedDate == null
              ? 'No date selected'
              : 'Selected: ${_selectedDate!.month}/${_selectedDate!.year}',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _showMonthYearPicker,
          child: Text('Select Month and Year'),
        ),
      ],
    );
  }
}
