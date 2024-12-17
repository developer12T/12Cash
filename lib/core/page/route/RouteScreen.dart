import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:_12sale_app/core/components/search/CustomerDropdownSearch.dart';
import 'package:_12sale_app/core/components/search/TestDropdown.dart';
import 'package:_12sale_app/core/components/table/RouteTable.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/SaleRoute.dart';
import 'package:_12sale_app/function/SavetoStorage.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class Routescreen extends StatefulWidget {
  const Routescreen({super.key});

  @override
  State<Routescreen> createState() => _RoutescreenState();
}

class _RoutescreenState extends State<Routescreen> {
  static const LatLng origin = LatLng(37.7749, -122.4194); // San Francisco, CA
  static const LatLng waypoint1 = LatLng(36.7783, -119.4179); // Fresno, CA
  static const LatLng waypoint2 = LatLng(34.0522, -118.2437); // Los Angeles, CA
  static const LatLng destination = LatLng(32.7157, -117.1611); // San Diego, CA
  Set<Marker> _markers = {};
  List<Widget> overlayTexts = [];
  List<Widget> distanceLabels = [];
  final List<LatLng> routePoints = [
    origin,
    waypoint1,
    waypoint2,
    destination,
  ];

  List<Map<String, dynamic>> _annotations = [];
  List<SaleRoute> _routes = [];
  final Set<Polyline> _polylines = {};
  int _polylineIdCounter = 0;
  late GoogleMapController _mapController;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  PolylineId? selectedPolyline;

  Future<void> fetchPolylineDataWithDio(
      LatLng origin, LatLng destination, String apiKey) async {
    final String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=${origin.latitude},${origin.longitude}'
        '&destinations=${destination.latitude},${destination.longitude}'
        '&key=$apiKey';

    try {
      final dio = Dio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final distance = data['rows'][0]['elements'][0]['distance']['text'];
        final duration = data['rows'][0]['elements'][0]['duration']['text'];

        print('Distance: $distance, Duration: $duration');

        setState(() {
          // _polylines.add(
          //   Polyline(
          //     polylineId: PolylineId('route'),
          //     points: [origin, destination],
          //     color: Colors.blue,
          //     width: 5,
          //   ),
          // );

          _annotations.add(
            {
              'position': LatLng(
                (origin.latitude + destination.latitude) / 2,
                (origin.longitude + destination.longitude) / 2,
              ),
              'text': '$distance, $duration',
            },
          );
        });
      } else {
        print('Failed to fetch distance matrix: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching distance matrix: $e');
    }
  }

  void _generateDistanceLabels() async {
    if (_mapController == null) {
      // Ensure the map controller is initialized
      print("MapController is not initialized yet.");
      return;
    }
    distanceLabels.clear();

    for (int i = 0; i < routePoints.length - 1; i++) {
      LatLng start = routePoints[i];
      LatLng end = routePoints[i + 1];
      LatLng midpoint = _calculateMidpoint(start, end);

      // Convert LatLng midpoint to screen position
      ScreenCoordinate screenPosition =
          await _mapController.getScreenCoordinate(midpoint);

      setState(() {
        distanceLabels.add(
          Positioned(
            left: screenPosition.x.toDouble(),
            top: screenPosition.y.toDouble(),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(4),
              child: Text(
                '120 km',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ),
        );
      });
    }
  }

  void _initializeMarkers() async {
    _markers = {};
    _markers.add(
      Marker(
        markerId: MarkerId('origin'),
        position: origin,
        infoWindow: InfoWindow(
          title: 'Origin',
          snippet: 'Label: WP1',
        ),
        // icon: BitmapDescriptor.fromBytes(encodedContent),
        icon: await const CountWidget(count: 1).toBitmapDescriptor(
          logicalSize: const Size(25, 25),
          imageSize: const Size(50, 50),
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: MarkerId('waypoint1'),
        position: waypoint1,
        infoWindow: InfoWindow(title: 'Waypoint 1'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    _markers.add(
      Marker(
        markerId: MarkerId('waypoint2'),
        position: waypoint2,
        infoWindow: InfoWindow(title: 'Waypoint 2'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),
    );

    _markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: destination,
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    setState(() {});
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(13.6823684, 100.6097614),
    zoom: 14.4746,
  );
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  initState() {
    super.initState();
    // _maker.addAll(_list);
    _loadSaleRoute();
    _initializePolylines();
    _initializeMarkers();
  }

  void _initializePolylines() {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('static_route'),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline =
        Polyline(polylineId: id, color: Colors.red, points: routePoints);
    polylines[id] = polyline;
    setState(() {});
  }

  // Function to calculate the midpoint between two points
  LatLng _calculateMidpoint(LatLng start, LatLng end) {
    return LatLng(
      (start.latitude + end.latitude) / 2,
      (start.longitude + end.longitude) / 2,
    );
  }

  void _generateOverlayTexts() {
    overlayTexts.clear();
    for (int i = 0; i < routePoints.length - 1; i++) {
      LatLng start = routePoints[i];
      LatLng end = routePoints[i + 1];
      LatLng midpoint = _calculateMidpoint(start, end);

      _markers.add(
        Marker(
          markerId: MarkerId('tooltip'),
          position: midpoint,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: 'Distance',
            snippet: '500 miles, 6 hours',
          ),
        ),
      );

      overlayTexts.add(Positioned(
        child: Container(
          padding: const EdgeInsets.all(4),
          color: Colors.white,
          child: Text(
            "123 km",
            style: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ),
        left: 100, // Placeholder for actual position
        top: 100, // Placeholder for actual position
      ));
    }
  }

  Future<void> _loadSaleRoute() async {
    String jsonSaleRoute = await rootBundle.loadString('data/sale_route.json');
    List<dynamic> jsonData = jsonDecode(jsonSaleRoute);

    setState(() {
      _routes = jsonData
          .map((data) => SaleRoute.fromJson(data as Map<String, dynamic>))
          .toList();
    });
    await saveToStorage('saleRoutes', _routes);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        // Expanded(
        //   child: Container(
        //     padding: const EdgeInsets.all(8),
        //     margin: EdgeInsets.all(screenWidth / 45),
        //     child: Stack(
        //       children: [
        //         GoogleMap(
        //           initialCameraPosition: const CameraPosition(
        //             target: origin,
        //             zoom: 5.0,
        //           ),
        //           markers: _markers,
        //           // polylines: Set<Polyline>.of(polylines.values),
        //           polylines: _polylines,
        //           mapType: MapType.normal,
        //           myLocationButtonEnabled: true,
        //           myLocationEnabled: true,
        //           // initialCameraPosition: _kGooglePlex,
        //           onMapCreated: (controller) {
        //             setState(() {
        //               _mapController = controller;
        //             });
        //             _generateDistanceLabels();
        //           },
        //         ),
        //         ...distanceLabels,
        //       ],
        //     ),
        //   ),
        // ),
        // TextButton(
        //   onPressed: () {
        //     print("test");
        //     // fetchPolylineDataWithDio(
        //     //     origin, destination, 'AIzaSyAQ9F4z5GhkeW5n8z03OK7H5CcMpzUAZr0');
        //   },
        //   child: const Text('add'),
        // ),
        Expanded(
          child: Container(
              padding: const EdgeInsets.all(8),
              margin: EdgeInsets.all(screenWidth / 45),
              child: const RouteTable()),
        ),
      ],
    );
  }
}

class RouteHeader extends StatefulWidget {
  const RouteHeader({super.key});

  @override
  State<RouteHeader> createState() => _RouteHeaderState();
}

class _RouteHeaderState extends State<RouteHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),

                  // color: Colors.red,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/12TradingLogo.png'),
                        // fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: Center(
                  // margin: EdgeInsets.only(top: 10),
                  child: Column(
                    // mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          // color: Colors.blue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.event,
                                      size: 25, color: Colors.white),
                                  Text(
                                    "route.title".tr(),
                                    style: Styles.headerWhite24(context),
                                    textAlign: TextAlign.start,
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     Text(
                              //       ' เดือน ${DateFormat('MMMM', 'th').format(DateTime.now())} ${DateTime.now().year + 543}',
                              //       style: Styles.headerWhite24(context),
                              //     ),
                              //   ],
                              // )
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          ' ${"route.month".tr()} ${DateFormat('MMMM', 'th').format(DateTime.now())} ${DateTime.now().year + 543}',
                          style: Styles.headerWhite24(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Flexible(
          fit: FlexFit.tight,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CustomerDropdownSearch(),
          ),
        ),
      ],
    );
  }
}

class CountWidget extends StatelessWidget {
  const CountWidget({super.key, required this.count});
  final int count;
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Styles.primaryColor,
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class TextOnImage extends StatelessWidget {
  const TextOnImage({
    super.key,
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          style: Styles.black18(context),
        )
      ],
    );
  }
}
