import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/order/CampaignCard.dart';
import 'package:_12sale_app/core/page/campaign/CampaignDetail.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Campaign.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Campaign extends StatefulWidget {
  const Campaign({super.key});

  @override
  State<Campaign> createState() => _CampaignState();
}

class _CampaignState extends State<Campaign> {
  List<CampaignModel> campaignList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getCampaign();
  }

  void openUrl(String url) async {
    final encodedUrl = Uri.encodeFull(url);
    final uri = Uri.parse(encodedUrl);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _getCampaign() async {
    try {
      ApiService apiService = ApiService();
      await apiService.init();
      var response = await apiService.request(
        endpoint:
            'api/cash/campaign/getCampaign', // You only need to pass the endpoint, the base URL is handled
        method: 'GET',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        setState(() {
          campaignList =
              data.map((item) => CampaignModel.fromJson(item)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      print("Error _getCampaign: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: AppbarCustom(
            title: " ประกาศข่าวสาร",
            icon: Icons.campaign,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LoadingSkeletonizer(
            loading: _loading,
            child: campaignList.isEmpty
                ? Center(
                    child: Text(
                    'ไม่พบข้อมูลแคมเปญ',
                    style: Styles.black18(context),
                  ))
                : ListView.builder(
                    itemCount: campaignList.length, // <<<<<< สำคัญ!
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CampaignCard(
                          item: campaignList[index],
                          onDetailsPressed: () {
                            openUrl(
                                "${ApiService.apiHost}/campaign/${campaignList[index].file[0].split('/').last}");
                          },
                        ),
                      );
                    },
                  ),
          ),
        ));
  }
}
