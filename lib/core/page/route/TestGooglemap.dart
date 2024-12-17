import 'dart:math';
import 'dart:convert';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:custom_info_window/custom_info_window.dart';

class PolylineWithLabels extends StatefulWidget {
  @override
  _PolylineWithLabelsState createState() => _PolylineWithLabelsState();
}

class _PolylineWithLabelsState extends State<PolylineWithLabels> {
  CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  GoogleMapController? _mapController;
  String apikey = 'AIzaSyAQ9F4z5GhkeW5n8z03OK7H5CcMpzUAZr0';
  int sumDistance = 0;
  int sumDuration = 0;

  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  List<Widget> _distanceLabels = [];
  List<LatLng> routePoints = [];
  Set<Marker> _markers = {};
  static const LatLng origin =
      LatLng(13.689600, 100.608600); // San Francisco, CA
  static const LatLng waypoint1 = LatLng(13.760493, 100.474507); // Fresno, CA
  static const LatLng waypoint2 =
      LatLng(13.711040, 100.517814); // Los Angeles, CA
  static const LatLng destination =
      LatLng(13.918764, 100.567671); // San Diego, CA
  // PolylinePoints polylinePoints = PolylinePoints();
  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _getPolyline();
    // _fetchRouteAndDisplay();
    routePoints = [origin, waypoint1, waypoint2, destination];
    _addPolyline();
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => _generateDistanceLabels());
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  void _addPolyline() {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.red,
          width: 5,
          zIndex: 2,
          consumeTapEvents: true,
          onTap: () {
            print('Polyline tapped!');
          },
        ),
      );
    });
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apikey,
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
        wayPoints: [
          PolylineWayPoint(
              location: "${waypoint1.latitude},${waypoint1.longitude}"),
          PolylineWayPoint(
              location: "${waypoint2.latitude},${waypoint2.longitude}"),
        ],
      ),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      var dio = Dio();
      var response = await dio.get(
        "https://maps.googleapis.com/maps/api/directions/json?origin=13.689600,100.608600&destination=13.918764,100.567671&waypoints=13.760493,100.474507|13.71104,100.517814&key=AIzaSyAQ9F4z5GhkeW5n8z03OK7H5CcMpzUAZr0",
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.data != null &&
          response.data['routes'] != null &&
          response.data['routes'].isNotEmpty &&
          response.data['routes'][0]['legs'] != null) {
        for (var i = 0; i < response.data['routes'][0]['legs'].length; i++) {
          final distanceValue =
              response.data['routes'][0]['legs'][i]['distance']['value'];

          final durationValue =
              response.data['routes'][0]['legs'][i]['duration']['value'];

          if (durationValue is int) {
            sumDuration +=
                durationValue; // Add directly if it's already an integer
          } else if (durationValue is String) {
            sumDuration += int.parse(durationValue); // Parse if it's a string
          } else {
            print("Unexpected data type for distance value: $durationValue");
          }

          // Handle both int and String types
          if (distanceValue is int) {
            sumDistance +=
                distanceValue; // Add directly if it's already an integer
          } else if (distanceValue is String) {
            sumDistance += int.parse(distanceValue); // Parse if it's a string
          } else {
            print("Unexpected data type for distance value: $distanceValue");
          }
        }
        print("Total distance: $sumDistance meters");
      } else {
        print("Invalid API response structure");
      }

      for (int i = 0; i < routePoints.length - 1; i++) {
        LatLng start = _findClosestPoint(routePoints[i]);
        LatLng end = _findClosestPoint(routePoints[i + 1]);
        LatLng midpoint = LatLng(
          (start.latitude + end.latitude) / 2,
          (start.longitude + end.longitude) / 2,
        );

        _markers.add(
          Marker(
            markerId: MarkerId('tooltip$i'),
            position: midpoint,
            icon: await TextOnImage(
              text:
                  "${response.data['routes'][0]['legs'][i]['distance']['text']}\n${response.data['routes'][0]['legs'][i]['duration']['text']}",
            ).toBitmapDescriptor(
                logicalSize: const Size(100, 100),
                imageSize: const Size(100, 100)),
            // infoWindow: InfoWindow(
            //   title: 'Distance$i',
            //   snippet: '500 miles, 6 hours',
            // ),
          ),
        );
        setState(() {});
      }

      // Calculate the midpoint

      // for (int i = 0; i < result.points.length - 1; i++) {
      //   LatLng start = polylineCoordinates[i];
      //   LatLng end = polylineCoordinates[i + 1];
      //   LatLng midpoint = _calculateMidpoint(start, end);
      //   _markers.add(
      //     Marker(
      //       markerId: MarkerId('tooltip$i'),
      //       position: midpoint,
      //       icon: await TextOnImage(
      //         text: "500 miles, $i hours",
      //       ).toBitmapDescriptor(
      //           logicalSize: const Size(100, 100),
      //           imageSize: const Size(100, 100)),
      //       // infoWindow: InfoWindow(
      //       //   title: 'Distance$i',
      //       //   snippet: '500 miles, 6 hours',
      //       // ),
      //     ),
      //   );
      //   setState(() {});
      // }
    }
    _addPolyLine();
  }

  LatLng _findClosestPoint(LatLng target) {
    LatLng closestPoint = polylineCoordinates.first;
    double minDistance = double.infinity;

    for (LatLng point in polylineCoordinates) {
      double distance = _calculateDistance(target, point);
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }
    return closestPoint;
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    final double latDiff = p1.latitude - p2.latitude;
    final double lngDiff = p1.longitude - p2.longitude;
    return latDiff * latDiff + lngDiff * lngDiff;
  }

  void _initializeMarkers() async {
    _markers = {};
    _markers.add(
      Marker(
        markerId: MarkerId('origin'),
        position: origin,
        infoWindow: const InfoWindow(
          title: 'ป้าแจ้ว',
          snippet: 'MBE2400001',
        ),
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
        infoWindow:
            InfoWindow(title: 'ร้านพี่น้อย ตลาดเทเวศร์', snippet: "MBE2400002"),
        icon: await const CountWidget(count: 2).toBitmapDescriptor(
          logicalSize: const Size(25, 25),
          imageSize: const Size(50, 50),
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: MarkerId('waypoint2'),
        position: waypoint2,
        infoWindow: InfoWindow(title: 'ร้านพี่น้อย', snippet: "MBE2400003"),
        icon: await const CountWidget(count: 3).toBitmapDescriptor(
          logicalSize: const Size(25, 25),
          imageSize: const Size(50, 50),
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: MarkerId('destination'),
        position: destination,
        infoWindow:
            InfoWindow(title: 'ร้านสายหยุดร้าน9', snippet: "MBE2400004"),
        icon: await const CountWidget(count: 4).toBitmapDescriptor(
          logicalSize: const Size(25, 25),
          imageSize: const Size(50, 50),
        ),
      ),
    );
    setState(() {});
  }

  // Future<void> _generateDistanceLabels() async {
  //   if (_mapController == null) return;

  //   for (int i = 0; i < routePoints.length - 1; i++) {
  //     LatLng start = polylineCoordinates[i];
  //     LatLng end = polylineCoordinates[i + 1];
  //     LatLng midpoint = _calculateMidpoint(start, end);
  //     // LatLng center = getCenterOfPolyline(polylineCoordinates[i]);
  //     // print("Center$i : $center");

  //     _markers.add(
  //       Marker(
  //         markerId: MarkerId('tooltip$i'),
  //         position: midpoint,
  //         icon: await TextOnImage(
  //           text: "500 miles, $i hours",
  //         ).toBitmapDescriptor(
  //             logicalSize: const Size(100, 100),
  //             imageSize: const Size(100, 100)),
  //         // infoWindow: InfoWindow(
  //         //   title: 'Distance$i',
  //         //   snippet: '500 miles, 6 hours',
  //         // ),
  //       ),
  //     );
  //     setState(() {});
  //   }
  // }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline =
        Polyline(polylineId: id, color: Colors.red, points: routePoints);
    // polylines[id] = polyline;
    setState(() {});
  }

  LatLng getCenterOfPolyline(List<LatLng> polylineCoordinates) {
    double totalLat = 0.0;
    double totalLng = 0.0;

    // Loop through all coordinates to sum up latitudes and longitudes
    for (LatLng point in polylineCoordinates) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    // Find the average (center point)
    double centerLat = totalLat / polylineCoordinates.length;
    double centerLng = totalLng / polylineCoordinates.length;

    return LatLng(centerLat, centerLng);
  }

  LatLng _calculateMidpoint(LatLng start, LatLng end) {
    return LatLng(
      (start.latitude + end.latitude) / 2,
      (start.longitude + end.longitude) / 2,
    );
  }

  Future<Map<String, String>?> _getDistanceAndDuration(
      LatLng start, LatLng end) async {
    const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    final String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${start.latitude},${start.longitude}&destinations=${end.latitude},${end.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final distance = data['rows'][0]['elements'][0]['distance']['text'];
      final duration = data['rows'][0]['elements'][0]['duration']['text'];
      return {'distance': distance, 'duration': duration};
    }

    return null;
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true,
      ),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        GoogleMap(
          markers: _markers,
          initialCameraPosition: CameraPosition(
            target: origin,
            zoom: 14,
          ),
          onMapCreated: (controller) {
            setState(() {
              _mapController = controller;
            });
          },
          polylines: _polylines,
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            padding: const EdgeInsets.all(4),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ระยะทางรวม ${(sumDistance / 1000).toStringAsFixed(2)} กม.",
                  style: Styles.black18(context),
                ),
                Text(
                  "เวลารวม ${((sumDuration / 60) / 60).toStringAsFixed(2)} ชม.",
                  style: Styles.black18(context),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 2,
          top: 245,
          child: TextButton.icon(
            icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () async {
              // final String url =
              //     'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}'
              //     '&destination=${destination.latitude},${destination.longitude}'
              //     '&waypoints=$waypointsString'
              //     '&travelmode=$travelMode';
              final Uri url = Uri.parse(
                  "https://www.google.com/maps/dir/?api=1&origin=13.689600,100.608600&destination=13.918764,100.56767&waypoints=13.760493,100.474507|13.71104,100.517814&travelmode=driving");
              _launchUrl(url);
            },
            label: Text(
              "เปิด Google Maps",
              style: Styles.white18(context),
            ),
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
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(8)),
          width: 100,
          child: Text(
            text,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
