class StoreLatLong {
  final String lat;
  final String long;
  final String id;
  final String period;

  StoreLatLong({
    required this.lat,
    required this.id,
    required this.long,
    required this.period,
  });

  // Factory constructor to create Cause instance from JSON
  factory StoreLatLong.fromJson(Map<String, dynamic> json) {
    return StoreLatLong(
      lat: json['lat'],
      long: json['long'],
      id: json['id'],
      period: json['period'],
    );
  }

  // Convert Cause instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'long': long,
      'id': id,
      'period': period,
    };
  }
}
