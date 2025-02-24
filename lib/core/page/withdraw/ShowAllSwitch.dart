import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/card/WeightCude.dart';
import 'package:_12sale_app/core/components/switch/example_1.dart';
import 'package:_12sale_app/core/components/switch/example_10.dart';
import 'package:_12sale_app/core/components/switch/example_11.dart';
import 'package:_12sale_app/core/components/switch/example_12.dart';
import 'package:_12sale_app/core/components/switch/example_13.dart';
import 'package:_12sale_app/core/components/switch/example_14.dart';
import 'package:_12sale_app/core/components/switch/example_15.dart';
import 'package:_12sale_app/core/components/switch/example_2.dart';
import 'package:_12sale_app/core/components/switch/example_3.dart';
import 'package:_12sale_app/core/components/switch/example_4.dart';
import 'package:_12sale_app/core/components/switch/example_5.dart';
import 'package:_12sale_app/core/components/switch/example_6.dart';
import 'package:_12sale_app/core/components/switch/example_7.dart';
import 'package:_12sale_app/core/components/switch/example_8.dart';
import 'package:_12sale_app/core/components/switch/example_9.dart';
import 'package:_12sale_app/core/components/switch/second_screen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class ShowAllSwitch extends StatefulWidget {
  const ShowAllSwitch({super.key});

  @override
  State<ShowAllSwitch> createState() => _ShowAllSwitchState();
}

class _ShowAllSwitchState extends State<ShowAllSwitch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
          title: " เบิกสินค้า",
          icon: Icons.store_mall_directory_rounded,
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Example15(),
                    const SizedBox(height: 16),
                    const Example14(),
                    const SizedBox(height: 16),
                    const Example12(),
                    const SizedBox(height: 16),
                    const Example3(),
                    const SizedBox(height: 16),
                    const Example1(),
                    const SizedBox(height: 16),
                    const Example2(),
                    const SizedBox(height: 16),
                    const Example4(),
                    const SizedBox(height: 16),
                    const Example5(),
                    const SizedBox(height: 16),
                    const Example6(),
                    const SizedBox(height: 16),
                    const Example7(),
                    const SizedBox(height: 16),
                    const Example8(),
                    const SizedBox(height: 16),
                    const Example9(),
                    const SizedBox(height: 16),
                    const Example10(),
                    const SizedBox(height: 16),
                    const Example11(),
                    const SizedBox(height: 16),
                    const Directionality(
                      textDirection: TextDirection.rtl,
                      child: Example13(),
                    ),
                    const SizedBox(height: 16),
                    const Example13(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (context) {
                              return const SecondView();
                            },
                          ),
                        );
                      },
                      child: const Text('Go to second screen'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
