import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/api_service.dart';
import 'past_orders_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Cart")),
      body: cart.items.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text(
                          "${item.quantity} x \$${item.product.price.toStringAsFixed(2)}",
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Subtotal: \$${cart.subtotal.toStringAsFixed(2)}"),
                      Text("Tax: \$${cart.tax.toStringAsFixed(2)}"),
                      Text("Total: \$${cart.total.toStringAsFixed(2)}"),
                      const SizedBox(height: 16),

                      // Place Order button
                      ElevatedButton(
                        onPressed: cart.items.isEmpty
                            ? null
                            : () async {
                                try {
                                  final items = cart.items.map((item) {
                                    return {
                                      "productId": item.product.id,
                                      "quantity": item.quantity,
                                    };
                                  }).toList();

                                  final res =
                                      await ApiService.placeOrder(items);

                                  if (res["id"] != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Order placed successfully!"),
                                      ),
                                    );
                                    cart.clearCart(); // clear cart after success
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Failed to place order."),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Error placing order: $e")),
                                  );
                                }
                              },
                        child: const Text("Place Order"),
                      ),

                      // View Past Orders button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PastOrdersScreen(),
                            ),
                          );
                        },
                        child: const Text("View Past Orders"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}