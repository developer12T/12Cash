// Main model class
class StoreVisit {
  final String id;
  final String period;
  final String area;
  final String day;
  final int? storeAll;
  final int? storePending;
  final int? storeSell;
  final int? storeCheckInNotSell;
  final int? storeNotSell;
  final int? storeTotal;
  final double percentComplete;
  final double percentEffective;
  final double percentVisit;
  final List<ListStore> listStore;

  StoreVisit({
    required this.id,
    required this.period,
    required this.area,
    required this.day,
    required this.listStore,
    this.storeAll,
    this.storePending,
    this.storeSell,
    this.storeCheckInNotSell,
    this.storeNotSell,
    this.storeTotal,
    required this.percentComplete,
    required this.percentEffective,
    required this.percentVisit,
  });

  factory StoreVisit.fromJson(Map<String, dynamic> json) {
    return StoreVisit(
      id: json['id'],
      period: json['period'],
      area: json['area'],
      day: json['day'],
      storeAll: json['storeAll'],
      storePending: json['storePending'],
      storeNotSell: json['storeNotSell'],
      storeCheckInNotSell: json['storeCheckInNotSell'],
      storeSell: json['storeSell'],
      storeTotal: json['storeTotal'],
      percentComplete: (json['percentComplete'] as num).toDouble(),
      percentEffective: (json['percentEffective'] as num).toDouble(),
      percentVisit: (json['percentVisit'] as num).toDouble(),
      listStore: (json['listStore'] as List)
          .map((store) => ListStore.fromJson(store))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'area': area,
      'day': day,
      'storeAll': storeAll,
      'storePending': storePending,
      'storeSell': storeSell,
      'storeCheckInNotSell': storeCheckInNotSell,
      'storeNotSell': storeNotSell,
      'storeTotal': storeTotal,
      'percentComplete': percentComplete,
      'percentEffective': percentEffective,
      'percentVisit': percentVisit,
      'listStore': listStore.map((store) => store.toJson()).toList(),
    };
  }
}

// ListStore class
class ListStore {
  final StoreInfo storeInfo;
  final String note;
  final String? image;
  final String? latitude;
  final String? longtitude;
  final String status;
  final String statusText;
  final String? date;
  final List<dynamic> listOrder;

  ListStore({
    required this.storeInfo,
    required this.note,
    this.image,
    this.latitude,
    this.longtitude,
    required this.status,
    required this.statusText,
    this.date,
    required this.listOrder,
  });

  factory ListStore.fromJson(Map<String, dynamic> json) {
    return ListStore(
      storeInfo: StoreInfo.fromJson(json['storeInfo']),
      note: json['note'] ?? '',
      image: json['image'] ?? '',
      latitude: json['latitude'] ?? '',
      longtitude: json['longtitude'] ?? '',
      status: json['status'] ?? '0',
      statusText: json['statusText'] ?? '',
      date: json['date'] ?? '',
      listOrder: json['listOrder'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeInfo': storeInfo.toJson(),
      'note': note,
      'image': image,
      'latitude': latitude,
      'longtitude': longtitude,
      'status': status,
      'statusText': statusText,
      'date': date,
      'listOrder': listOrder,
    };
  }
}

// StoreInfo class
class StoreInfo {
  final String id;
  final String storeId;
  final String name;
  final String taxId;
  final String tel;
  final String typeName;
  final String address;

  StoreInfo({
    required this.id,
    required this.storeId,
    required this.name,
    required this.taxId,
    required this.tel,
    required this.typeName,
    required this.address,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['_id'],
      storeId: json['storeId'],
      name: json['name'],
      taxId: json['taxId'],
      tel: json['tel'],
      typeName: json['typeName'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'storeId': storeId,
      'name': name,
      'taxId': taxId,
      'tel': tel,
      'typeName': typeName,
      'address': address,
    };
  }
}
