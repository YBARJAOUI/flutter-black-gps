import 'package:blackgps/utils/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
BuildContext get globalContext => navigatorKey.currentContext!;

final loadingProvider = StateProvider<bool>((ref) => false);
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

void startLoading(WidgetRef ref) {
  ref.read(loadingProvider.notifier).state = true;
}

void stopLoading(WidgetRef ref) {
  ref.read(loadingProvider.notifier).state = false;
}
