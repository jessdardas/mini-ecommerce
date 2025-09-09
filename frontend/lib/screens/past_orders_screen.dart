import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PastOrdersScreen extends StatefulWidget {
  const PastOrdersScreen({Key? key}) : super(key: key);

  @override
  _PastOrdersScreenState createState() => _PastOrdersScreenState();
}

class _PastOrdersScreenState extends State<PastOrdersScreen> {
  late Future<List<Map<String, dynamic>>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = ApiService.fetchPastOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Past Orders")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No past orders found"));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order ID: ${order['id']}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("Date: ${order['createdAt']}"),
                      const SizedBox(height: 8),
                      const Text("Items:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...List.generate(order['items'].length, (i) {
                        final item = order['items'][i];
                        return Text(
                            "Product ID: ${item['productId']}, Qty: ${item['quantity']}, Price: \$${item['price']}");
                      }),
                      const SizedBox(height: 4),
                      Text(
                        "Total: \$${order['items'].fold(0, (sum, item) => sum + (item['price'] * item['quantity']))}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
