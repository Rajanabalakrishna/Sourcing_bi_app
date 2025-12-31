

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Transport_provider/transport_model.dart';



class TransportService {
  static const String _baseUrl = 'https://supply.bharatintelligence.ai'; // Replace with your actual base URL

  Future<TransportProvider> getTransportProvider(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/transport-providers/$id/'));

    if (response.statusCode == 200) {
      return TransportProvider.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load transport provider');
    }
  }
}