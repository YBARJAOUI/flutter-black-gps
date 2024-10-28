import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Providers for Tracking screen state
final vehicleMarkerProvider = StateProvider.autoDispose<Marker?>((ref) => null);
final routePointsProvider =
    StateProvider.autoDispose<List<LatLng>>((ref) => []);
final polylinesProvider = StateProvider.autoDispose<Set<Polyline>>((ref) => {
      Polyline(
        polylineId: PolylineId('route'),
        color: Colors.red,
        width: 5,
      )
    });
final speedProvider = StateProvider.autoDispose<int>((ref) => 0);
final mapTypeProvider =
    StateProvider.autoDispose<MapType>((ref) => MapType.normal);
