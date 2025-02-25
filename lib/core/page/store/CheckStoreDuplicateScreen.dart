import 'dart:convert';

import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/components/layout/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/button/Button.dart';
import 'package:_12sale_app/core/components/card/store/DuplicateCard.dart';
import 'package:_12sale_app/core/components/card/store/StoreCardAll.dart';
import 'package:_12sale_app/core/components/card/store/StoreCardNew.dart';
import 'package:_12sale_app/core/page/store/DetailSimilarDtore.dart';
import 'package:_12sale_app/core/page/store/DetailStoreScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/DuplicateStore.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckStoreDuplicateScreen extends StatefulWidget {
  List<DuplicateStore> stores;
  CheckStoreDuplicateScreen({required this.stores, super.key});

  @override
  State<CheckStoreDuplicateScreen> createState() =>
      _CheckStoreDuplicateScreenState();
}

class _CheckStoreDuplicateScreenState extends State<CheckStoreDuplicateScreen> {
  List<DuplicateStore> storeItems = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            title: " ร้านค้าที่คล้ายกัน",
            icon: Icons.store_mall_directory_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: widget.stores.isEmpty
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading spinner if data isn't loaded
                  : BoxShadowCustom(
                      child: ListView.builder(
                        itemCount: widget.stores.length,
                        itemBuilder: (context, index) {
                          return DuplicateCardStore(
                            item: widget.stores[index],
                            onDetailsPressed: () {
                              print('Details for ${widget.stores[index].name}');
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CheckStoreDuplicateScreen2 extends StatefulWidget {
  List<Store> stores;

  CheckStoreDuplicateScreen2({required this.stores, super.key});

  @override
  State<CheckStoreDuplicateScreen2> createState() =>
      _CheckStoreDuplicateScreen2State();
}

class _CheckStoreDuplicateScreen2State
    extends State<CheckStoreDuplicateScreen2> {
  List<Store> storeItems = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppbarCustom(
            title: " ${"store.processtimeline_screen.similar_title".tr()}",
            icon: Icons.store_mall_directory_rounded),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: widget.stores.isEmpty
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading spinner if data isn't loaded
                  : BoxShadowCustom(
                      child: ListView.builder(
                        itemCount: widget.stores.length,
                        itemBuilder: (context, index) {
                          return StoreCartAll(
                            item: widget.stores[index],
                            onDetailsPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailSimilarStore(
                                      initialSelectedRoute: RouteStore(
                                          route: widget.stores[index].route),
                                      store: widget.stores[index],
                                      customerNo: widget.stores[index].storeId,
                                      customerName: widget.stores[index].name),
                                ),
                              );
                              print('Details for ${widget.stores[index].name}');
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
