import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Campaign.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:flutter/material.dart';

class CampaignCard extends StatefulWidget {
  final CampaignModel item;
  const CampaignCard({
    super.key,
    required this.item,
  });

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return BoxShadowCustom(
        child: Container(
      height: screenWidth / 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  // Expanded(
                  //   flex: 1,
                  //   child: ClipRRect(
                  //     borderRadius: BorderRadius.circular(
                  //         8), // Optional: Add rounded corners
                  //     child: Image.network(
                  //       '${ApiService.apiHost}/images/products/${widget.product.id}.webp',
                  //       width: screenWidth / 4,
                  //       height: screenWidth / 4,
                  //       fit: BoxFit.cover,
                  //       errorBuilder: (context, error, stackTrace) {
                  //         return Container(
                  //           width: screenWidth / 4,
                  //           height: screenWidth / 4,
                  //           color: Colors.grey,
                  //           child: Column(
                  //             mainAxisAlignment: MainAxisAlignment.center,
                  //             children: [
                  //               Icon(Icons.hide_image,
                  //                   color: Colors.white, size: 50),
                  //               Text(
                  //                 "ไม่มีภาพ",
                  //                 style: Styles.white18(context),
                  //               )
                  //             ],
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ),
                ],
              )
            ],
          )),
    ));
  }
}
