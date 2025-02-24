class SaleRoute {
  final String id;
  final String area;
  final String period;
  final String day;
  final int storeAll;
  final int storeBuy;
  final int storeNotBuy;
  final int storeCheckin;
  final int storeTotal;
  final List<Store> listStore;

  SaleRoute({
    required this.id,
    required this.area,
    required this.period,
    required this.day,
    required this.storeAll,
    required this.storeBuy,
    required this.storeNotBuy,
    required this.storeCheckin,
    required this.storeTotal,
    required this.listStore,
  });

  factory SaleRoute.fromJson(Map<String, dynamic> json) {
    return SaleRoute(
      id: json['id'],
      area: json['area'],
      period: json['period'],
      day: json['day'],
      storeAll: json['storeAll'],
      storeBuy: json['storeBuy'],
      storeNotBuy: json['storeNotBuy'],
      storeCheckin: json['storeCheckin'],
      storeTotal: json['storeTotal'],
      listStore: (json['listStore'] as List<dynamic>)
          .map((store) => Store.fromJson(store))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area': area,
      'period': period,
      'day': day,
      'storeAll': storeAll,
      'storeBuy': storeBuy,
      'storeNotBuy': storeNotBuy,
      'storeCheckin': storeCheckin,
      'storeTotal': storeTotal,
      'listStore': listStore.map((store) => store.toJson()).toList(),
    };
  }
}

class Store {
  final StoreInfo storeInfo;
  final String latitude;
  final String longitude;
  final String note;
  final String status;
  final String statusText;
  final DateTime date;
  final List<ListOrder> listOrder;

  Store({
    required this.storeInfo,
    required this.latitude,
    required this.longitude,
    required this.note,
    required this.status,
    required this.statusText,
    required this.date,
    required this.listOrder,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeInfo: StoreInfo.fromJson(json['storeInfo']),
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      note: json['note'] ?? '',
      status: json['status'] ?? '',
      statusText: json['statusText'] ?? '',
      date: DateTime.parse(json['date']),
      listOrder: (json['listOrder'] as List<dynamic>)
          .map((order) => ListOrder.fromJson(order))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeInfo': storeInfo.toJson(),
      'latitude': latitude,
      'longitude': longitude,
      'note': note,
      'status': status,
      'statusText': statusText,
      'date': date.toIso8601String(),
      'listOrder': listOrder.map((order) => order.toJson()).toList(),
    };
  }
}

class StoreInfo {
  final String storeId;
  final String storeName;
  final String storeAddress;
  final String storeType;

  StoreInfo({
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.storeType,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
      storeAddress: json['storeAddress'] ?? '',
      storeType: json['storeType'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'storeName': storeName,
      'storeAddress': storeAddress,
      'storeType': storeType,
    };
  }
}

class ListOrder {
  final int number;
  final String orderId;
  final String status;
  final String statusText;
  final DateTime date;

  ListOrder({
    required this.number,
    required this.orderId,
    required this.status,
    required this.statusText,
    required this.date,
  });

  factory ListOrder.fromJson(Map<String, dynamic> json) {
    return ListOrder(
      number: json['number'],
      orderId: json['orderId'],
      status: json['status'] ?? '',
      statusText: json['statusText'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'orderId': orderId,
      'status': status,
      'statusText': statusText,
      'date': date.toIso8601String(),
    };
  }
}
