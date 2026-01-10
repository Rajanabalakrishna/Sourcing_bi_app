import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mukadam_bi/notes/markVisitedModel.dart';
import 'package:mukadam_bi/notes/visitPlanModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'end_Screen.dart';


class VisitApiService {
  static const String _baseUrl = 'https://furtive-chrissy-reparably.ngrok-free.dev';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_token');
  }


  Future<List<VisitPlan>> fetchPlannedVisits() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/visit-plans/my_plans/?is_executed=false'),
        headers: {
          'Authorization': 'Token ${token ?? ""}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => VisitPlan.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<List<alreadyVisitedPaln>> fetchExecutedVisits() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/visit-plans/my_plans/?is_executed=true'),
        headers: {
          'Authorization': 'Token ${token ?? ""}',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => alreadyVisitedPaln.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load history');
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
