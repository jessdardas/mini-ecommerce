package com.example.ecommerce.controller;

import com.example.ecommerce.dto.OrderRequest;
import com.example.ecommerce.model.Order;
import com.example.ecommerce.model.Product;
import com.example.ecommerce.repository.ProductRepository;
import com.example.ecommerce.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class OrderController {

    private final OrderService orderService;

    @Autowired
    private ProductRepository productRepository;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    // ==========================
    // User endpoint: place order
    // ==========================
    @PostMapping("/orders")
    public ResponseEntity<?> placeOrder(@RequestBody OrderRequest orderRequest) {
        Long userId = 1L; // hardcoded for now

        try {
            Order order = orderService.placeOrder(userId, orderRequest.getItems());
            return ResponseEntity.status(HttpStatus.CREATED).body(order);
        } catch (Exception e) {
            // Return 400 Bad Request with message
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    new ErrorResponse(e.getMessage())
            );
        }
    }

    // ==========================
    // User endpoint: view own orders
    // ==========================
    @GetMapping("/orders/me")
    public List<Order> getUserOrders() {
        Long userId = 1L; // hardcoded for now
        return orderService.getUserOrders(userId);
    }

    // ==========================
    // Admin endpoint: view all orders
    // ==========================
    @GetMapping("/admin/orders")
    public List<Order> getAllOrders() {
        return orderService.getAllOrders();
    }

    // ==========================
    // Admin endpoint: low-stock products
    // ==========================
    @GetMapping("/admin/low-stock")
    public List<Product> getLowStockProducts() {
        return productRepository.findByQuantityLessThan(5);
    }

    // ==========================
    // Error response inner class
    // ==========================
    static class ErrorResponse {
        private String message;

        public ErrorResponse(String message) { this.message = message; }
        public String getMessage() { return message; }
        public void setMessage(String message) { this.message = message; }
    }
}
