import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../models/product.dart';

class ApiService {
  // Base URL depending on platform
  static String get base {
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

  static Future<List<Product>> fetchProducts() async {
    final res = await http.get(Uri.parse('$base/api/products'));

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load products: ${res.body}");
    }
  }

  // -------------------
  // ORDERS
  // -------------------

  static Future<Map<String, dynamic>> placeOrder(List<Map<String, dynamic>> items) async {
    final token = await TokenStorage.getToken();
    final res = await http.post(
      Uri.parse('$base/api/orders'),
      headers: _authHeaders(token),
      body: jsonEncode({'items': items}),
    );

    return _parseResponse(res);
  }

  // -------------------
  // Fetch past orders
  // -------------------

  static Future<List<Map<String, dynamic>>> fetchPastOrders() async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.get(
        Uri.parse("${base}/api/orders/me"),
        headers: _authHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((order) {
          final items = (order['items'] as List<dynamic>).map((item) {
            return {
              'id': item['id'],
              'productId': item['product']?['id'] ?? item['id'],
              'quantity': item['quantity'],
              'price': item['price'],
            };
          }).toList();

          return {
            'id': order['id'],
            'userId': order['userId'],
            'createdAt': order['createdAt'],
            'items': items,
          };
        }).toList();
      } else {
        throw Exception("Failed to fetch past orders");
      }
    } catch (e) {
      print("Error fetching past orders: $e");
      return [];
    }
  }

  // -------------------
  // HELPERS
  // -------------------

  static Map<String, String> _authHeaders(String? token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static dynamic _parseResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isNotEmpty ? jsonDecode(res.body) : {};
    } else if (res.statusCode == 401) {
      TokenStorage.clearToken();
      throw Exception('Unauthorized - please login again.');
    } else {
      throw Exception('API Error ${res.statusCode}: ${res.body}');
    }
  }
}
