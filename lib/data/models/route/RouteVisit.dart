import 'package:_12sale_app/data/models/route/StoreVisit.dart';

class RouteVisit {
  final String id;
  final String period;
  final String area;
  final String day;
  final int storeAll;
  final int storePending;
  final int storeSell;
  final int storeCheckInNotSell;
  final int storeNotSell;
  final int storeTotal;
  final double percentComplete;
  final double percentEffective;
  final double percentVisit;
  List<ListStore>? listStore;

  RouteVisit({
    required this.id,
    required this.period,
    required this.area,
    required this.day,
    required this.storeAll,
    required this.storePending,
    required this.storeSell,
    required this.storeCheckInNotSell,
    required this.storeNotSell,
    required this.storeTotal,
    required this.percentComplete,
    required this.percentEffective,
    required this.percentVisit,
    this.listStore,
  });

  factory RouteVisit.fromJson(Map<String, dynamic> json) {
    return RouteVisit(
      id: json['id'] ?? '',
      period: json['period'] ?? '',
      area: json['area'] ?? '',
      day: json['day'] ?? '',
      storeAll: (json['storeAll'] ?? 0) as int,
      storePending: (json['storePending'] ?? 0) as int,
      storeSell: (json['storeSell'] ?? 0) as int,
      storeCheckInNotSell: (json['storeCheckInNotSell'] ?? 0) as int,
      storeNotSell: (json['storeNotSell'] ?? 0) as int,
      storeTotal: (json['storeTotal'] ?? 0) as int,
      percentComplete: (json['percentComplete'] ?? 0).toDouble(),
      percentEffective: (json['percentEffective'] ?? 0).toDouble(),
      percentVisit: (json['percentVisit'] ?? 0).toDouble(),
      listStore: (json['listStore'] as List?)
              ?.map((store) => ListStore.fromJson(store))
              .toList() ??
          [],
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
      'listStore': listStore?.map((store) => store.toJson()).toList(),
    };
  }
}
