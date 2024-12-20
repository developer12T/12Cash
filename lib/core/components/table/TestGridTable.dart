import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Testgridtable extends StatefulWidget {
  const Testgridtable({super.key});

  @override
  State<Testgridtable> createState() => _TestgridtableState();
}

class _TestgridtableState extends State<Testgridtable> {
  List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;

  @override
  void initState() {
    super.initState();
    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: ' Data Grid',
          icon: Icons.campaign,
        ),
      ),
      body: SfDataGrid(
        columnWidthCalculationRange: ColumnWidthCalculationRange.allRows,
        rowHeight: 65.0,
        allowSorting: true,
        allowFiltering: true,
        source: employeeDataSource,
        columnWidthMode: ColumnWidthMode.fill,
        columns: <GridColumn>[
          GridColumn(
            // maximumWidth: 500,
            // minimumWidth: 500,
            allowSorting: false,
            allowFiltering: false,
            // filterPopupMenuOptions: FilterPopupMenuOptions(
            //     showColumnName: false, filterMode: FilterMode.checkboxFilter),
            columnName: 'itemNo',
            minimumWidth: 100,
            label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'Item Code',
              ),
            ),
          ),
          GridColumn(
              allowSorting: false,
              allowFiltering: false,
              columnName: 'name',
              minimumWidth: 250,
              label: Container(
                alignment: Alignment.center,
                child: Text('Name'),
              )),
          GridColumn(
            minimumWidth: 100,
            columnName: 'group',
            label: Container(
              alignment: Alignment.center,
              child: Text(
                'Group',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GridColumn(
            minimumWidth: 100,
            columnName: 'flavour',
            label: Container(
              alignment: Alignment.center,
              child: Text(
                'Flavour',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GridColumn(
            minimumWidth: 100,
            filterPopupMenuOptions: FilterPopupMenuOptions(
              filterMode: FilterMode.both,
              showColumnName: true,
            ),
            columnName: 'size',
            label: Container(
              alignment: Alignment.center,
              child: Text(
                softWrap: true,
                'Size',
                overflow: TextOverflow.clip,
              ),
            ),
          ),
          GridColumn(
            minimumWidth: 100,
            columnName: 'brand',
            label: Container(
              alignment: Alignment.center,
              child: Text(
                'Brand',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          GridColumn(
            minimumWidth: 100,
            columnName: 'salary',
            label: Container(
              alignment: Alignment.center,
              child: Text(
                'Salary',
                overflow: TextOverflow.clip,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Employee> getEmployeeData() {
    return [
      Employee(10010101001, 'ผงปรุงรสหมู ฟ้าไทย 10g x12x20', 'ผงปรุงรส', 'หมู',
          '10g', 'ฟ้าไทย', 1000),
      Employee(10010101001, 'ผงปรุงรสหมู ฟ้าไทย 10g x12x20', 'ผงปรุงรส', 'หมู',
          '10g', 'ฟ้าไทย', 1000),
      // Employee(10002, 'Kathryn', 'Manager', 30000),
      // Employee(10003, 'Lara', 'Developer', 15000),
      // Employee(10004, 'Michael', 'Designer', 15000),
      // Employee(10005, 'Martin', 'Developer', 15000),
      // Employee(10006, 'Newberry', 'Developer', 15000),
      // Employee(10007, 'Balnc', 'Developer', 15000),
      // Employee(10008, 'Perry', 'Developer', 15000),
      // Employee(10009, 'Gable', 'Developer', 15000),
      // Employee(10010, 'Grimes', 'Developer', 15000)
    ];
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the employee which will be rendered in datagrid.
class Employee {
  /// Creates the employee class with required details.
  Employee(this.itemCode, this.name, this.group, this.flavour, this.size,
      this.brand, this.salary);

  /// Id of an employee.
  final int itemCode;

  /// Name of an employee.
  final String name;

  /// Designation of an employee.
  final String group;

  final String flavour;

  final String size;

  final String brand;

  /// Salary of an employee.
  final int salary;
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<Employee> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'itemNo', value: e.itemCode),
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<String>(columnName: 'group', value: e.group),
              DataGridCell<String>(columnName: 'flavour', value: e.flavour),
              DataGridCell<String>(columnName: 'size', value: e.size),
              DataGridCell<String>(columnName: 'brand', value: e.brand),
              DataGridCell<int>(columnName: 'salary', value: e.salary),
            ]))
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
