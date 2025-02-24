import 'package:_12sale_app/core/components/switch/enums.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SecondView extends StatefulWidget {
  const SecondView({Key? key}) : super(key: key);

  @override
  State<SecondView> createState() => _SecondViewState();
}

class _SecondViewState extends State<SecondView> {
  int isSelect = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second View'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomSlidingSegmentedControl<int>(
                  initialValue: 1,
                  isStretch: true,
                  children: {
                    1: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          color: isSelect == 1
                              ? Styles.primaryColor
                              : Styles.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'รอส่ง',
                          style: isSelect == 1
                              ? Styles.headerPirmary18(context)
                              : Styles.headerWhite18(context),
                        )
                      ],
                    ),
                    2: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description,
                          color: isSelect == 2
                              ? Styles.primaryColor
                              : Styles.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ประวัติ',
                          style: isSelect == 2
                              ? Styles.headerPirmary18(context)
                              : Styles.headerWhite18(context),
                        ),
                      ],
                    )
                  },
                  onValueChanged: (v) {
                    setState(() {
                      isSelect = v;
                    });
                    print(v);
                  },
                  decoration: BoxDecoration(
                    color: Styles.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: Styles.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(milliseconds: 300),
                ),
              ),
              const SizedBox(height: 20),
              // CustomSlidingSegmentedControl<SegmentType>(
              //   initialValue: SegmentType.map,
              //   children: const {
              //     SegmentType.news: Text(
              //       'News daily portal',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //     SegmentType.map: Text(
              //       'Map',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //     SegmentType.paper: Text(
              //       'Flights',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   },
              //   innerPadding: EdgeInsets.zero,
              //   thumbDecoration: const BoxDecoration(color: Colors.blue),
              //   duration: const Duration(milliseconds: 300),
              //   curve: Curves.easeInToLinear,
              //   onValueChanged: (SegmentType v) {
              //     print(v);
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
