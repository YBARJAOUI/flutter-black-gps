import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blackgps/utils/TokenManagement.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blackgps/utils/TokenManagement.dart';

class LoginStateNotifier extends StateNotifier<bool> {
  LoginStateNotifier() : super(false);

  Future<void> checkLoginState() async {
    final tokenStorage = TokenStorage();
    final tokens = await tokenStorage.loadTokens();
    state = tokens != null;
  }

  void login() => state = true;

  void logout() => state = false;
}

final loginStateProvider = StateNotifierProvider<LoginStateNotifier, bool>((ref) {
  return LoginStateNotifier();
});
