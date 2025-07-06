import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Campaign.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CampaignCard extends StatefulWidget {
  final CampaignModel item;
  final VoidCallback onDetailsPressed;
  const CampaignCard({
    super.key,
    required this.item,
    required this.onDetailsPressed,
  });

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    tz.initializeTimeZones();
    final bangkok = tz.getLocation('Asia/Bangkok');
    final utcTime = widget.item.createdAt;
    final bangkokTime = tz.TZDateTime.from(utcTime, bangkok);
    final formatted = DateFormat('dd/MM/yyyy | HH:mm:ss').format(bangkokTime);

    return GestureDetector(
      onTap: widget.onDetailsPressed,
      child: BoxShadowCustom(
          child: Container(
        height: screenWidth / 3,
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
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            8), // Optional: Add rounded corners
                        child: Image.network(
                          '${ApiService.apiHost}/campaign/${widget.item.image[0].split('/').last}',
                          width: screenWidth / 1.5,
                          height: screenWidth / 4,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: screenWidth / 1.5,
                              height: screenWidth / 4,
                              color: Colors.grey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.hide_image,
                                      color: Colors.white, size: 50),
                                  Text(
                                    "ไม่มีภาพ",
                                    style: Styles.white18(context),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.title,
                                  style: Styles.headerBlack18(context),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.item.des,
                                    style: Styles.black18(context),
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    formatted,
                                    style: Styles.black18(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ))
                  ],
                )
              ],
            )),
      )),
    );
  }
}
