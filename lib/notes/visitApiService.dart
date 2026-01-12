import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/notes/markVisitedModel.dart';
import 'package:mukadam_bi/notes/visitPlanModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'end_Screen.dart';


class VisitApiService {
 // static const String _baseUrl = 'https://furtive-chrissy-reparably.ngrok-free.dev';

  static const String _baseUrl = 'https://supply.bharatintelligence.ai';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }


  Future<List<VisitPlan>> fetchPlannedVisits() async {
    final token = await _getToken();
    final prefs = await SharedPreferences.getInstance();
    // Taking user_id from SharedPreferences as requested
    final userId = prefs.getInt('bg_user_id');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/visit-plans/my_plans/?is_executed=false&status=planned&user_id=$userId'),
        headers: {
          'Authorization': 'Token ${token ?? ""}',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        // Updated to handle the new response structure where data is inside a "data" key
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        return data.map((json) => VisitPlan.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<List<VisitPlan>> fetchTodayVisits(String date) async {
    final token = await _getToken();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('bg_user_id');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/visit-plans/my_plans/?day=$date&user_id=$userId'),
        headers: {
          'Authorization': 'Token ${token ?? ""}',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((json) => VisitPlan.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load today\'s plans: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching today\'s data: $e');
    }
  }


  Future<List<alreadyVisitedPaln>> fetchExecutedVisits({
    required String dateFrom,
    required String dateTo,
  }) async {
    final token = await _getToken();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('bg_user_id');

    // Using the exact URL structure provided in your query
    final url = '$_baseUrl/api/visit-plans/my_plans/?is_executed=true&date_from=$dateFrom&date_to=$dateTo&user_id=$userId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token ${token ?? ""}',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        // Map data using your alreadyVisitedPaln model
        return data.map((json) => alreadyVisitedPaln.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }


  Future<bool> markPlanAsExecuted(int planId) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/visit-plans/$planId/mark_executed/'),
        headers: {
          'Authorization': 'Token ${token ?? ""}',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error marking plan: $e");
      return false;
    }
  }


}
