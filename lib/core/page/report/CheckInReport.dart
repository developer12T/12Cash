import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CheckinReport extends StatefulWidget {
  const CheckinReport({super.key});

  @override
  State<CheckinReport> createState() => _CheckinReportState();
}

class _CheckinReportState extends State<CheckinReport> {
  Map<String, dynamic> data = {};
  bool isLoading = true;

  String period =
      "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

  Future<void> getRouteEffectiveAll() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/route/getRouteEffectiveAll?area=${User.area}&period=$period',
        method: 'GET',
      );
      if (response.statusCode == 200) {
        setState(() {
          data = response.data;
        });
      }
    } catch (e) {
      print("getRouteEffectiveAll error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getRouteEffectiveAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " รายงานการเข้าเยี่ยม",
          icon: Icons.campaign,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatCard("Visit", _formatDouble(data["visit"])),
                  _buildStatCard("Effective", _formatDouble(data["effective"])),
                  _buildStatCard(
                      "ร้านค้าทั้งหมด", _formatInt(data["totalStoreAll"])),
                  _buildStatCard("ร้านค้ารอเข้าเยี่ยม",
                      _formatInt(data["totalStorePending"])),
                  _buildStatCard(
                      "ร้านค้าที่ซื้อ", _formatInt(data["totalStoreSell"])),
                  _buildStatCard("ร้านค้าที่ไม่ซื้อ",
                      _formatInt(data["totalStoreNotSell"])),
                  _buildStatCard("ร้านค้าเข้าเยี่ยมไม่ซื้อ",
                      _formatInt(data["totalStoreCheckInNotSell"])),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Text(label, style: Styles.headerBlack24(context)),
        trailing: Text(value, style: Styles.headerPirmary24(context)),
      ),
    );
  }

  String _formatDouble(dynamic val) {
    if (val == null) return "-";
    return (val is num) ? val.toStringAsFixed(2) + '%' : val.toString();
  }

  String _formatInt(dynamic val) {
    if (val == null) return "-";
    return val.toString() + ' ร้าน';
  }
}
