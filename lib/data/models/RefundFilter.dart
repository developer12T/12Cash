import 'package:_12sale_app/data/models/Store.dart';
import 'package:flutter/material.dart';

class RefundfilterLocal with ChangeNotifier {
  int _isSelect = 1;
  int get isSelect => _isSelect;

  void updateValue(int select) {
    _isSelect = select;
    notifyListeners();
  }
}
