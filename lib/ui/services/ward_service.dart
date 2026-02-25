import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class WardService {
  static List<dynamic> _features = [];

  /// Load all ward GeoJSON files
  static Future<void> initialize() async {
    if (_features.isNotEmpty) return;

    // List all GeoJSON files manually
    final files = [
      'assets/data/A.geojson',
      'assets/data/B.geojson',
      'assets/data/C.geojson',
      'assets/data/D.geojson',
      'assets/data/E.geojson',
      'assets/data/FN.geojson',
      'assets/data/FS.geojson',
      'assets/data/GN.geojson',
      'assets/data/GS.geojson',
      'assets/data/HE.geojson',
      'assets/data/HW.geojson',
      'assets/data/KE.geojson',
      'assets/data/KW.geojson',
      'assets/data/L.geojson',
      'assets/data/ME.geojson',
      'assets/data/MW.geojson',
      'assets/data/N.geojson',
      'assets/data/PN.geojson',
      'assets/data/PS.geojson',
      'assets/data/RC.geojson',
      'assets/data/RN.geojson',
      'assets/data/RS.geojson',
      'assets/data/S.geojson',
      'assets/data/T.geojson',
    ];

    for (var file in files) {
      final geojsonString = await rootBundle.loadString(file);
      final data = jsonDecode(geojsonString);
      if (data['features'] != null) {
        _features.addAll(data['features']);
      }
    }
  }

  /// Returns the ward name from a lat/lng
  Future<String?> getWardFromLocation(Position position) async {
    await initialize();

    if (_features.isEmpty) return null;

    for (var feature in _features) {
      final geometry = feature['geometry'];
      final properties = feature['properties'];
      if (geometry == null || properties == null) continue;

      final wardName = properties['ward'];
      if (wardName == null) continue;

      if (_isPointInMultiPolygon(
          position.longitude, position.latitude, geometry['coordinates'])) {
        return wardName;
      }
    }

    return null;
  }

  /// Check if point is inside MultiPolygon
  bool _isPointInMultiPolygon(
      double lng, double lat, List<dynamic> coordinates) {
    for (var polygon in coordinates) {
      for (var ring in polygon) {
        if (_isPointInPolygon(lng, lat, ring)) return true;
      }
    }
    return false;
  }

  /// Ray-casting algorithm for point-in-polygon
  bool _isPointInPolygon(double lng, double lat, List<dynamic> polygon) {
    int intersections = 0;

    for (int i = 0; i < polygon.length - 1; i++) {
      final x1 = polygon[i][0];
      final y1 = polygon[i][1];
      final x2 = polygon[i + 1][0];
      final y2 = polygon[i + 1][1];

      if (((y1 > lat) != (y2 > lat)) &&
          (lng < (x2 - x1) * (lat - y1) / (y2 - y1) + x1)) {
        intersections++;
      }
    }

    return intersections % 2 != 0;
  }
}
