import 'package:_12sale_app/data/models/route/RouteVisit.dart';
import 'package:_12sale_app/data/models/route/StoreVisit.dart';
import 'package:flutter/material.dart';

class RouteVisitFilterLocal with ChangeNotifier {
  List<RouteVisit> _routeVisitList = [];
  List<StoreFavoriteLocal> _storesFavoriteList = [];
  String filterRoute = 'R01';

  List<RouteVisit> get routeVisitList => _routeVisitList;
  List<StoreFavoriteLocal> get storesFavoriteList => _storesFavoriteList;
  StoreFavoriteLocal? existingStore;

  void updateValue(List<RouteVisit> stores) {
    _routeVisitList.clear();
    _routeVisitList = stores;
    notifyListeners();
  }

/******  b188193a-4997-4d1c-857c-532ee4f089e6  *******/
  void addStoreFavorite(ListStore store) {
    if (_storesFavoriteList
        .any((element) => element.store_id == store.storeInfo.storeId)) {
      _storesFavoriteList
          .firstWhere((element) => element.store_id == store.storeInfo.storeId)
          .count++;
    } else {
      _storesFavoriteList.add(
        StoreFavoriteLocal(
          store_id: store.storeInfo.storeId,
          count: 1,
        ),
      );
    }
    notifyListeners();
  }
}

class StoreFavoriteLocal {
  String store_id;
  int count;
  StoreFavoriteLocal({
    required this.store_id,
    required this.count,
  });

  Map<String, dynamic> toJson() {
    return {
      'store_id': store_id,
      'count': count,
    };
  }

  static List<StoreFavoriteLocal> fromJsonList(List list) {
    return list.map((item) => StoreFavoriteLocal.fromJson(item)).toList();
  }

  factory StoreFavoriteLocal.fromJson(Map<String, dynamic> json) {
    return StoreFavoriteLocal(
      store_id: json['store_id'] as String,
      count: json['count'] as int,
    );
  }
}
