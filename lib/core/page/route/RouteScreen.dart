import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:_12sale_app/core/components/BoxShadowCustom.dart';
import 'package:_12sale_app/core/components/Loading.dart';
import 'package:_12sale_app/core/components/card/order/InvoiceCard.dart';
import 'package:_12sale_app/core/components/card/route/RouteVisitCard.dart';
import 'package:_12sale_app/core/components/card/route/RouteVisitCard.dart';
import 'package:_12sale_app/core/components/card/route/RouteVisitCard.dart';
import 'package:_12sale_app/core/components/search/CustomerDropdownSearch.dart';
import 'package:_12sale_app/core/components/search/StoreSearch.dart';
import 'package:_12sale_app/core/page/HomeScreen.dart';
import 'package:_12sale_app/core/page/route/DetailScreen.dart';
import 'package:_12sale_app/core/page/route/ShopRouteScreen.dart';
import 'package:_12sale_app/core/page/route/ShopRouteScreen.dart';
import 'package:_12sale_app/core/page/store/DetailStoreScreen.dart';
import 'package:_12sale_app/core/page/store/StoreScreen.dart';
import 'package:_12sale_app/core/styles/style.dart';
import 'package:_12sale_app/data/models/Route.dart';
import 'package:_12sale_app/data/models/search/RouteVisitFilterLocal.dart';
import 'package:_12sale_app/data/models/search/SaleRoute.dart';
// import 'package:_12sale_app/data/models/StoreFilterLocal.dart';
import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/models/route/RouteVisit.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:_12sale_app/function/SavetoStorage.dart';
import 'package:_12sale_app/main.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

List<RouteVisit> routeVisits = [];

String period =
    "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";

class Routescreen extends StatefulWidget {
  const Routescreen({super.key});

  @override
  State<Routescreen> createState() => _RoutescreenState();
}

class _RoutescreenState extends State<Routescreen> with RouteAware {
  bool _loadingRouteVisit = true;
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
    if (mounted) {
      setState(() {});
    }
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

  Future<void> _getRouteVisit() async {
    ApiService apiService = ApiService();
    await apiService.init();

    var response = await apiService.request(
      endpoint: 'api/cash/route/getRoute?area=${User.area}&period=${period}',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];
      // print("getRoute: ${response.data['data']}");
      if (mounted) {
        setState(() {
          routeVisits = data.map((item) => RouteVisit.fromJson(item)).toList();
          _loadingRouteVisit = false;
        });
      }
      print("getRoute: $routeVisits");
    }
  }

  @override
  initState() {
    super.initState();
    // _maker.addAll(_list);
    _loadSaleRoute();
    _initializePolylines();
    _initializeMarkers();

    _getRouteVisit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this screen as a route-aware widget
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      // Only subscribe if the route is a P ageRoute
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    setState(() {
      _loadingRouteVisit = true;
    });
    // Called when the screen is popped back to
    _getRouteVisit();
  }

  @override
  void dispose() {
    // Unsubscribe when the widget is disposed
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeState = Provider.of<RouteVisitFilterLocal>(context);

    return Scaffold(
      backgroundColor:
          Colors.transparent, // set scaffold background color to transparent
      body: RefreshIndicator(
        edgeOffset: 0,
        color: Colors.white,
        backgroundColor: Styles.primaryColor,
        onRefresh: () async {
          _getRouteVisit();
          routeState.routeVisitList.clear();
        },
        child: Container(
          margin: EdgeInsets.only(top: 20),
          child: LoadingSkeletonizer(
            loading: _loadingRouteVisit,
            child: ListView.builder(
              itemCount: routeState.routeVisitList.length > 0
                  ? (routeState.routeVisitList.length / 2).ceil()
                  : (routeVisits.length / 2).ceil(), // Number of rows needed
              itemBuilder: (context, index) {
                final firstIndex = index * 2;
                final secondIndex = firstIndex + 1;
                return routeState.routeVisitList.length > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RouteVisitCard(
                              item: routeState.routeVisitList[firstIndex],
                              onDetailsPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      routeId: routeState
                                          .routeVisitList[firstIndex].id,
                                      route: routeState
                                          .routeVisitList[firstIndex].day,
                                      customerNo: routeState
                                          .routeVisitList[firstIndex]
                                          .listStore![0]
                                          .storeInfo
                                          .storeId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (secondIndex <
                              routeState.routeVisitList
                                  .length) // Check if the second card exists
                            Expanded(
                              child: RouteVisitCard(
                                item: routeState.routeVisitList[secondIndex],
                                onDetailsPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(
                                        routeId: routeState
                                            .routeVisitList[secondIndex].id,
                                        route: routeState
                                            .routeVisitList[secondIndex].day,
                                        customerNo: routeState
                                            .routeVisitList[secondIndex]
                                            .listStore![0]
                                            .storeInfo
                                            .storeId,
                                      ),
                                    ),
                                  );
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => ShopRouteScreen(
                                  //       day: routeState
                                  //           .routeVisitList[secondIndex].day,
                                  //       route: routeState
                                  //           .routeVisitList[secondIndex].day,
                                  //       status: routeState
                                  //           .routeVisitList[secondIndex].day,
                                  //       listStore: routeState
                                  //           .routeVisitList[secondIndex]
                                  //           .listStore,
                                  //     ),
                                  //   ),
                                  // );
                                },
                              ),
                            )
                          else
                            Expanded(
                              child:
                                  SizedBox(), // Placeholder for spacing if no second card
                            ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RouteVisitCard(
                              item: routeVisits[firstIndex],
                              onDetailsPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopRouteScreen(
                                      routeId: routeVisits[firstIndex].id,
                                      route: routeVisits[firstIndex].day,
                                      // status: routeVisits[firstIndex].day,
                                      // listStore:
                                      //     routeVisits[firstIndex].listStore,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (secondIndex <
                              routeVisits
                                  .length) // Check if the second card exists
                            Expanded(
                              child: RouteVisitCard(
                                item: routeVisits[secondIndex],
                                onDetailsPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShopRouteScreen(
                                        routeId: routeVisits[secondIndex].id,
                                        route: routeVisits[secondIndex].day,
                                        // status: routeVisits[secondIndex].day,
                                        // listStore:
                                        //     routeVisits[secondIndex].listStore,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Expanded(
                              child:
                                  SizedBox(), // Placeholder for spacing if no second card
                            ),
                        ],
                      );
              },
            ),
          ),
        ),
      ),
    );
    // return Column(
    //   children: [
    //     // Expanded(
    //     //   child: Container(
    //     //     padding: const EdgeInsets.all(8),
    //     //     margin: EdgeInsets.all(screenWidth / 45),
    //     //     child: Stack(
    //     //       children: [
    //     //         GoogleMap(
    //     //           initialCameraPosition: const CameraPosition(
    //     //             target: origin,
    //     //             zoom: 5.0,
    //     //           ),
    //     //           markers: _markers,
    //     //           // polylines: Set<Polyline>.of(polylines.values),
    //     //           polylines: _polylines,
    //     //           mapType: MapType.normal,
    //     //           myLocationButtonEnabled: true,
    //     //           myLocationEnabled: true,
    //     //           // initialCameraPosition: _kGooglePlex,
    //     //           onMapCreated: (controller) {
    //     //             setState(() {
    //     //               _mapController = controller;
    //     //             });
    //     //             _generateDistanceLabels();
    //     //           },
    //     //         ),
    //     //         ...distanceLabels,
    //     //       ],
    //     //     ),
    //     //   ),
    //     // ),
    //     // TextButton(
    //     //   onPressed: () {
    //     //     print("test");
    //     //     // fetchPolylineDataWithDio(
    //     //     //     origin, destination, 'AIzaSyAQ9F4z5GhkeW5n8z03OK7H5CcMpzUAZr0');
    //     //   },
    //     //   child: const Text('add'),
    //     // ),
    //     // Expanded(
    //     //   child: Container(
    //     //     padding: const EdgeInsets.all(8),
    //     //     margin: EdgeInsets.all(screenWidth / 45),
    //     //     width: screenWidth,
    //     //     // color: Colors.red,
    //     //     child: Column(
    //     //       mainAxisAlignment: MainAxisAlignment.center,
    //     //       children: [
    //     //         Text(
    //     //           "ยังไม่เปิดให้บริการ ",
    //     //           style: Styles.black32(context),
    //     //         ),
    //     //       ],
    //     //     ),
    //     //   ),
    //     // ),
    // Expanded(
    //   child: Padding(
    //     padding: const EdgeInsets.only(top: 20),
    //     child: RouteTable(),
    //   ),
    // ),

    //   ],
    // );
  }
}

class RouteHeader extends StatefulWidget {
  const RouteHeader({super.key});

  @override
  State<RouteHeader> createState() => _RouteHeaderState();
}

class _RouteHeaderState extends State<RouteHeader> {
  String changeSearch = '';
  @override
  void initState() {
    super.initState();
  }

  // Future<void> _getRouteVisit() async {
  //   ApiService apiService = ApiService();
  //   await apiService.init();

  //   var response = await apiService.request(
  //     endpoint: 'api/cash/route/getRoute?area=${User.area}&period=${period}',
  //     method: 'GET',
  //   );

  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = response.data['data'];
  //     // print("getRoute: ${response.data['data']}");
  //     if (mounted) {
  //       setState(() {
  //         routeVisits = data.map((item) => RouteVisit.fromJson(item)).toList();
  //       });
  //     }
  //     print("getRoute: $routeVisits");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final routeState = Provider.of<RouteVisitFilterLocal>(context);
    List<StoreFavoriteLocal> _storeFavoriteLocal = [];
    double screenWidth = MediaQuery.of(context).size.width;
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
                                  FaIcon(
                                    FontAwesomeIcons.route,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
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
        // const Flexible(
        //   fit: FlexFit.tight,
        //   child: Padding(
        //     padding: EdgeInsets.all(8.0),
        //     child: CustomerDropdownSearch(),
        //   ),
        // ),
        Flexible(
          fit: FlexFit.tight,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                // color: Colors.white,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          // padding: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.white,
                          ),
                          child: StoreSearch(
                            key: ValueKey("Search-${changeSearch}"),
                            onStoreSelected: (data) async {
                              if (data != null) {
                                ApiService apiService = ApiService();
                                await apiService.init();
                                var response = await apiService.request(
                                  endpoint:
                                      'api/cash/route/getRoute?period=${period}&storeId=${data.storeId}',
                                  method: 'GET',
                                );

                                if (response.statusCode == 200) {
                                  final List<dynamic> data =
                                      response.data['data'];
                                  // print("getRoute: ${response.data['data']}");
                                  if (mounted) {
                                    setState(() {
                                      routeVisits = data
                                          .map((item) =>
                                              RouteVisit.fromJson(item))
                                          .toList();
                                      // _loadingRouteVisit = false;
                                    });
                                  }
                                  routeState.updateValue(routeVisits);
                                  print("getRoute: $routeVisits");
                                }
                                setState(
                                  () {
                                    _storeFavoriteLocal =
                                        routeState.storesFavoriteList;
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            routeState.routeVisitList.clear();
                            try {
                              ApiService apiService = ApiService();
                              await apiService.init();

                              var response = await apiService.request(
                                endpoint:
                                    'api/cash/route/getRoute?area=${User.area}&period=${period}',
                                method: 'GET',
                              );

                              if (response.statusCode == 200) {
                                final List<dynamic> data =
                                    response.data['data'];
                                // print("getRoute: ${response.data['data']}");
                                if (mounted) {
                                  setState(() {
                                    routeVisits = data
                                        .map(
                                            (item) => RouteVisit.fromJson(item))
                                        .toList();
                                  });
                                }
                                if (changeSearch == '') {
                                  setState(() {
                                    changeSearch = '1';
                                  });
                                } else {
                                  setState(() {
                                    changeSearch = '';
                                  });
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                      index: 1,
                                    ),
                                  ),
                                );

                                // print(
                                //     "routeState.routeVisitList ${routeState.routeVisitList.length} ");
                              }
                            } catch (e) {}
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.grey,
                              ),
                              child: BoxShadowCustom(
                                // color: Styles.success,
                                borderColor: Colors.grey[200]!,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[200]!,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 40),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.search_off_outlined,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "ล้างการค้นหา",
                                            style: Styles.black18(context),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        Text(
          text,
          style: Styles.black18(context),
        )
      ],
    );
  }
}
