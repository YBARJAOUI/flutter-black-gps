import 'package:blackgps/providers/commonProviders.dart';
import 'package:blackgps/utils/ApiService.dart';
import 'package:blackgps/utils/TokenManagement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imeiMyCarsListProvider = StateProvider<List<String>>((ref) => []);
final carListdataProvider =
    StateProvider<Map<String, List<dynamic>>>((ref) => {});

final fetchMyCarsProvider = FutureProvider<void>((ref) async {
  final tokens = await TokenStorage().loadTokens();
  final apiService = ref.read(apiServiceProvider);

  if (tokens == null) {
    print("Token is null");
    return;
  }

  try {
    final List response = await apiService.get('app/cars', headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${tokens['accessToken']}'
    });

    print(response);
    if (response == null || response.isEmpty) {
      print('Error: response is null or empty');
      return;
    }

    // Update providers
    ref.read(imeiMyCarsListProvider.notifier).state =
        response.map((car) => car['gpsdevice'].toString()).toList();

    final cardata = ref.read(carListdataProvider.notifier);
    cardata.update((state) {
      final newState = {...state};
      for (var car in response) {
        newState[car['gpsdevice'].toString()] = [
          car['name'] ?? 'Unknown',
          car['plate_number'] ?? 'Unknown',
          car['numero_voiture'] ?? 'Unknown',
          car['gpsdevice_phone_number'] ?? 'Unknown',
          car['image'] ?? 'assets/placeholder.png'
        ];
      }
      return newState;
    });

    // Optionally, call gpsinfo for each IMEI if needed
    for (String imei in ref.read(imeiMyCarsListProvider)) {
      print("Fetching GPS info for IMEI: $imei");
      await gpsinfo(ref, imei);
    }
  } catch (e) {
    print('Error getting cars: $e');
  }
});

Future<void> gpsinfo(FutureProviderRef<void> ref, String imei) async {
  // Implement your gpsinfo logic here
  print("Fetching GPS info for IMEI: $imei");
  // Example of fetching additional data
  final apiService = ref.read(apiServiceProvider);
  try {
    final gpsInfo = await apiService.get('app/gpsinfo/$imei');
    // Process and update state with the gpsInfo
  } catch (e) {
    print('Error getting GPS info for $imei: $e');
  }
}
