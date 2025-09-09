package com.example.ecommerce.controller;

import com.example.ecommerce.dto.OrderRequest;
import com.example.ecommerce.model.Order;
import com.example.ecommerce.model.Product;
import com.example.ecommerce.model.User;
import com.example.ecommerce.repository.ProductRepository;
import com.example.ecommerce.repository.UserRepository;
import com.example.ecommerce.service.OrderService;
import com.example.ecommerce.util.JwtUtil;
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

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtil jwtUtil;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    // ==========================
    // Place order (user must be logged in)
    // ==========================
    @PostMapping("/orders")
    public ResponseEntity<?> placeOrder(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody OrderRequest orderRequest) {

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Missing or invalid token");
        }

        String token = authHeader.substring(7);
        String email = jwtUtil.extractUsername(token);
        User user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token user");
        }

        try {
            Order order = orderService.placeOrder(user.getId(), orderRequest.getItems());
            return ResponseEntity.status(HttpStatus.CREATED).body(order);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorResponse(e.getMessage()));
        }
    }

    // ==========================
    // View own orders
    // ==========================
    @GetMapping("/orders/me")
    public ResponseEntity<?> getUserOrders(@RequestHeader("Authorization") String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Missing or invalid token");
        }

        String token = authHeader.substring(7);
        String email = jwtUtil.extractUsername(token);
        User user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token user");
        }

        List<Order> orders = orderService.getUserOrders(user.getId());
        return ResponseEntity.ok(orders);
    }

    // ==========================
    // Admin endpoints
    // ==========================
    @GetMapping("/admin/orders")
    public List<Order> getAllOrders() {
        return orderService.getAllOrders();
    }

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
