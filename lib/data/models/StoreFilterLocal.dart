import 'package:_12sale_app/data/models/Store.dart';
import 'package:flutter/material.dart';

class StoreLocal with ChangeNotifier {
  List<Store> _storesList = [];
  List<Store> get storeList => _storesList;
  void updateValue(List<Store> stores) {
    _storesList.clear();
    _storesList = stores;
    notifyListeners();
  }
}
