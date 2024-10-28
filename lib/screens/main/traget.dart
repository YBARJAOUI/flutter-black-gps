import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:blackgps/components/PlayBottom.dart';
import 'package:blackgps/constants/colors.dart';
import 'package:blackgps/utils/ApiService.dart';
import 'package:blackgps/utils/TokenManagement.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ffcache/ffcache.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Traget extends StatefulWidget {
  final String imei;
  final DateTime startDate;
  final DateTime endDate;

  const Traget(
      {required this.imei, required this.startDate, required this.endDate});

  @override
  _TragetState createState() => _TragetState();
}

class _TragetState extends State<Traget> {
  List<LatLng> routePoints = []; // This will hold all the points in the route
  int speedMultiplierIndex = 0;
  List<int> speedMultipliers = [1, 2, 4, 8]; // Speeds: 1x, 2x, 4x, 8x
  double totaleOdmetre = 0;
  bool isPlaying = false;
  int currentPointIndex = 0;
  Timer? playbackTimer;
  Marker? movingMarker;
  Set<Marker> markers = {};
  GoogleMapController? mapController; // Ensure this is here

  MapType _currentMapType = MapType.hybrid;
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
              ? MapType.hybrid
              : MapType.normal;
    });
  }

  List<Polyline> polylines = [];
  late LatLng initialPosition = LatLng(0, 0);
  bool isLoading = false;
  final cache = FFCache();

  @override
  void initState() {
    super.initState();
    gpsinfo(widget.imei);
  }

  // void createInitialPolyline() {
  //   // Initialize an empty polyline
  //   Polyline polyline = Polyline(
  //     polylineId: PolylineId('current_route'),
  //     points: [],
  //     color: Color.fromARGB(255, 37, 86, 192),
  //     width: 5,
  //   );
  //   setState(() {
  //     polylines.add(polyline);
  //   });
  // }

  void updateRoutePolyline(LatLng newPosition) {
    if (polylines.isNotEmpty) {
      Polyline oldPolyline = polylines.first;
      List<LatLng> updatedPoints = List.from(oldPolyline.points)
        ..add(newPosition);
      Polyline updatedPolyline = Polyline(
        polylineId: oldPolyline.polylineId,
        points: updatedPoints,
        color: oldPolyline.color,
        width: oldPolyline.width,
      );
      setState(() {
        polylines[0] =
            updatedPolyline; // Replace the old polyline with the updated one
      });
    }
  }

  @override
  void dispose() {
    playbackTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  Future<void> fetchDirections(List<LatLng> points) async {
    const int segmentSize = 20;
    int numberOfSegments = (points.length / segmentSize).ceil();

    for (int i = 0; i < numberOfSegments; i++) {
      int start = i * segmentSize;
      int end = min(start + segmentSize, points.length);

      List<LatLng> segment = points.sublist(start, end);

      if (segment.length < 2) continue; // Skip segments with less than 2 points

      LatLng origin = segment.first;
      LatLng destination = segment.last;

      String waypoints = '';
      if (i < numberOfSegments - 1) {
        // Add the first point of the next segment as a waypoint
        LatLng nextSegmentStart = points[end];
        waypoints =
            '&waypoints=${nextSegmentStart.latitude},${nextSegmentStart.longitude}';
      }

      String url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}${waypoints}&alternatives=false&key=AIzaSyDH3FndsyKM3NH7rZNXbgensB_TumqoC-E';

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var routes = jsonResponse['routes'];
        if (routes.isNotEmpty) {
          var encodedPoly = routes[0]['overview_polyline']['points'];
          List<LatLng> routePoints = decodePolyline(encodedPoly);

          setState(() {
            polylines.add(Polyline(
              polylineId:
                  PolylineId('segment_${i}'), // Unique ID for each segment
              points: routePoints,
              color: Color.fromARGB(255, 37, 86, 192),
              width: 5,
            ));
          });
          print('hhhh$polylines');
        }
      } else {
        print('Error fetching directions: ${response.statusCode}');
      }
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng point = LatLng(lat / 1E5, lng / 1E5);
      points.add(point);
    }

    return points;
  }

  Future<BitmapDescriptor> createArrowMarkerIcon(
      Color color, double heading) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double arrowWidth = 45.0;
    const double arrowHeight = 45.0;

    // Dessiner une flèche pointant vers le haut
    Path path = Path();
    path.moveTo(arrowWidth / 2, 0);
    path.lineTo(0, arrowHeight);
    path.lineTo(arrowWidth, arrowHeight);
    path.close();

    canvas.translate(arrowWidth / 2, arrowHeight / 2);
    canvas.rotate(heading); // Rotation de la flèche selon l'angle donné
    canvas.translate(-arrowWidth / 2, -arrowHeight / 2);
    canvas.drawPath(path, paint);

    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(arrowWidth.toInt(), arrowHeight.toInt());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List byteList = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(byteList);
  }

  Color getColorForStatus(int movement, int ignition) {
    if (ignition == 0) {
      return Colors.red; // Red if the ignition is off
    } else if (movement == 0) {
      return Colors.orange; // Orange if the ignition is on but no movement
    } else {
      return Colors.green; // Green otherwise (ignition on and moving)
    }
  }

  void updateMarkerPosition(LatLng newPosition, double heading) {
    createArrowMarkerIcon(Colors.green, heading).then((customIcon) {
      setState(() {
        movingMarker = Marker(
          markerId: MarkerId("moving"),
          position: newPosition,
          anchor: Offset(0.5, 0.5),
          icon: customIcon,
        );
        markers.removeWhere((m) => m.markerId == MarkerId("moving"));
        markers.add(movingMarker!);

        // Update the polyline with the new position
        // if (polylines.isNotEmpty) {
        //   Polyline oldPolyline = polylines.first;
        //   List<LatLng> updatedPoints = List.from(oldPolyline.points)
        //     ..add(newPosition);
        //   Polyline updatedPolyline = Polyline(
        //     polylineId: oldPolyline.polylineId,
        //     points: updatedPoints,
        //     color: oldPolyline.color,
        //     width: oldPolyline.width,
        //   );
        //   polylines[0] =
        //       updatedPolyline; // Replace the old polyline with the updated one
        // }
      });

      // Optional: Center the map on the new marker position
      mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
    });
  }

  double calculateHeading(LatLng from, LatLng to) {
    double deltaLongitude = to.longitude - from.longitude;
    double deltaLatitude = to.latitude - from.latitude;
    return atan2(deltaLongitude, deltaLatitude);
  }

  void togglePlayback() {
    if (!mounted) return;
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      startPlayback();
    } else {
      stopPlayback(); // Only pause, not reset
    }
  }

  void cycleSpeed() {
    setState(() {
      speedMultiplierIndex =
          (speedMultiplierIndex + 1) % speedMultipliers.length;
    });

    if (isPlaying) {
      // Restart playback with new speed if it's currently playing
      startPlayback();
    }
  }

  void startPlayback() {
    playbackTimer?.cancel();
    playbackTimer = Timer.periodic(
        Duration(milliseconds: 1000 ~/ speedMultipliers[speedMultiplierIndex]),
        (timer) {
      if (!mounted) {
        timer.cancel();
      } else {
        if (currentPointIndex < routePoints.length) {
          LatLng currentPosition = routePoints[currentPointIndex];
          double heading = 0;
          if (currentPointIndex < routePoints.length - 1) {
            heading = calculateHeading(
                currentPosition, routePoints[currentPointIndex + 1]);
          }
          updateMarkerPosition(currentPosition, heading);
          if (currentPointIndex == 0) {
            clearOldPath(); // Clear the path only at the start of the playback
          }
          updateRoutePolyline(currentPosition);
          currentPointIndex++;
        } else {
          stopPlayback(true); // True to reset when reaching the end
        }
      }
    });
  }

  void stopPlayback([bool reset = false]) {
    if (!mounted) return;
    playbackTimer?.cancel();
    if (reset) {
      resetPlayback(); // Reset playback to the start if specified
    }
  }

  void resetPlayback() {
    setState(() {
      currentPointIndex = 0; // Reset index to start from the beginning
      clearOldPath();
      if (routePoints.isNotEmpty) {
        double initialHeading =
            calculateHeading(routePoints.first, routePoints[1]);
        updateMarkerPosition(routePoints.first, initialHeading);
      }
    });
  }

  void clearOldPath() {
    setState(() {
      polylines.clear();
      polylines.add(Polyline(
        polylineId: PolylineId('current_route'),
        points: [],
        color: Colors.blue,
        width: 5,
      ));
    });
  }

  void traitement(dynamic response, String imei) async {
    List<LatLng> allPoints = [];
    double totalOdometerFirst = 0.0;
    double totalOdometerLast = 0.0;
    // Extraction des données GPS
    for (var data in response) {
      double latitude = data['data']['lat'].toDouble();
      double longitude = data['data']['lon'].toDouble();

      allPoints.add(LatLng(latitude, longitude));

      if (totalOdometerFirst == 0.0) {
        totalOdometerFirst = data['data']['ioElements']
            .firstWhere((element) => element['id'] == 16,
                orElse: () => null)['value']
            .toDouble();
      }

      totalOdometerLast = data['data']['ioElements']
          .firstWhere((element) => element['id'] == 16,
              orElse: () => null)['value']
          .toDouble();
    }
    totaleOdmetre = (totalOdometerLast - totalOdometerFirst) / 1000;
    double initialHeading = 0;

    if (allPoints.isNotEmpty) {
      await fetchDirections(allPoints);

      routePoints =
          convertPolylineListToLatLngList(polylines); // Save for playback
      // createInitialPolyline(); // Initialize the polyline for playback

      initialPosition = allPoints.first;
      if (allPoints.length > 1) {
        initialHeading = calculateHeading(allPoints[0], allPoints[1]);
      }
      updateMarkerPosition(allPoints.first, initialHeading);

      markers.add(Marker(
        markerId: MarkerId('start'),
        position: allPoints.first,
        infoWindow: InfoWindow(title: 'Départ'),
      ));
      markers.add(Marker(
        markerId: MarkerId('end'),
        position: allPoints.last,
        infoWindow: InfoWindow(title: 'Arrivée'),
      ));
    } else {
      initialPosition = LatLng(33.0, -5.0);
    }

    setState(() {
      isLoading = false;
    });
  }

  List<LatLng> convertPolylineListToLatLngList(List<Polyline> polylines) {
    List<LatLng> latLngList = [];
    for (Polyline polyline in polylines) {
      latLngList.addAll(polyline.points);
    }
    return latLngList;
  }

  // void traitement(dynamic response, String imei) async {
  //   List<LatLng> allPoints = [];
  //   int markerNumber = 1;
  //   bool canPlaceMarker = true;

  //   // Extraction des données GPS
  //   for (var data in response) {
  //     double latitude = data['data']['lat'].toDouble();
  //     double longitude = data['data']['lon'].toDouble();
  //     if (latitude == 0 && longitude == 0) continue;

  //     allPoints.add(LatLng(latitude, longitude));
  //   }

  //   double initialHeading = 0;

  //   if (allPoints.isNotEmpty) {
  //     fetchDirections(allPoints);

  //     routePoints = allPoints; // Save for playback
  //     createInitialPolyline(); // Initialize the polyline for playback

  //     initialPosition = allPoints.first;
  //     if (allPoints.length > 1) {
  //       initialHeading = calculateHeading(allPoints[0], allPoints[1]);
  //     }
  //     updateMarkerPosition(allPoints.first, initialHeading);

  //     markers.add(Marker(
  //       markerId: MarkerId('start'),
  //       position: allPoints.first,
  //       infoWindow: InfoWindow(title: 'Départ'),
  //     ));
  //     markers.add(Marker(
  //       markerId: MarkerId('end'),
  //       position: allPoints.last,
  //       infoWindow: InfoWindow(title: 'Arrivée'),
  //     ));
  //   } else {
  //     initialPosition = LatLng(33.0, -5.0);
  //   }

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // void traitement(dynamic response, String imei) async {
  //   List<LatLng> allPoints = [];
  //   int markerNumber = 1;
  //   bool canPlaceMarker = true;
  //   print('hhh$response');
  //   // for (var data in response) {
  //   //   double latitude = data['data']['lat'].toDouble();
  //   //   double longitude = data['data']['lon'].toDouble();
  //   //   if (latitude == 0 && longitude == 0) continue;

  //   //   allPoints.add(LatLng(latitude, longitude));
  //   //   var ioElements = data['data']['ioElements'];
  //   //   var ignition = ioElements.firstWhere(
  //   //       (element) => element['label'] == 'Ignition',
  //   //       orElse: () => null);

  //   //   if (ignition != null && ignition['valueHuman'] == 'Yes') {
  //   //     canPlaceMarker = true;
  //   //   } else if (ignition != null &&
  //   //       ignition['valueHuman'] == 'No' &&
  //   //       canPlaceMarker) {
  //   //     BitmapDescriptor markerIcon = await createMarkerBitmap(markerNumber);
  //   //     Marker marker = Marker(
  //   //       markerId: MarkerId('no_ignition_$markerNumber'),
  //   //       position: LatLng(latitude, longitude),
  //   //       icon: markerIcon,
  //   //     );
  //   //     markers.add(marker);
  //   //     markerNumber++;
  //   //     canPlaceMarker = false;
  //   //   }
  //   // }
  //   double initialHeading = 0;

  //   if (allPoints.isNotEmpty) {
  //     createPolyline(allPoints);

  //     routePoints = allPoints; // Save for playback
  //     createInitialPolyline(); // Initialize the polyline for playback

  //     initialPosition = allPoints.first;
  //     if (allPoints.length > 1) {
  //       initialHeading = calculateHeading(allPoints[0], allPoints[1]);
  //     }
  //     updateMarkerPosition(allPoints.first, initialHeading);

  //     markers.add(Marker(
  //       markerId: MarkerId('start'),
  //       position: allPoints.first,
  //       infoWindow: InfoWindow(title: 'Départ'),
  //     ));
  //     markers.add(Marker(
  //       markerId: MarkerId('end'),
  //       position: allPoints.last,
  //       infoWindow: InfoWindow(title: 'Arrivée'),
  //     ));
  //   } else {
  //     initialPosition = LatLng(33.0, -5.0);
  //   }

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  void createPolyline(List<LatLng> points) {
    Polyline polyline = Polyline(
      polylineId: PolylineId('route_${polylines.length}'),
      points: points,
      color: Color.fromARGB(255, 37, 86, 192),
      width: 5,
    );
    setState(() {
      polylines.add(polyline);
    });
  }

  Future<BitmapDescriptor> createMarkerBitmap(int number) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paintCircle = Paint()..color = Colors.blue;
    final Paint paintBorder = Paint()
      ..color = Colors.white
      ..strokeWidth = 75 / 10
      ..style = PaintingStyle.stroke;
    final double radius = 75 / 2;

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

  void gpsinfo(String imei) async {
    final apiService = ApiService();
    final token = await TokenStorage().loadTokens();
    String startDate =
        DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(widget.startDate.toUtc());
    String endDate =
        DateFormat("yyyy-MM-ddTHH:mm:ss'Z'").format(widget.endDate.toUtc());
    if (token == null) {
      print("Token is null");
      return;
    }
    try {
      final response = await apiService.get(
          'app/trajet?imei=$imei&start_date=$startDate&end_date=$endDate',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${token['accessToken']}'
          });
      if (response != null) {
        print("jjjj$response");
        traitement(response[0]["tracker_data"], imei);
      }
    } catch (e) {
      showerror(e);
    }
  }

  void showerror(Object e) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text('pas de data pour ce jour  : $e'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    setState(() => isLoading = false);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
    // If you need to perform any action immediately after the map loads, do it here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.blueColor,
        title: Text(
          'history.trip'.tr(),
          style: TextStyle(color: CustomColors.whiteColor, fontSize: 24),
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _onMapCreated(controller);
                  },
                  initialCameraPosition: CameraPosition(
                    target: initialPosition,
                    zoom: 15.0,
                  ),
                  mapType: _currentMapType,
                  polylines: Set<Polyline>.of(polylines),
                  markers: markers.toSet()
                    ..add(movingMarker ?? Marker(markerId: MarkerId("dummy"))),
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Positioned(
                  top: 10,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: _onMapTypeButtonPressed,
                    heroTag: "mapTypeControlFAB", // Unique tag for this button

                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    backgroundColor: Color.fromARGB(183, 255, 255, 255),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.layers,
                        size: 36.0,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Positioned(
                  bottom: 25,
                  left: 15,
                  right: 15,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Date sélectionner: ${DateFormat('yyyy-MM-dd').format(widget.startDate)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Assuming PlaybackControlBar is a custom widget you've defined
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            PlaybackControlBar(
                              onPlayPausePressed: togglePlayback,
                              isPlaying: isPlaying,
                            ),
                            Text(
                              'Trajet: $totaleOdmetre' + ' km',
                              style: TextStyle(
                                fontWeight: ui.FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            FloatingActionButton(
                              onPressed: cycleSpeed,
                              mini: true,
                              heroTag: "speedControlFAB",
                              child: Text(
                                  "${speedMultipliers[speedMultiplierIndex]}x"),
                              backgroundColor:
                                  ui.Color.fromARGB(190, 33, 149, 243),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
