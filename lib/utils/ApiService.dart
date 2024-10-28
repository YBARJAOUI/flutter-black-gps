import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // final String baseUrl = "http://192.168.1.130:8000/";
  final String baseUrl = "https://mobile.blackgps.xyz/";
  // "https://mobile.blackgps.xyz/";

  ApiService();

  Future<List<Map<String, dynamic>>> get(String endpoint,
      {Map<String, String>? headers}) async {
    final http.Response response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    return _resp(response);
  }

  List<Map<String, dynamic>> _resp(http.Response response) {
    if (response.statusCode == 200) {
      // Parsing the JSON response body
      List<dynamic> jsonResponse = json.decode(response.body);

      // Converting List<dynamic> to List<Map<String, dynamic>>
      List<Map<String, dynamic>> dataList = [];
      for (var item in jsonResponse) {
        dataList.add(Map<String, dynamic>.from(item));
      }

      return dataList;
    } else {
      // If the response was not successful, throw an error
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, String>? headers, data}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, String>? headers, data}) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers ?? {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data; // Successful response
    } else {
      throw Exception(data['detail']); // Handle errors
    }
  }
}

// import 'package:http/http.dart' as http;

// Future<void> fetchData() async {
//   final url = 'http://127.0.0.1:8000/app/cars';
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     // Traitement des données si la requête est réussie
//     print('Data: ${response.body}');
//   } else {
//     // Gestion des erreurs si la requête échoue
//     print('Request failed with status: ${response.statusCode}');
//   }
// }

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:jwt_io/jwt_io.dart';

// class ApiService {
//   final String baseUrl = "https://mobile.blackgps.xyz/";
//   String? _accessToken;
//   String? _refreshToken;

//   ApiService();

//   Future<void> _refreshAccessToken() async {
//     final response = await http.post(
//       Uri.parse('${baseUrl}api/token/refresh/'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'refresh': _refreshToken}),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       _accessToken = data['access'];
//       _refreshToken = data['refresh'];
//     } else {
//       throw Exception('Failed to refresh token');
//     }
//   }

//   Future<void> _checkAndRefreshToken() async {
//     if (_accessToken != null) {
//       final jwt = _accessToken!;
//       bool hasExpired = JwtToken.isExpired(jwt);

//       if (hasExpired) {
//         await _refreshAccessToken();
//       }
//     }
//   }

//   Future<List<Map<String, dynamic>>> get(String endpoint,
//       {Map<String, String>? headers}) async {
//     await _checkAndRefreshToken();
//     final http.Response response = await http.get(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: {
//         ...?headers,
//         if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
//       },
//     );
//     return _resp(response);
//   }

//   Future<Map<String, dynamic>> post(String endpoint,
//       {Map<String, String>? headers, data}) async {
//     await _checkAndRefreshToken();
//     final response = await http.post(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: {
//         ...?headers,
//         if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(data),
//     );
//     return _handleResponse(response);
//   }

//   Future<Map<String, dynamic>> put(String endpoint,
//       {Map<String, String>? headers, data}) async {
//     await _checkAndRefreshToken();
//     final response = await http.put(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: {
//         ...?headers,
//         if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(data),
//     );
//     return _handleResponse(response);
//   }

//   Future<Map<String, dynamic>> delete(String endpoint,
//       {Map<String, String>? headers}) async {
//     await _checkAndRefreshToken();
//     final response = await http.delete(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: {
//         ...?headers,
//         if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
//       },
//     );
//     return _handleResponse(response);
//   }

//   List<Map<String, dynamic>> _resp(http.Response response) {
//     if (response.statusCode == 200) {
//       // Parsing the JSON response body
//       List<dynamic> jsonResponse = json.decode(response.body);

//       // Converting List<dynamic> to List<Map<String, dynamic>>
//       List<Map<String, dynamic>> dataList = [];
//       for (var item in jsonResponse) {
//         dataList.add(Map<String, dynamic>.from(item));
//       }

//       return dataList;
//     } else {
//       // If the response was not successful, throw an error
//       throw Exception('Failed to load data: ${response.statusCode}');
//     }
//   }

//   Map<String, dynamic> _handleResponse(http.Response response) {
//     final Map<String, dynamic> data = json.decode(response.body);

//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return data; // Successful response
//     } else {
//       throw Exception(data['detail']); // Handle errors
//     }
//   }
// }
