import 'dart:math';
import 'package:flutter/foundation.dart';

double R = 6378137; // Earth's radius in meters
double radius = 50; // Radius in meters

/// Calculate the distance between two latitude and longitude points using the Haversine formula
double calculateDistance(double originLat, double originLng,
    double destinationLat, double destinationLng) {
  // Check if the two points are the same (very small threshold for floating-point precision)
  if (originLat == destinationLat && originLng == destinationLng) {
    return 0.0;
  }

  // Convert degrees to radians
  double originLatRad = originLat * pi / 180;
  double originLngRad = originLng * pi / 180;
  double destinationLatRad = destinationLat * pi / 180;
  double destinationLngRad = destinationLng * pi / 180;

  // Differences between the latitudes and longitudes
  double dLat = destinationLatRad - originLatRad;
  double dLon = destinationLngRad - originLngRad;

  // Haversine formula
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(originLatRad) *
          cos(destinationLatRad) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // Distance in meters
  double distance = R * c;
  return distance;
}

/// Check if the point is out of range (more than the specified radius)
bool isOutOfRange(double originLat, double originLng, double destinationLat,
    double destinationLng, double radius) {
  double distance =
      calculateDistance(originLat, originLng, destinationLat, destinationLng);
  // print(originLat);
  // print(originLng);
  // print(destinationLat);
  // print(destinationLng);
  // print(distance);
  if (kDebugMode) {
    print(distance > radius);
  }
  return distance > radius;
}
