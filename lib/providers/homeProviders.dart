import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:blackgps/Routers/router.dart';
import 'package:blackgps/providers/commonProviders.dart';
import 'package:blackgps/utils/TokenManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

// Define your providers
final imeiListProvider = StateProvider<List<String>>((ref) => []);
final cardataProvider = StateProvider<Map<String, List<dynamic>>>((ref) => {});
final markersProvider = StateProvider<Set<Marker>>((ref) => {});
final currentMapTypeProvider = StateProvider<MapType>((ref) => MapType.hybrid);
final selectedIndexProvider = StateProvider<int>((ref) => 0);
final elementValuesProvider = StateProvider<Map<String, dynamic>>((ref) => {});
final isLoadingProvider = StateProvider<bool>((ref) => true);
final markersLoadedProvider = StateProvider<bool>((ref) => false);

Future<String?> getAddressFromLatLng(double latitude, double longitude) async {
  final String baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  final String location = '$latitude,$longitude';

  final String url =
      '$baseUrl?location=$location&radius=50&type=address&key=AIzaSyDH3FndsyKM3NH7rZNXbgensB_TumqoC-E';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['name'];
      } else {
        return null;
      }
    } else {
      print(
          'Erreur lors de la récupération des données : ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Erreur lors de la requête HTTP : $e');
    return null;
  }
}

final fetchCarsFutureProvider = FutureProvider<void>((ref) async {
  final tokens = await TokenStorage().loadTokens();
  if (tokens == null) {
    print('Error: tokens are null');
    return;
  }

  final apiService = ref.read(apiServiceProvider);

  try {
    final List response =
        await apiService.get('app/allcarslastposition', headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokens['accessToken']}'
    });

    if (response == null || response.isEmpty) {
      print('Error: response is null or empty');
      return;
    }

    Map<String, List<dynamic>> allCarData = {}; // Map to store all car data
    Set<Marker> allMarkers = {}; // Set to store all markers
    List<Future<void>> markerFutures = [];

    for (var data in response) {
      String name = data['car']['name'] ?? "";
      String plate_number = data['car']['plate_number'];
      String image = data['car']['image'];
      int id = data['car']["id"];
      String gpsdevicePhoneNumber = data['car']["gpsdevice"]['phone_number'];
      String imei = data["car"]["gpsdevice"]["imei"] ?? "";
      double latitude = double.tryParse(
              data["latest_tracker_data"]["data"]['lat'].toString()) ??
          0.0;
      double longitude = double.tryParse(
              data["latest_tracker_data"]["data"]['lon'].toString()) ??
          0.0;
      List<dynamic> ioElements =
          data["latest_tracker_data"]["data"]['ioElements'] ?? [];

      final elementValues = ref.read(elementValuesProvider.notifier);
      for (var element in ioElements) {
        String label = element['label'] ?? 'Unknown';
        dynamic value = element['value'] ?? 'Unknown';
        elementValues.state[label] = value;
      }

      int power = elementValues.state['Ignition'];
      double totalkm = elementValues.state['Total Odometer'] / 1000;
      final speed = elementValues.state['Speed'];
      final fuel = elementValues.state['Average Fuel Use'] / 10;
      print(fuel);
      final number = data["car"]["numero_voiture"] ?? "0";
      Color markerColor;
      if (elementValues.state['Ignition'] == 0) {
        markerColor = Colors.red;
      } else if (elementValues.state['Movement'] == 0) {
        markerColor = Colors.orange;
      } else {
        markerColor = Colors.blue;
      }

      String? placeName = await getAddressFromLatLng(latitude, longitude);

      // Add marker creation to the list of futures
      markerFutures
          .add(createMarkerBitmap(number, markerColor).then((markerIcon) {
        Marker marker = Marker(
          markerId: MarkerId('id-$imei'),
          position: LatLng(latitude, longitude),
          icon: markerIcon,
          onTap: () {
            final router = ref.watch(routerProvider);

            if (router != null) {
              router.go('/tracking/$imei/$latitude/$longitude');
            } else {
              print('Error: GoRouter is not initialized');
            }
          },
        );

        allMarkers.add(marker);

        allCarData[imei] = [
          name,
          number,
          plate_number,
          image,
          placeName,
          power,
          totalkm,
          speed,
          fuel,
          gpsdevicePhoneNumber,
          id,
          latitude,
          longitude
        ];
      }));
    }

    // Wait for all marker futures to complete
    await Future.wait(markerFutures);

    ref.read(markersProvider.notifier).update((state) {
      state = allMarkers;
      ref.read(markersLoadedProvider.notifier).state =
          true; // Set markers loaded
      return state;
    });

    ref.read(cardataProvider.notifier).update((state) {
      state = allCarData;
      return state;
    });
  } catch (e) {
    print('Error getting cars: $e');
  } finally {}
});

// Function to create marker bitmap
Future<BitmapDescriptor> createMarkerBitmap(int number, Color couleur) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);
  final Paint paintCircle = Paint()..color = couleur;
  final Paint paintBorder = Paint()
    ..color = Colors.white
    ..strokeWidth = 10
    ..style = PaintingStyle.stroke;
  final double radius = 35;

  canvas.drawCircle(Offset(radius, radius), radius, paintCircle);
  canvas.drawCircle(Offset(radius, radius),
      radius - paintBorder.strokeWidth / 2, paintBorder);

  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: "$number",
      style: TextStyle(
        fontSize: radius - paintBorder.strokeWidth,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: ui.TextDirection.ltr,
  );

  textPainter.layout();
  final Offset textOffset = Offset(
    radius - textPainter.width / 2,
    radius - textPainter.height / 2,
  );

  textPainter.paint(canvas, textOffset);

  final ui.Image image = await pictureRecorder.endRecording().toImage(75, 75);
  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List byteDataList = byteData!.buffer.asUint8List();

  return BitmapDescriptor.fromBytes(byteDataList);
}
