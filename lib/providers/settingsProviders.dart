import 'package:blackgps/providers/commonProviders.dart';
import 'package:blackgps/utils/TokenManagement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:ffcache/ffcache.dart';
import 'package:blackgps/utils/ApiService.dart';

final isNotificationProvider = StateProvider<bool>((ref) => false);
final userDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

final firstNameControllerProvider = Provider((ref) => TextEditingController());
final lastNameControllerProvider = Provider((ref) => TextEditingController());
final phoneControllerProvider = Provider((ref) => TextEditingController());
final newPasswordControllerProvider =
    Provider((ref) => TextEditingController());
final confirmPasswordControllerProvider =
    Provider((ref) => TextEditingController());

final fetchUserProvider = FutureProvider<void>((ref) async {
  final tokens = await TokenStorage().loadTokens();
  final apiService = ref.read(apiServiceProvider);

  if (tokens == null) {
    print("Token is null");
    return;
  }

  try {
    final response = await apiService.get('app/users', headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokens['accessToken']}'
    });
    ref.read(userDataProvider.notifier).state = response.first;
    ref.read(isNotificationProvider.notifier).state =
        response.first["is_notification"];
    ref.read(firstNameControllerProvider).text =
        response.first["first_name"] ?? "";
    ref.read(lastNameControllerProvider).text =
        response.first["last_name"] ?? "";
    ref.read(phoneControllerProvider).text = response.first["phone"] ?? "";
  } catch (e) {
    print('Error fetching user data: $e');
  }
});
