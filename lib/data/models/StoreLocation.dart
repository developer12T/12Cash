class StoreLocation {
  final String storeId;
  final String storeName;
  final double lat;
  final double lng;

  StoreLocation({
    required this.storeId,
    required this.storeName,
    required this.lat,
    required this.lng,
  });

  factory StoreLocation.fromJson(Map<String, dynamic> json) {
    return StoreLocation(
      storeId: json['storeId'],
      storeName: json['storeName'],
      lat: json['location'][0],
      lng: json['location'][1],
    );
  }
}
