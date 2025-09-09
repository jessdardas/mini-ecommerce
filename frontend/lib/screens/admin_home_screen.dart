import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/product.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0;
  String _description = '';
  int _stock = 0;

  List<Map<String, dynamic>> _orders = [];
  List<Product> _lowStock = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAllOrders();
    _fetchLowStock();
  }

  Future<void> _fetchAllOrders() async {
    try {
      final orders = await ApiService.fetchAllOrders();
      setState(() => _orders = orders);
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    }
  }

  Future<void> _fetchLowStock() async {
    try {
      final products = await ApiService.fetchLowStock();
      setState(() => _lowStock = products);
    } catch (e) {
      debugPrint("Error fetching low stock: $e");
    }
  }

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await ApiService.addProduct(_name, _price, _description, _stock);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product added successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Add Product"),
            Tab(text: "All Orders"),
            Tab(text: "Low Stock"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ----------------
          // ADD PRODUCT TAB
          // ----------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Product Name"),
                    onSaved: (v) => _name = v!,
                    validator: (v) => v!.isEmpty ? "Enter product name" : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Price"),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _price = double.parse(v!),
                    validator: (v) => v!.isEmpty ? "Enter price" : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Description"),
                    onSaved: (v) => _description = v!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Stock Quantity"),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _stock = int.parse(v!),
                    validator: (v) => v!.isEmpty ? "Enter stock quantity" : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addProduct,
                    child: const Text("Add Product"),
                  )
                ],
              ),
            ),
          ),

          // ----------------
          // ALL ORDERS TAB
          // ----------------
          ListView.builder(
            itemCount: _orders.length,
            itemBuilder: (context, i) {
              final order = _orders[i];
              return ListTile(
                title: Text("Order #${order['id']}"),
                subtitle: Text("User: ${order['userId']} | Items: ${order['items'].length}"),
              );
            },
          ),

          // ----------------
          // LOW STOCK TAB
          // ----------------
          ListView.builder(
            itemCount: _lowStock.length,
            itemBuilder: (context, i) {
              final p = _lowStock[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text("Stock: ${p.stock} | Price: \$${p.price}"),
                leading: const Icon(Icons.warning, color: Colors.red),
              );
            },
          ),
        ],
      ),
    );
  }
}
