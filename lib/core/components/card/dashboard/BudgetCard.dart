import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

const List<String> list = <String>['Day', 'Month', 'Year', 'Custom'];

class BudgetCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const BudgetCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: widget.color.withOpacity(0.1),
              child: Icon(widget.icon, color: widget.color, size: 28),
            ),
            const SizedBox(width: 16),

            // Card content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.value,
                    style: Styles.headerBlack24(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.title,
                    style: Styles.grey16(context),
                  ),
                ],
              ),
            ),

            // Dropdown filter
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down),
              elevation: 2,
              style: Styles.grey16(context),
              underline: Container(height: 0),
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
