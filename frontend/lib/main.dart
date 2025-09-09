import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/catalog_screen.dart';

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
        '/catalog': (context) => CatalogScreen(), // add later
      },
    );
  }
}
