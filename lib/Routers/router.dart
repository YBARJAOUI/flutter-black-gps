import 'package:blackgps/providers/authProviders.dart';
import 'package:blackgps/screens/auth/signin.dart';
import 'package:blackgps/screens/main/dashboard.dart';
import 'package:blackgps/screens/main/home.dart';
import 'package:blackgps/screens/main/mycars.dart';
import 'package:blackgps/screens/main/settings.dart';
import 'package:blackgps/screens/main/tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(loginStateProvider);

  return GoRouter(
    initialLocation: '/',
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Signin(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => Home(),
      ),
      GoRoute(
        path: '/mycars',
        builder: (context, state) => MyCars(),
      ),
      GoRoute(
        path: '/charts',
        builder: (context, state) => FleetManagement(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsPage(),
      ),
      // GoRoute(
      //   path: '/tracking/:imei',
      //   builder: (context, state) {
      //     final imei = state.pathParameters['imei']!;
      //     final extra = state.extra as Map<String, dynamic>?;

      //     if (extra == null) {
      //       return Scaffold(
      //         body: Center(
      //           child: Text('Missing parameters'),
      //         ),
      //       );
      //     }
      //     final lat = extra['latitude'] as String;
      //     final lon = extra['longitude'] as String;

      //     return Tracking(
      //       imei: imei,
      //       initialLatitude: double.parse(lat),
      //       initialLongitude: double.parse(lon),
      //     );
      //   },
      // ),
      GoRoute(
        path: '/tracking/:imei/:latitude/:longitude',
        builder: (context, state) {
          final imei = state.pathParameters['imei']!;
          final latitude = state.pathParameters['latitude']!;
          final longitude = state.pathParameters['longitude']!;
          return Tracking(
            imei: imei,
            latitude: double.parse(latitude),
            longitud: double.parse(longitude),
          );
        },
      ),
    ],
    redirect: (context, state) {
      final loggedIn = isLoggedIn;
      final loggingIn = state.uri.toString() == '/';

      if (!loggedIn && !loggingIn) return '/';
      if (loggedIn && loggingIn) return '/home';

      return null;
    },
  );
});
