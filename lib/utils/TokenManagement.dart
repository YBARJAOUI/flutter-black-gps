import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<Map<String, String>?> loadTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(_accessTokenKey);
    String? refreshToken = prefs.getString(_refreshTokenKey);

    if (accessToken != null && refreshToken != null) {
      return {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    }
    return null; // or throw an exception if you prefer
  }

  Future<void> deleteTokens() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
