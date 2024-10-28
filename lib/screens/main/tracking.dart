import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:blackgps/components/CustomBottomNavBar.dart';
import 'package:blackgps/constants/colors.dart';
import 'package:blackgps/providers/commonProviders.dart';
import 'package:blackgps/providers/homeProviders.dart';
import 'package:blackgps/providers/trackingProviders.dart';
import 'package:blackgps/utils/TokenManagement.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ffcache/ffcache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:speedometer_chart/speedometer_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class Tracking extends ConsumerStatefulWidget {
  final String imei;
  final double latitude;
  final double longitud;

  Tracking({
    required this.imei,
    required this.latitude,
    required this.longitud,
  });

  @override
  _TrackingState createState() => _TrackingState();
}

class _TrackingState extends ConsumerState<Tracking> {
  GoogleMapController? mapController;
  Timer? timer;
  final cache = FFCache();
  late List<String> imeiList;
  late Future<void> _fetchDataFuture;
  late Map<String, List<dynamic>> cardata;
  Map<String, dynamic> elementValues = {};

  Future<void> fetchCars() async {
    if (!mounted) return;

    final tokens = await TokenStorage().loadTokens();
    if (tokens == null) {
      print("Token is null");
      return;
    }

    final apiService = ref.read(apiServiceProvider);
    try {
      final List response = await apiService.get('app/cars', headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${tokens['accessToken']}'
      });

      setState(() {
        imeiList = response.map((car) => car['gpsdevice'] as String).toList();

        for (var car in response) {
          cardata.putIfAbsent(car['gpsdevice'],
              () => [car['name'], car['plate_number'], car['numero_voiture']]);
        }

        if (imeiList.isNotEmpty) {
          for (String imei in imeiList) {
            gpsinfo(imei);
          }
        }
      });
    } catch (e) {
      print('Error get cars : $e');
    }
  }

  void gpsinfo(String imei) async {
    try {
      fetchLatestData(imei);
    } catch (e) {
      print('Errors: $e');
    }
  }

  Future<void> fetchLatestData(String imei) async {
    final tokens = await TokenStorage().loadTokens();
    final apiService = ref.read(apiServiceProvider);
    if (tokens == null) {
      print("Token is null");
      return;
    }
    bool dataFound = false;

    try {
      final response =
          await apiService.get('app/sqltracker/$imei/last', headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${tokens['accessToken']}'
      });

      if (response != null) {
        traitement(response, imei);
      }
    } catch (e) {
      print("error here point : ${e}");
    }
  }

  void traitement(response, imei) async {
    for (var data in response) {
      double latitude = double.parse(data['lat'].toString());
      double longitude = double.parse(data['lon'].toString());
      List<dynamic> ioElements = data['ioElements'];

      for (var element in ioElements) {
        String label = element['label'];
        dynamic value = element['value'];
        elementValues[label] = value;
      }

      print(elementValues);
      final number = cardata[imei]?[2];
      Color markerColor;
      if (elementValues['Ignition'] == 0) {
        markerColor = Colors.red; // Red if the ignition is off
      } else if (elementValues['Movement'] == 0) {
        markerColor = Colors.orange; // Orange if no movement
      } else {
        markerColor = Colors.blue; // Green otherwise (ignition on and moving)
      }
    }
  }

  @override
  void initState() {
    super.initState();
    cardata = {};
    elementValues = {};
    imeiList = [];
    _fetchDataFuture = fetchCars();
    timer = Timer.periodic(
        Duration(seconds: 3), (Timer t) => fetchVehiclePosition());
  }

  double calculateHeading(LatLng start, LatLng end) {
    double deltaLongitude = end.longitude - start.longitude;
    double deltaLatitude = end.latitude - start.latitude;
    return atan2(deltaLongitude, deltaLatitude);
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

  void fetchVehiclePosition() async {
    if (!mounted) return;
    final tokens = await TokenStorage().loadTokens();
    final apiService = ref.read(apiServiceProvider);
    if (tokens == null) {
      print("Token is null");
      return;
    }

    final response =
        await apiService.get('app/sqltracker/${widget.imei}/last', headers: {
      'Authorization': 'Bearer ${tokens['accessToken']}',
      'Content-Type': 'application/json'
    });

    print("this is the live response : ${response}");

    if (response != null) {
      LatLng newPosition = LatLng(double.parse(response[0]['lat'].toString()),
          double.parse(response[0]['lon'].toString()));

      int movement = 0;
      int ignition = 0;
      List<dynamic> ioElements = response[0]['ioElements'];
      for (var element in ioElements) {
        if (element['label'] == 'Movement') {
          movement = element['value'];
        } else if (element['label'] == 'Ignition') {
          ignition = element['value'];
        }
        if (element['label'] == 'Speed') {
          ref.read(speedProvider.notifier).state = element['value'];
        }
      }
      if (mounted) {
        if (ref.read(vehicleMarkerProvider) == null) {
          initializeMarker(newPosition);
        } else {
          animateMarker(newPosition, movement, ignition);
        }
      }
    } else {
      print('Failed to load vehicle position');
    }
  }

  void animateMarker(LatLng newPosition, int movement, int ignition) {
    if (!mounted) return;
    var oldPosition = ref.read(vehicleMarkerProvider)!.position;
    var steps = 10;
    var stepDuration = Duration(milliseconds: 100);

    for (int i = 1; i <= steps; i++) {
      Timer(Duration(milliseconds: stepDuration.inMilliseconds * i), () async {
        if (mounted) {
          double lat = oldPosition.latitude +
              (newPosition.latitude - oldPosition.latitude) / steps * i;
          double lng = oldPosition.longitude +
              (newPosition.longitude - oldPosition.longitude) / steps * i;
          LatLng intermediatePosition = LatLng(lat, lng);

          double heading = calculateHeading(oldPosition, newPosition);
          Color color = getColorForStatus(
              movement, ignition); // Determine color based on status

          var arrowIcon = await createArrowMarkerIcon(color, heading);
          if (!mounted) return;
          ref.read(vehicleMarkerProvider.notifier).state = Marker(
            markerId: MarkerId('vehicle'),
            position: intermediatePosition,
            anchor: Offset(0.5, 0.5),
            icon: arrowIcon,
          );

          // Add intermediate position to route points
          ref.read(routePointsProvider.notifier).update((state) {
            state.add(intermediatePosition);
            return state;
          });

          // Update polyline
          Polyline oldPolyline = ref
              .read(polylinesProvider.notifier)
              .state
              .firstWhere((poly) => poly.polylineId.value == 'route',
                  orElse: () => Polyline(polylineId: PolylineId('route')));
          ref.read(polylinesProvider.notifier).update((state) {
            state.remove(oldPolyline);
            state.add(Polyline(
              polylineId: PolylineId('route'),
              points: List.from(ref.read(routePointsProvider)),
              color: Colors.blue,
              width: 5,
            ));
            return state;
          });

          // Animate the camera to follow the marker without changing the zoom
          mapController?.getZoomLevel().then((currentZoom) {
            mapController?.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: intermediatePosition, zoom: currentZoom)));
          });
        }
      });
    }
  }

  void initializeMarker(LatLng position) async {
    var customIcon = await createCustomMarkerIcon();
    ref.read(vehicleMarkerProvider.notifier).state = Marker(
      markerId: MarkerId('vehicle1'),
      position: position,
      anchor: Offset(0.5, 0.5),
      icon: customIcon,
    );
    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 15),
    ));
  }

  Future<BitmapDescriptor> createCustomMarkerIcon() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.blue;
    const double circleSize = 30.0;

    canvas.drawCircle(
        Offset(circleSize / 2, circleSize / 2), circleSize / 2, paint);

    final ui.Image image = await pictureRecorder
        .endRecording()
        .toImage(circleSize.toInt(), circleSize.toInt());
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List byteList = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(byteList);
  }

  Future<void> launchGoogleMaps(double lat, double lng) async {
    var url = 'google.navigation:q=${lat.toString()},${lng.toString()}';
    var fallbackUrl =
        'https://www.google.com/maps/search/?api=1&query=${lat.toString()},${lng.toString()}';
    try {
      bool launched = false;
      if (!kIsWeb) {
        launched = await launchUrl(Uri.parse(url));
      }
      if (!launched) {
        await launchUrl(Uri.parse(fallbackUrl));
      }
    } catch (e) {
      await launchUrl(Uri.parse(fallbackUrl));
    }
  }

  Future<void> shareCoordinates() async {
    try {
      final vehicleMarker = ref.read(vehicleMarkerProvider);
      if (vehicleMarker != null) {
        LatLng position = vehicleMarker.position;
        await launchGoogleMaps(position.latitude, position.longitude);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$e',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[800], // Deep red color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }

  void _showMarkerInfo() {
    final data =
        cardata[widget.imei]; // Récupérer les données pour l'IMEI donné
    if (data != null) {
      double ecoScore = elementValues['Eco Score'] / 10 ?? 0;
      int trajet = elementValues['Trip Odometer'] ?? 0;
      double voltage = elementValues['Ext Voltage'] / 1000 ?? 0;
      int speed = elementValues['Speed'] ?? 0;
      int mouvment = elementValues['Movement'] ?? 0;
      Color progressColor = ColorTween(
        begin: Colors.red,
        end: Colors.green,
      ).lerp(ecoScore / 100)!;
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300, // Ajustez la hauteur selon vos besoins
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: 100,
                    ),
                    Text(
                      (data[0]),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text('${'carbottomsheet.platenumber'.tr()}: ${data[1]}'),
                Container(
                  padding: EdgeInsets.all(15.0),
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 252, 252, 252),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Image.asset('assets/icon-eco.png',
                              width: 55, height: 55), // Icône ECO-SCORE
                          SizedBox(
                            width: 100.0,
                            height: 100.0,
                            child: CircularProgressIndicator(
                              value: ecoScore / 100,
                              strokeWidth: 10.0,
                              backgroundColor:
                                  Color.fromARGB(255, 228, 227, 227),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(progressColor),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 15), // Espace entre le cercle et le texte
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'carbottomsheet.ecoscore'.tr(),
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${ecoScore} %",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 60),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'carbottomsheet.trip'.tr(),
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${trajet / 100} Km",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Boxicons.bxs_car_battery,
                          color: CustomColors.blackColor,
                          size: 30,
                        ),
                        Text('$voltage V', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Boxicons.bx_tachometer,
                          color: CustomColors.blackColor,
                          size: 30,
                        ),
                        Text("$speed Km/h", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle,
                            color: elementValues["Ignition"] == 0
                                ? Colors.red
                                : Colors.green,
                            size: 20),
                        Text(elementValues["Ignition"] == 0 ? 'Off' : 'On',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _onMapTypeButtonPressed() {
    ref.read(mapTypeProvider.notifier).update((state) {
      if (state == MapType.normal) {
        return MapType.satellite;
      } else if (state == MapType.satellite) {
        return MapType.hybrid;
      } else {
        return MapType.normal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final vehicleMarker = ref.watch(vehicleMarkerProvider);
    final polylines = ref.watch(polylinesProvider);
    final speed = ref.watch(speedProvider);
    final mapType = ref.watch(mapTypeProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomColors.blueColor,
        title: Text(
          'livetracking.livetracking'.tr(),
          style: TextStyle(color: CustomColors.whiteColor, fontSize: 24),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: mapType,
            onMapCreated: (controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
                target: LatLng(widget.latitude, widget.longitud), zoom: 15),
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: vehicleMarker != null ? {vehicleMarker} : {},
            polylines: polylines,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _onMapTypeButtonPressed,
                  materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // Minimized padding
                  mini: true,
                  backgroundColor: Color.fromARGB(183, 255, 255, 255),
                  heroTag: 'changeMapButton', // Unique heroTag

                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Boxicons.bx_layer,
                      color: CustomColors.blueSecondaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 14), // Space between buttons
                FloatingActionButton(
                  onPressed: shareCoordinates,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  mini: true,
                  backgroundColor: Color.fromARGB(183, 255, 255, 255),
                  heroTag: 'shareCoordinatesButton',
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Boxicons.bx_share_alt,
                      color: CustomColors.blueSecondaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 14), // Space between buttons
                FloatingActionButton(
                  onPressed: _showMarkerInfo,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  mini: true,
                  backgroundColor: Color.fromARGB(183, 255, 255, 255),
                  heroTag: 'shareCoordinatesButtons',
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Boxicons.bxs_card,
                      color: CustomColors.blueSecondaryColor,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.45),
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpeedometerChart(
                        dimension: 65,
                        minValue: 0,
                        maxValue: 200,
                        value: speed.toDouble(),
                        graphColor: [Colors.green, Colors.yellow, Colors.red],
                        pointerColor: Colors.black,
                      ),
                      Text(
                        "${speed} Km/h",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == 0) {
            context.go('/home');
          } else if (index == 1) {
            context.go('/mycars');
          } else if (index == 2) {
            context.go('/charts');
          } else if (index == 3) {
            context.go('/settings');
          }
          ref.read(selectedIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
