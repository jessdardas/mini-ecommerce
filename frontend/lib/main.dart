import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/admin_home_screen.dart';

void main() {
  runApp(const MiniEcommerceApp());
}

class MiniEcommerceApp extends StatelessWidget {
  const MiniEcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Ecommerce',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/catalog': (context) => CatalogScreen(),
        '/adminHome': (context) => const AdminHomeScreen(),
      },
    );
  }
}
