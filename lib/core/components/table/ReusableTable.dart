import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

class ReusableTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;

  const ReusableTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map((column) =>
                DataColumn(label: Text(column, style: Styles.black18(context))))
            .toList(),
        rows: rows
            .map(
              (row) => DataRow(
                cells: row
                    .map((cell) => DataCell(Text(
                          cell,
                          style: Styles.black18(context),
                        )))
                    .toList(),
              ),
            )
            .toList(),
      ),
    );
  }
}
