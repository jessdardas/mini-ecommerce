import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb



class ApiService {
  // Base URL, automatically resolves depending on platform
  static String get base {
    // Use localhost for web; mobile emulator uses 10.0.2.2 for Android emulator
    return kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
  }

  // -------------------
  // AUTH
  // -------------------

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$base/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _parseResponse(res);

    // Save token automatically
    if (data.containsKey('token')) {
      await TokenStorage.saveToken(data['token']);
    }

    return data;
  }

  static Future<Map<String, dynamic>> register(String email, String password) async {
    final res = await http.post(
      Uri.parse('$base/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _parseResponse(res);
  }

  // -------------------
  // PRODUCTS
  // -------------------

  static Future<List<dynamic>> getProducts() async {
    final token = await TokenStorage.getToken();
    final res = await http.get(
      Uri.parse('$base/api/products'),
      headers: _authHeaders(token),
    );
    final body = _parseResponse(res);
    return body as List<dynamic>;
  }

  // -------------------
  // ORDERS
  // -------------------

  static Future<Map<String, dynamic>> placeOrder(List<Map<String, dynamic>> items) async {
    final token = await TokenStorage.getToken();
    final res = await http.post(
      Uri.parse('$base/api/orders'),
      headers: _authHeaders(token)..addAll({'Content-Type': 'application/json'}),
      body: jsonEncode({'items': items}),
    );
    return _parseResponse(res);
  }

  // -------------------
  // HELPERS
  // -------------------

  static Map<String, String> _authHeaders(String? token) {
    final headers = <String, String>{};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  static dynamic _parseResponse(http.Response res) {
    if (res.statusCode == 204) return {};
    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode >= 200 && res.statusCode < 300) return decoded ?? {};

    if (res.statusCode == 401) {
      TokenStorage.clearToken();
      throw Exception('Unauthorized - please login again.');
    }

    throw Exception('API Error ${res.statusCode}: ${res.body}');
  }
}
