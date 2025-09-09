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
    // Place order (USER only)
    // ==========================
    @PostMapping("/orders")
    public ResponseEntity<?> placeOrder(
            @RequestHeader("Authorization") String authHeader,
            @RequestBody OrderRequest orderRequest) {

        User user = validateUserFromToken(authHeader);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid or missing token");
        }

        try {
            Order order = orderService.placeOrder(user.getId(), orderRequest.getItems());
            return ResponseEntity.status(HttpStatus.CREATED).body(order);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(new ErrorResponse(e.getMessage()));
        }
    }

    // ==========================
    // View own orders (USER only)
    // ==========================
    @GetMapping("/orders/me")
    public ResponseEntity<?> getUserOrders(@RequestHeader("Authorization") String authHeader) {
        User user = validateUserFromToken(authHeader);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid or missing token");
        }

        List<Order> orders = orderService.getUserOrders(user.getId());
        return ResponseEntity.ok(orders);
    }

    // ==========================
    // Admin endpoints
    // ==========================
    @GetMapping("/admin/orders")
    public ResponseEntity<?> getAllOrders(@RequestHeader("Authorization") String authHeader) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Admins only");
        }
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    @GetMapping("/admin/low-stock")
    public ResponseEntity<?> getLowStockProducts(@RequestHeader("Authorization") String authHeader) {
        if (!isAdmin(authHeader)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Admins only");
        }
        return ResponseEntity.ok(productRepository.findByQuantityLessThan(5));
    }

    // ==========================
    // Helpers
    // ==========================
    private User validateUserFromToken(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return null;
        }
        String token = authHeader.substring(7);
        String email = jwtUtil.extractUsername(token);
        return userRepository.findByEmail(email).orElse(null);
    }

    private boolean isAdmin(String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return false;
        }
        String token = authHeader.substring(7);
        String role = jwtUtil.extractRole(token);
        return "ADMIN".equals(role);
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
