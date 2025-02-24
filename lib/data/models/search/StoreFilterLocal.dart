// import 'package:_12sale_app/data/models/RouteVisit.dart';
import 'package:_12sale_app/data/models/Store.dart';
import 'package:flutter/material.dart';

class StoreLocal with ChangeNotifier {
  List<Store> _storesList = [];
  List<StoreFavoriteLocal> _storesFavoriteList = [];

  List<Store> get storeList => _storesList;
  List<StoreFavoriteLocal> get storesFavoriteList => _storesFavoriteList;
  StoreFavoriteLocal? existingStore;
  void updateValue(List<Store> stores) {
    _storesList.clear();
    _storesList = stores;
    notifyListeners();
  }

  void addStoreFavorite(Store store) {
    if (_storesFavoriteList
        .any((element) => element.store_id == store.storeId)) {
      _storesFavoriteList
          .firstWhere((element) => element.store_id == store.storeId)
          .count++;
    } else {
      _storesFavoriteList.add(
        StoreFavoriteLocal(
          store_id: store.storeId,
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
