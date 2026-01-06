class StoreLocation {
  final String storeId;
  final String storeName;
  final String storeAddress;
  final double lat;
  final double lng;

  StoreLocation({
    required this.storeId,
    required this.storeName,
    required this.storeAddress,
    required this.lat,
    required this.lng,
  });

  factory StoreLocation.fromJson(Map<String, dynamic> json) {
    return StoreLocation(
      storeId: json['storeId'],
      storeName: json['storeName'],
      storeAddress: json['storeAddress'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
