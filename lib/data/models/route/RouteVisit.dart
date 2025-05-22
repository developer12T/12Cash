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

  // Factory method to parse JSON into RouteVisit
  factory RouteVisit.fromJson(Map<String, dynamic> json) {
    return RouteVisit(
      id: json['id'],
      period: json['period'],
      area: json['area'],
      day: json['day'],
      storeAll: json['storeAll'],
      storePending: json['storePending'],
      storeSell: json['storeSell'],
      storeCheckInNotSell: json['storeCheckInNotSell'],
      storeNotSell: json['storeNotSell'],
      storeTotal: json['storeTotal'],
      percentComplete: (json['percentComplete'] as num).toDouble(),
      percentEffective: (json['percentEffective'] as num).toDouble(),
      percentVisit: (json['percentVisit'] as num).toDouble(),
      listStore: (json['listStore'] as List?)
              ?.map((store) => ListStore.fromJson(store))
              .toList() ??
          [],
    );
  }

  // Method to convert object back to JSON
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
