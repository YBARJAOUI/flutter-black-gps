import 'dart:async';

import 'package:blackgps/components/CustomBottomNavBar.dart';
import 'package:blackgps/constants/colors.dart';
import 'package:blackgps/providers/authProviders.dart';
import 'package:blackgps/providers/commonProviders.dart';
import 'package:blackgps/providers/homeProviders.dart';
import 'package:blackgps/providers/settingsProviders.dart';
import 'package:blackgps/utils/TokenManagement.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  late GoogleMapController mapController;
  Timer? refreshTimer;
  final LatLng _center = const LatLng(33.521563, -5.677433);

  @override
  void initState() {
    super.initState();
    ref.read(fetchCarsFutureProvider);

    final messaging = FirebaseMessaging.instance;
    messaging.getToken().then((token) async {
      await updateTokenDevice(ref, token);
      print("Firebase Token: $token");
    });
//here

    startRefreshTimer();
  }

  void startRefreshTimer() {
    refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!mounted) return;
      ref.read(fetchCarsFutureProvider);
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> updateTokenDevice(WidgetRef ref, String? tokenDevice) async {
    if (!mounted) return;

    final token = await TokenStorage().loadTokens();
    if (token == null) {
      print("Token is null");
      return;
    }

    final apiService = ref.read(apiServiceProvider);
    //final userDetails = ref.read(userDataProvider);
    try {
      await apiService.put('app/users', data: {
        'device_token': tokenDevice
      }, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token['accessToken']}'
      });
    } catch (e) {
      print('Error updating token device: $e');
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        GoRouter.of(context).push('/mycars');
        break;
      case 2:
        GoRouter.of(context).push('/charts');
        break;
      case 3:
        GoRouter.of(context).push('/settings');
        break;
      default:
    }

    ref.read(selectedIndexProvider.notifier).state = index;
  }

  void _onSelect(MapType type) {
    ref.read(currentMapTypeProvider.notifier).state = type;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void logout() async {
    try {
      final tokens = await TokenStorage().deleteTokens();
      ref.read(loginStateProvider.notifier).logout(); // Update the login state
      context.go('/');
      print("Logout clicked");
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Erreur lors de la déconnexion : $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  context.go('/');
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final imeiList = ref.watch(imeiListProvider);
    final markers = ref.watch(markersProvider);
    final currentMapType = ref.watch(currentMapTypeProvider);
    final selectedIndex = ref.watch(selectedIndexProvider);
    final markersLoaded = ref.watch(markersLoadedProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: CustomColors.blueColor,
          automaticallyImplyLeading: false,
          title: Text(
            'BLACK GPS',
            style: TextStyle(color: CustomColors.whiteColor),
          ),
          actions: [
            IconButton(
              icon: Icon(Boxicons.bx_log_out_circle,
                  color: CustomColors.whiteColor),
              onPressed: logout,
            ),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(target: _center, zoom: 6.2),
              markers: markers,
              mapType: currentMapType,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: PopupMenuButton<MapType>(
                color: Color.fromARGB(239, 226, 225, 225),
                onSelected: _onSelect,
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<MapType>>[
                  const PopupMenuItem<MapType>(
                    value: MapType.normal,
                    child: Text('Normal'),
                  ),
                  const PopupMenuItem<MapType>(
                    value: MapType.satellite,
                    child: Text('Satellite'),
                  ),
                  const PopupMenuItem<MapType>(
                    value: MapType.hybrid,
                    child: Text('Hybride'),
                  ),
                ],
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(183, 255, 255, 255),
                  child: Icon(
                    Icons.layers,
                    size: 36.0,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            if (!markersLoaded)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
