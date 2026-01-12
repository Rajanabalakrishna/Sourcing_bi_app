import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


//static const String baseUrl = 'https://supply.bharatintelligence.ai';
class LocationApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl:'https://supply.bharatintelligence.ai/api',//'https://furtive-chrissy-reparably.ngrok-free.dev/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // POST: Send location to backend
  static Future<void> postLocation(Map<String, dynamic> payload) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none))  return ;

      final response = await _dio.post('/user-locations/', data: payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("API Success: Location Synced");

      }

    } catch (e) {
      print("API Post Error: $e");
    }
  }

  // GET: Fetch location history for the map
  static Future<List<Map<String, dynamic>>> getLocationHistory(int userId) async {
    try {
      final response = await _dio.get('/user-locations/', queryParameters: {
        'user_id': userId,
      });

      if (response.statusCode == 200) {
        // Adjust this based on your actual API response structure
        List<dynamic> data = response.data;
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print("API Fetch Error: $e");
    }
    return [];
  }
}
