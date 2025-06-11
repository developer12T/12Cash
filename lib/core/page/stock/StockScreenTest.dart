import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/table/ReusableTable.dart';
import 'package:flutter/material.dart';

class StockScreenTest extends StatefulWidget {
  const StockScreenTest({super.key});

  @override
  State<StockScreenTest> createState() => _StockScreenTestState();
}

class _StockScreenTestState extends State<StockScreenTest> {
  @override
  Widget build(BuildContext context) {
    final columns = [
      'รหัส',
      'ชื่อ',
      'เบิกต้นทริป',
      // 'stock-in',
      // 'stock-out',
      // 'balance'
    ];
    final rows = [
      ['1', 'Alice', 'Developer'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['1', 'Alice', 'Developer'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['1', 'Alice', 'Developer'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['1', 'Alice', 'Developer'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['1', 'Alice', 'Developer'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
      ['2', 'Bob', 'Designer'],
      ['3', 'Charlie', 'Manager'],
    ];
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(title: " สต๊อก", icon: Icons.settings_sharp),
      ),
      // persistentFooterButtons: [],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ReusableTable(columns: columns, rows: rows),
      ),
    );
  }
}
