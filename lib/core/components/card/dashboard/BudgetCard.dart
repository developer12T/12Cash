import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:dartx/dartx.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

const List<String> list = <String>['day', 'month', 'year'];

class BudgetCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String? storeId;

  const BudgetCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    this.storeId,
  }) : super(key: key);

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  String dropdownValue = list.second;

  double totalSale = 0;
  String date =
      "${DateFormat('dd').format(DateTime.now())}${DateFormat('MM').format(DateTime.now())}${DateTime.now().year}";

  Future<void> getDataSummaryChoince(String type) async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var body = {
        "area": "${User.area}",
        "date": "$date",
        "type": "$type",
      };

      if (widget.storeId != null) {
        body['storeId'] = widget.storeId!;
      }

      var response = await apiService.request(
        endpoint: 'api/cash/order/getSummarybyChoice',
        method: 'POST',
        body: body,
      );
      if (response.statusCode == 200) {
        print(response.data);
        setState(() {
          totalSale = response.data['total'].toDouble();
        });
      }
    } catch (e) {
      print("Error on getDataSummaryChoince is $e");
      if (mounted) {
        setState(() {
          totalSale = 0.0;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataSummaryChoince('month');
  }

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
                    // '฿${totalSale.toStringAsFixed(2)} THB',
                    '฿ ${NumberFormat.currency(locale: 'th_TH', symbol: '').format(totalSale)} THB',
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
            SizedBox(width: 16),
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
                getDataSummaryChoince(dropdownValue);
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
