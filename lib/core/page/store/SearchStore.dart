import 'dart:math';
import 'package:_12sale_app/core/components/Appbar.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/StoreLocation.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/data/service/locationService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../../data/models/User.dart';

class SearchStore extends StatefulWidget {
  const SearchStore({super.key});

  @override
  State<SearchStore> createState() => _SearchStoreState();
}

/* ===================== */
/* Distance Calculation  */
/* ===================== */
double calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const R = 6371; // km
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

double _deg2rad(double deg) => deg * (pi / 180);

/* ===================== */
/* Mock Store Data       */
/* ===================== */
List<StoreLocation> mockStores = [];
final LocationService locationService = LocationService();

/* ===================== */
/* State                 */
/* ===================== */
class _SearchStoreState extends State<SearchStore> {
  GoogleMapController? _mapController;

  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  LatLng? _selectedPoint;

  List<StoreLocation> _allStores = [];
  List<StoreLocation> _nearbyStores = [];

  double latitude = 0;
  double longitude = 0;

  double _radiusKm = 2;
  CameraPosition? _initialCamera;

  // static const CameraPosition _initialCamera = CameraPosition(
  //   target: LatLng(13.736717, 100.523186),
  //   zoom: 12,
  // );

  @override
  void initState() {
    super.initState();
    _getNearbyStores();
    // _loadInitialStores();
  }

  void moveToCurrentLocation() {
    if (_mapController != null && latitude != 0 && longitude != 0) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(latitude, longitude),
          15,
        ),
      );
    }
  }

  /* ===================== */
  /* Load All Stores       */
  /* ===================== */
  void _loadInitialStores() {
    setState(() {
      _markers.clear();
      _circles.clear();

      for (final store in _allStores) {
        _markers.add(
          Marker(
            markerId: MarkerId(store.storeId),
            position: LatLng(store.lat, store.lng),
            infoWindow: InfoWindow(title: store.storeName),
          ),
        );
      }
    });
  }

  Future<bool> fetchLocation() async {
    try {
      await locationService.initialize();

      double? lat = await locationService.getLatitude();
      double? lon = await locationService.getLongitude();

      if (lat == null || lon == null) {
        throw Exception('Location is null');
      }

      setState(() {
        latitude = lat;
        longitude = lon;
      });

      setState(() {
        _initialCamera = CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 10,
        );
      });

      print('📍 LOCATION: $latitude , $longitude');
      return true;
    } catch (e) {
      if (mounted) {
        setState(() {
          latitude = 0;
          longitude = 0;
        });
      }
      print("❌ Location Error: $e");
      return false;
    }
  }

  Future<void> _getNearbyStores() async {
    try {
      context.loaderOverlay.show();

      final hasLocation = await fetchLocation();
      if (!hasLocation || latitude == 0 || longitude == 0) {
        throw Exception('Location not ready');
      }

      ApiService apiService = ApiService();
      await apiService.init();

      var response = await apiService.request(
        endpoint: 'api/cash/store/getNearbyStores',
        method: 'POST',
        body: {
          "area": "${User.area}",
          "lat": latitude,
          "long": longitude,
          "distance": 50
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        _allStores = data.map((item) => StoreLocation.fromJson(item)).toList();

        print('🏪 STORES: ${_allStores.length}');
      }

      _loadInitialStores();
      moveToCurrentLocation();
    } catch (e) {
      print("❌ API Error: $e");
    } finally {
      context.loaderOverlay.hide();
    }
  }

  /* ===================== */
  /* Reset Show All Stores */
  /* ===================== */
  void _showAllStores() {
    setState(() {
      _selectedPoint = null;
      _nearbyStores.clear();
      _markers.clear();
      _circles.clear();

      for (final store in _allStores) {
        _markers.add(
          Marker(
            markerId: MarkerId(store.storeId),
            position: LatLng(store.lat, store.lng),
            infoWindow: InfoWindow(title: store.storeName),
          ),
        );
      }
    });

    // _mapController?.animateCamera(
    //   CameraUpdate.newCameraPosition(_initialCamera),
    // );

    // ⭐ กลับไปตำแหน่งปัจจุบันแทน initialCamera
    if (_mapController != null && latitude != 0 && longitude != 0) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(latitude, longitude),
          14,
        ),
      );
    }
  }

  /* ===================== */
  /* Long Press Handler    */
  /* ===================== */
  void _onLongPress(LatLng position) {
    setState(() {
      _selectedPoint = position;
      _nearbyStores.clear();
      _markers.clear();
      _circles.clear();

      // --- Selected Point Marker ---
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ),
          infoWindow: const InfoWindow(title: 'ตำแหน่งที่เลือก'),
        ),
      );

      // --- Radius Circle ---
      _circles.add(
        Circle(
          circleId: const CircleId('radius'),
          center: position,
          radius: _radiusKm * 1000, // km → meter
          fillColor: Colors.blue.withOpacity(0.15),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );

      // --- Radius Label Marker ---
      _markers.add(
        Marker(
          markerId: const MarkerId('radius_label'),
          position: LatLng(
            position.latitude + 0.0005, // ขยับนิดให้ไม่ทับจุด
            position.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: 'รัศมี ${_radiusKm.toInt()} กม.',
          ),
        ),
      );

      // --- Nearby Stores ---
      for (final store in _allStores) {
        final distance = calculateDistance(
          position.latitude,
          position.longitude,
          store.lat,
          store.lng,
        );

        if (distance <= _radiusKm) {
          _nearbyStores.add(store);

          _markers.add(
            Marker(
              markerId: MarkerId(store.storeId),
              position: LatLng(store.lat, store.lng),
              infoWindow: InfoWindow(
                title: store.storeName,
                snippet: '${distance.toStringAsFixed(2)} กม.',
              ),
            ),
          );
        }
      }
    });
  }

  /* ===================== */
  /* Radius Selector       */
  /* ===================== */
  Widget _radiusSelector(BuildContext context) {
    final radii = [1.0, 3.0, 5.0, 10.0];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: radii.map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                label: Text('${r.toInt()} กม.', style: Styles.black16(context)),
                selected: _radiusKm == r,
                onSelected: (_) {
                  setState(() {
                    _radiusKm = r;
                  });

                  if (_selectedPoint != null) {
                    _onLongPress(_selectedPoint!);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /* ===================== */
  /* UI                    */
  /* ===================== */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppbarCustom(
          title: "ค้นหาร้านค้าใกล้ฉัน",
          icon: Icons.store,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAllStores,
        icon: const Icon(Icons.store_mall_directory),
        label: Text('แสดงทุกร้านในระยะ 50 กม.', style: Styles.black16(context)),
      ),
      body: Column(
        children: [
          _radiusSelector(context),

          /* -------- MAP -------- */
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: _initialCamera ??
                  const CameraPosition(
                    target: LatLng(13.736717, 100.523186),
                    zoom: 10,
                  ),
              markers: _markers,
              circles: _circles,
              onLongPress: _onLongPress,
              onMapCreated: (controller) {
                _mapController = controller; // ⭐ สำคัญมาก

                if (latitude != 0 && longitude != 0) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(latitude, longitude),
                      15,
                    ),
                  );
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),

          /* -------- LIST -------- */
          Expanded(
            child: _selectedPoint == null
                ? Center(
                    child: Text(
                      'กดค้างบนแผนที่เพื่อค้นหาร้านใกล้',
                      style: Styles.black18(context),
                    ),
                  )
                : _nearbyStores.isEmpty
                    ? Center(
                        child: Text(
                          'ไม่พบร้านค้าในระยะ ${_radiusKm.toInt()} กม.',
                          style: Styles.black18(context),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _nearbyStores.length,
                        itemBuilder: (context, index) {
                          final store = _nearbyStores[index];
                          final distance = calculateDistance(
                            _selectedPoint!.latitude,
                            _selectedPoint!.longitude,
                            store.lat,
                            store.lng,
                          );

                          return ListTile(
                            leading: const Icon(Icons.store),
                            title: Text(store.storeName,
                                style: Styles.black16(context)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(store.storeId,
                                    style: Styles.black16(context)),
                                Text(
                                  'ระยะทาง ${distance.toStringAsFixed(2)} กม.',
                                  style: Styles.black16(context),
                                ),
                              ],
                            ),
                            onTap: () {
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  LatLng(store.lat, store.lng),
                                  16,
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
