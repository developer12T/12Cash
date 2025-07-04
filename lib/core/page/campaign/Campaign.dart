import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:flutter/material.dart';

class Campaign extends StatefulWidget {
  const Campaign({super.key});

  @override
  State<Campaign> createState() => _CampaignState();
}

class _CampaignState extends State<Campaign> {
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
      body: Column(
        children: [],
      ),
    );
  }
}
